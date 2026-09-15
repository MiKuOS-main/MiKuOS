#!/usr/bin/env python3
"""Apply MiKuOS patches to the calamares-nixos-extensions nixos module.

Usage: patch_main.py PATH/TO/main.py
"""
import sys

path = sys.argv[1]
with open(path) as f:
    content = f.read()

cfgcosmic = '''cfgcosmic = """  # Enable the COSMIC Desktop Environment.
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

"""
'''

marker_cfg = 'cfgkeymap = """  # Configure keymap in X11'
assert content.count(marker_cfg) == 1, "!cfgkeymap marker not unique"
content = content.replace(marker_cfg, cfgcosmic + "\n" + marker_cfg, 1)

dispatch = '''    elif gs.value("packagechooser_packagechooser") == "cosmic":
        cfg += cfgcosmic
'''
marker_disp = '    if (\n        gs.value("keyboardLayout")'
assert content.count(marker_disp) == 1, "!dispatch marker not unique"
content = content.replace(marker_disp, dispatch + marker_disp, 1)

wording = [
    ('return _("Installing NixOS.")', 'return _("Installing MiKuOS.")'),
    ('"""NixOS Configuration."""', '"""MiKuOS Configuration."""'),
    ('status = _("Configuring NixOS")', 'status = _("Configuring MiKuOS")'),
    ('status = _("Generating NixOS configuration")', 'status = _("Generating MiKuOS configuration")'),
    ('status = _("Installing NixOS")', 'status = _("Installing MiKuOS")'),
    ('# and in the NixOS manual (accessible by running \u2018nixos-help\u2019).',
     '# and in the MiKuOS manual (accessible by running \u2018nixos-help\u2019).'),
    ('(e.g. man configuration.nix or on https://nixos.org/nixos/options.html).',
     '(e.g. man configuration.nix or on https://mikuos.local/options.html).'),
]
for old, new in wording:
    assert old in content, "missing: {!r}".format(old)
    content = content.replace(old, new)

with open(path, "w") as f:
    f.write(content)

print("patched OK")