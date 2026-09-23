# YAMS: Yet Another Media Server

A simple Docker-based *arr media stack installer and guide for self-hosted home media.

- Website: https://yams.media
- Docs: https://yams.media
- Discord: https://discord.gg/Gwae3tNMST

## What this repo contains

- `src/` — installer scripts and Docker Compose templates
- `docs/` — Hugo-based website and documentation content
- `tests/` — automated validation for the installer and CLI

## Quick links

- [Contributing guide](./CONTRIBUTING.md)
- [Code of conduct](./CODE_OF_CONDUCT.md)
- [Project todo list](./TODO.md)

## Local development

If you are working on the docs site:

```bash
cd docs
hugo server
```

If you are validating the installer or CLI behavior:

```bash
tests/run
```

Docker is required for the automated test workflow.

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

