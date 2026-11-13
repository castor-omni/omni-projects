# omni-projects

## Overview

A personal development repo for Castor Estrada at [Omni](https://omni.co). It's a working space for the things built alongside day-to-day work as a Solutions Engineer: Omni semantic model files, demo and trial tooling, and experiments. Nothing here is an official Omni product, and contents may be rough, in progress, or out of date.

## What's in here

| Path | What it is |
|---|---|
| `control-center/` | A home base for running prospect trials (POCs). Runs as a Claude artifact and pulls from connected Slack, Gmail, Calendar, Fathom and Omni. See its own [README](control-center/README.md). |
| `omni/` | Omni semantic model files (YAML) synced from Omni models: views, topics and relationships for the MotherDuck, Snowflake and modeling-exercise connections. |

## Getting Started

### Prerequisites

- Git
- An Omni account with access to the relevant models (for the files in `omni/`)
- Claude, with the connectors listed in `control-center/README.md` (for the control center)

### Installation

```bash
# clone and set up
git clone https://github.com/castor-omni/omni-projects.git
cd omni-projects
```

## Usage

- **Model files:** open the YAML under `omni/` in your editor, or sync the folder with an Omni model through its Git integration. Each folder maps to a connection or model, with `*.view.yaml`, `*.topic.yaml`, `relationships.yaml` and `model.yaml` files.
- **Control center:** follow the setup steps in [`control-center/README.md`](control-center/README.md).

## Development

- Work is committed directly to `main`; branches are only used when something needs to stay separate.
- Keep secrets out of the repo: API keys, embed secrets, `.env*` files and `.dev.vars` stay local and gitignored.
- Model files under `omni/` should be changed in Omni and synced back where possible, so the repo doesn't drift from the source of truth.
- There is no test suite. Check model changes by validating them in Omni.

## License

No license is specified. This is a personal repo, so treat its contents as all rights reserved unless a file or folder says otherwise.
