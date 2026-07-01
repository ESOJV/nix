# PLACEHOLDER — not usable as-is.
#
# On the real Framework, `sudo nixos-generate-config` will OVERWRITE this file
# with the machine's actual layout: fileSystems."/", swapDevices, boot.initrd
# kernel modules, hardware.cpu.*, etc. Until then this stub only lets the repo
# structure exist — the `framework-13` output will NOT build (no root fileSystem).
#
# Reminder for install: make swap >= 32 GB (= RAM) so hibernate works.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];
}
