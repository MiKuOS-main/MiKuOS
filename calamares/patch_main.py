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

# Ship a MiKuOS identity module with the generated configuration so the
# installed system is branded MiKuOS, not stock NixOS.
marker_cfghead = "      ./hardware-configuration.nix\n    ];\n"
assert content.count(marker_cfghead) == 1, "!cfghead imports marker not unique"
content = content.replace(
    marker_cfghead,
    "      ./hardware-configuration.nix\n      ./mikuos.nix\n    ];\n",
    1,
)

write_mikuos = '''    # Write the MiKuOS identity module and its artwork into the target.
    mikuos_assets = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "..", "..", "..", "..",
        "share", "calamares", "mikuos-assets",
    ))
    mikuos_dir = os.path.join(root_mount_point, "etc", "nixos", "mikuos")
    if not os.path.exists(mikuos_dir):
        os.makedirs(mikuos_dir)
    subprocess.check_output(
        ["cp", "-r", os.path.join(mikuos_assets, "."), mikuos_dir + "/"]
    )
    os.rename(
        os.path.join(mikuos_dir, "mikuos.nix"),
        os.path.join(root_mount_point, "etc", "nixos", "mikuos.nix"),
    )

'''
marker_write = "    # Write the configuration.nix file"
assert content.count(marker_write) == 1, "!config-write marker not unique"
content = content.replace(marker_write, write_mikuos + marker_write, 1)
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