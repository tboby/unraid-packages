# UnRAID Slackware Packages

Auto-maintained Slackware packages for UnRAID, compatible with [un-get](https://github.com/ich777/un-get).

## Packages

- **Atuin** - Shell history manager
- **Chezmoi** - Dotfiles manager

## Installation

Add this repository to your un-get sources:

```bash
echo "https://raw.githubusercontent.com/0xjams/unraid-packages/master/slackware64/packages 0xjams-repo" >> /boot/config/plugins/un-get/sources.list
```

Then install packages:

```bash
un-get update
un-get install atuin
```

## Repository Structure

This repository follows the Slackware standard 

## Roadmap

- Monitor upstream releases weekly to build packages via a GitHub Action

## Manual Building

To build packages manually:

```bash
cd packages/atuin
./build.sh
```
