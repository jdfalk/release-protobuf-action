#!/usr/bin/env bash
# file: src/entrypoint.sh
# version: 1.0.0
# guid: 5f7a9c1d-2e3b-4c5d-8f9a-0b1c2d3e4f5a

set -euo pipefail

BUF_VERSION=${BUF_VERSION:-latest}
PROTO_DIR=${PROTO_DIR:-proto}
BUF_CONFIG=${BUF_CONFIG:-buf.yaml}
BUF_GEN_CONFIG=${BUF_GEN_CONFIG:-buf.gen.yaml}
GENERATE_SDKS=${GENERATE_SDKS:-true}
SDK_LANGUAGES=${SDK_LANGUAGES:-go}
OUTPUT_DIR=${OUTPUT_DIR:-gen}
RUN_LINT=${RUN_LINT:-true}
RUN_BREAKING=${RUN_BREAKING:-true}
AGAINST_BRANCH=${AGAINST_BRANCH:-main}
CREATE_TAGS=${CREATE_TAGS:-true}
TAG_PREFIX=${TAG_PREFIX:-proto}
GITHUB_TOKEN=${GITHUB_TOKEN:-}
GITHUB_REF=${GITHUB_REF:-}

write_output() {
  name=$1
  value=$2
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf '%s=%s\n' "$name" "$value" >>"$GITHUB_OUTPUT"
  fi
}

write_summary() {
  text=$1
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    printf '%s\n' "$text" >>"$GITHUB_STEP_SUMMARY"
  fi
}

if [ ! -f "$BUF_CONFIG" ]; then
  echo "::error::buf.yaml not found at $BUF_CONFIG"
  exit 1
fi

if [ "$GENERATE_SDKS" = "true" ] && [ ! -f "$BUF_GEN_CONFIG" ]; then
  echo "::error::buf.gen.yaml not found at $BUF_GEN_CONFIG"
  exit 1
fi

if [ "$RUN_LINT" = "true" ]; then
  buf lint --config "$BUF_CONFIG"
fi

if [ "$RUN_BREAKING" = "true" ]; then
  buf breaking --against ".git#branch=${AGAINST_BRANCH}" --config "$BUF_CONFIG" || true
fi

if [ "$GENERATE_SDKS" = "true" ]; then
  mkdir -p "$OUTPUT_DIR"
  buf generate --config "$BUF_GEN_CONFIG"
  write_output "languages" "$SDK_LANGUAGES"
  write_output "path" "$OUTPUT_DIR"
fi

if [ "$CREATE_TAGS" = "true" ] && [ "${GITHUB_REF#refs/tags/}" != "$GITHUB_REF" ]; then
  BASE_TAG="${GITHUB_REF#refs/tags/}"
  IFS=',' read -ra LANGS <<<"$SDK_LANGUAGES"

  git config user.name "github-actions[bot]"
  git config user.email "github-actions[bot]@users.noreply.github.com"

  for lang in "${LANGS[@]}"; do
    SDK_TAG="${TAG_PREFIX}/${lang}/${BASE_TAG}"
    git tag -a "$SDK_TAG" -m "Protocol Buffer SDK release for ${lang}: ${BASE_TAG}"
    git push origin "$SDK_TAG" || echo "Warning: failed to push tag $SDK_TAG"
  done
fi

write_summary "## Protocol Buffer Release Summary"
write_summary ""
write_summary "**Proto Directory:** ${PROTO_DIR}"
write_summary "**SDK Languages:** ${SDK_LANGUAGES}"
write_summary "**Output Directory:** ${OUTPUT_DIR}"
