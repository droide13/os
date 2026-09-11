#!/usr/bin/env bash
# Arch Linux maintenance commands, extracted and annotated.
# Reference only — read each comment before running anything.

# ---------------------------------------------------------------------------
# 1. System update / upgrade
# ---------------------------------------------------------------------------

# Sync the package databases (-y) and upgrade every installed package (-u).
# Never use `pacman -Sy <pkg>` on its own: it updates the database without
# upgrading, which leaves you with a partial upgrade and broken libraries.
sudo pacman -Syu

# Same thing, but via the yay AUR helper: upgrades repo packages *and* the
# AUR packages you built yourself.
yay -Syu

# --- Troubleshooting: "signature is marginal trust" -------------------------

# Refreshes the set of trusted developer PGP keys. Run this, then re-run the
# full upgrade above. (Here the bare -Sy is the documented exception; follow
# it immediately with -Syu.)
sudo pacman -Sy archlinux-keyring

# ---------------------------------------------------------------------------
# 2. Clean the pacman cache
# ---------------------------------------------------------------------------

# Count how many package files are sitting in the cache.
# (`sudo` isn't needed to list it — plain `ls` works.)
ls /var/cache/pacman/pkg/ | wc -l

# Show the total disk space that cache is using, human-readable.
du -sh /var/cache/pacman/pkg/

# Install pacman-contrib, which provides the paccache tool.
sudo pacman -S pacman-contrib

# Remove old cached versions, keeping the 3 most recent of each package.
# Use `-rk1` to keep only 1, or `-dk3` for a dry run that shows what would go.
sudo paccache -r

# Downgrade / reinstall a package straight from a cached file — the reason
# you keep a few versions around in the first place.
# sudo pacman -U /var/cache/pacman/pkg/name-version.pkg.tar.gz

# ---------------------------------------------------------------------------
# 3. Orphan packages (dependencies nothing needs any more)
# ---------------------------------------------------------------------------

# List orphans: -Q query local, -d dependencies only, -t not required by
# anything, -q quiet (names only, no version numbers).
pacman -Qdtq

# Pipe that list into a removal: -R remove, -n also delete config files
# ("no save"), -s also remove now-unneeded dependencies of those packages.
# The trailing `-` tells pacman to read the package names from stdin.
# pacman -Qtdq | sudo pacman -Rns -

# Troubleshooting: "error: argument '-' specified with empty stdin" simply
# means the orphan list was empty. Nothing to do.

# ---------------------------------------------------------------------------
# 4. Review and remove unwanted packages
# ---------------------------------------------------------------------------

# List explicitly installed packages (-Qe) with full info (-i), then use awk
# to print "<size> <name>" and sort -h to order by human-readable size.
# The biggest space hogs end up at the bottom.
pacman -Qei | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h

# Same listing, but for foreign packages (-Qm) — i.e. everything from the AUR
# or installed manually rather than from the official repos.
pacman -Qim | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h

# Remove every orphan in one shot via command substitution. Equivalent to the
# pipe version above; it errors out harmlessly if there are no orphans.
sudo pacman -Rns $(pacman -Qdtq)

# Remove one specific package, its configs, and its unused dependencies.
# sudo pacman -Rns <package-name>

# ---------------------------------------------------------------------------
# 5. User cache in /home
# ---------------------------------------------------------------------------

# Check how much space your per-user cache is eating. Your own cache doesn't
# need sudo, and using it can leave root-owned files behind.
du -sh ~/.cache

# Wipe the cache contents. Safe in principle (apps regenerate it), but close
# your apps first, and note this doesn't touch dotfiles like ~/.cache/.foo
# since the glob skips hidden entries.
rm -rf ~/.cache/*

# ---------------------------------------------------------------------------
# 6. Systemd journal / logs
# ---------------------------------------------------------------------------

# Report how much disk the journal is currently consuming.
journalctl --disk-usage

# Delete journal entries older than 7 days. Alternatives: --vacuum-size=500M
# to cap total size, or --vacuum-files=N to cap the number of journal files.
sudo journalctl --vacuum-time=7d

# Make the cap permanent: edit /etc/systemd/journald.conf, uncomment and set
#     SystemMaxUse=500M
# then reload with: sudo systemctl restart systemd-journald
