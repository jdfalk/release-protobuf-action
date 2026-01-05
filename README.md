# release-protobuf-action

GitHub Action for Protocol Buffer releases and SDK generation, with optional
dockerized execution.

## Features

- ✅ Buf lint and breaking change checks
- ✅ SDK generation for multiple languages
- ✅ Optional SDK tag creation
- ✅ Docker path for reproducible runs

## Usage

```yaml
- uses: jdfalk/release-protobuf-action@v1
  with:
    sdk-languages: go,python,typescript
    create-tags: true
```

### Force Docker Execution

```yaml
- uses: jdfalk/release-protobuf-action@v1
  with:
    use-docker: true
    docker-image: ghcr.io/jdfalk/release-protobuf-action:main
    sdk-languages: go
```

## Inputs

| Input            | Description                                                      | Required | Default                                       |
| ---------------- | ---------------------------------------------------------------- | -------- | --------------------------------------------- |
| `buf-version`    | Buf version to use                                               | No       | `latest`                                      |
| `proto-dir`      | Directory containing .proto files                                | No       | `proto`                                       |
| `buf-config`     | Path to buf.yaml                                                 | No       | `buf.yaml`                                    |
| `buf-gen-config` | Path to buf.gen.yaml                                             | No       | `buf.gen.yaml`                                |
| `generate-sdks`  | Whether to generate SDKs                                         | No       | `true`                                        |
| `sdk-languages`  | SDK languages to generate                                        | No       | `go`                                          |
| `output-dir`     | Output directory for generated code                              | No       | `gen`                                         |
| `run-lint`       | Run buf lint                                                     | No       | `true`                                        |
| `run-breaking`   | Check for breaking changes                                       | No       | `true`                                        |
| `against-branch` | Branch to check breaking changes against                         | No       | `main`                                        |
| `create-tags`    | Create SDK-specific tags                                         | No       | `true`                                        |
| `tag-prefix`     | Tag prefix for SDK releases                                      | No       | `proto`                                       |
| `github-token`   | GitHub token for tagging                                         | No       | `${{ github.token }}`                         |
| `use-docker`     | Run the action inside the published container image              | No       | `false`                                       |
| `docker-image`   | Docker image reference (tag or digest) when `use-docker` is true | No       | `ghcr.io/jdfalk/release-protobuf-action:main` |

## Outputs

| Output                | Description                   |
| --------------------- | ----------------------------- |
| `generated-languages` | Languages that were generated |
| `output-path`         | Path to generated code        |

## License

MIT
