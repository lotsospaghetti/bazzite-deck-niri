# bazzite-deck-niri &nbsp; [![bluebuild build badge](https://github.com/lotsospaghetti/bazzite-deck-niri/actions/workflows/build.yml/badge.svg)](https://github.com/lotsospaghetti/bazzite-deck-niri/actions/workflows/build.yml)

A WIP `bazzite-deck-gnome`-based image that aims to be a mostly unopinionated\* example of getting [Niri](https://github.com/niri-wm/niri) to work on PC handhelds using [Steam Input keybinds](files/system/etc/niri/steaminput-binds.kdl) and an [auto-generated scaling/transform config](files/system/usr/bin/bazzite-desktop-bootstrap) for the internal display.

\*The image comes with [Noctalia Shell](https://noctalia.dev/) as a convenient default and some of the keybinds are assigned to basic Noctalia Shell actions. If using this image as a base you can remove the `noctalia-shell` package and change the keybinds to use something else.

This repository was built using [BlueBuild](https://blue-build.org).

## Installation

First, [install a Bazzite -deck image](https://docs.bazzite.gg/General/Installation_Guide/install-guide/) (`bazzite-deck-gnome` is recommended but `bazzite-deck` may or may not also work). Then follow these steps to rebase to `bazzite-deck-niri`:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/lotsospaghetti/bazzite-deck-niri:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/lotsospaghetti/bazzite-deck-niri:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

As far as I've tested, [installing directly from an ISO doesn't seem to work](https://github.com/lotsospaghetti/bazzite-deck-niri/issues/1). You could [try it](https://blue-build.org/how-to/generate-iso/) but I highly recommend rebasing instead.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/lotsospaghetti/bazzite-deck-niri
```
