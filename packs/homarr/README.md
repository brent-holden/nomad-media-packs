# Homarr

This pack deploys [Homarr](https://homarr.dev/), a modern and sleek dashboard for your homelab.

## Requirements

- A host volume named `homarr-config` for persistent configuration
- (Optional) A CSI volume named `backup-drive` for backups

## Default Port

Homarr runs on port `7575` by default.

## Variables

See `variables.hcl` for all available configuration options.

## Usage

```bash
nomad-pack run packs/homarr
```
