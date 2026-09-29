# Single source of truth for MiKuOS release identity.
#
# The version below is MiKuOS's own release number. It is deliberately
# independent of the NixOS release it is built on, which is tracked
# separately as `nixosBaseRelease` so that "what am I running" and
# "which nixpkgs is this from" stay distinguishable.
#
# `system.nixos.codeName` cannot be used for the nickname: it is a
# readOnly option in nixpkgs, pinned to upstream's own codename
# (e.g. "Yarara" for 26.05). See the consumers below.
{
  version = "1.0.0";
  codeName = "Tetu";

  # The NixOS release this MiKuOS release is built on. This is the value
  # that must be used for `system.stateVersion` / `home.stateVersion`;
  # inventing a stateVersion ahead of nixpkgs would break migrations.
  nixosBaseRelease = "26.05";
}
