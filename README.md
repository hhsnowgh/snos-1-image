# snos-1-image

The factory for [SNOS 1](https://github.com/hhsnowgh/snos-1). This repo doesn't contain SNOS itself. It assembles the bootable machine around it: a NixOS substrate (kernel, systemd, bootloader) stripped down so the floor is the only thing on screen.

```
flake.nix     pins snos-1, compiles floor.rs, builds the qcow2
machine.nix   the shipped machine: tty1 boot, tty2 repl, nothing else
```

## Download

Grab `snos-machine-1.0.qcow2.gz` from [Releases](https://github.com/hhsnowgh/snos-1-image/releases), unzip it (double-click on a Mac, or `gunzip snos-machine-1.0.qcow2.gz`), and boot the `.qcow2` in UTM / QEMU (aarch64, UEFI). Set display as gpu based. Checksums are in `SHA256SUMS` on the release.

If the hypervisor shares a directory (UTM: Share Mode VirtIO-FS, tag `share`), it becomes the gate - drag a .snos file in on the host, import it by name at the prompt.

## Build it yourself

```
nix build .#image -L
sha256sum result/snos-machine.qcow2
```

Builds for `aarch64-linux`. The `image` workflow does the same on GitHub Actions.

## License

Dual-licensed under [MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE) at your option. Name SNOS stays with the project - see [TRADEMARK.md](https://github.com/hhsnowgh/snos-1/blob/main/TRADEMARK.md).
