#!/usr/bin/env sh
set -eu

CONFIG_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
LAZY_DIR=${NVIM_LAZY_DIR:-"$HOME/.local/share/nvim/lazy"}
PATCHES_DIR=${NVIM_PATCHES_DIR:-"$CONFIG_DIR/patches"}

usage()
{
	cat <<'USAGE'
Usage:
  apply-nvim-patches.sh
  apply-nvim-patches.sh status
  apply-nvim-patches.sh apply [plugin]

Applies patch files from this nvim config repo's patches/ directory to lazy.nvim
plugin checkouts. Patch file names must match the plugin directory name:

  patches/supermaven-nvim.patch -> ~/.local/share/nvim/lazy/supermaven-nvim

Environment overrides:
  NVIM_LAZY_DIR     lazy.nvim plugin directory
  NVIM_PATCHES_DIR  patch directory
USAGE
}

patch_target()
{
	awk '
		/^\+\+\+ / {
			sub(/^\+\+\+ b\//, "")
			sub(/^\+\+\+ /, "")
			print
			exit
		}
	' "$1"
}

first_added_line()
{
	awk '
		/^\+[^+]/ {
			sub(/^\+/, "")
			print
			exit
		}
	' "$1"
}

patch_applied()
{
	plugin_dir=$1
	patch_file=$2
	target=$(patch_target "$patch_file")
	added=$(first_added_line "$patch_file")

	[ -n "$target" ] || return 1
	[ -n "$added" ] || return 1
	[ -f "$plugin_dir/$target" ] || return 1
	grep -F -- "$added" "$plugin_dir/$target" >/dev/null 2>&1
}

status_one()
{
	patch_file=$1
	plugin=$(basename "$patch_file" .patch)
	plugin_dir=$LAZY_DIR/$plugin

	if [ ! -d "$plugin_dir" ]; then
		printf '%s: not installed at %s\n' "$plugin" "$plugin_dir"
	elif patch_applied "$plugin_dir" "$patch_file"; then
		printf '%s: applied\n' "$plugin"
	else
		printf '%s: missing\n' "$plugin"
	fi
}

apply_one()
{
	patch_file=$1
	plugin=$(basename "$patch_file" .patch)
	plugin_dir=$LAZY_DIR/$plugin

	if [ ! -d "$plugin_dir" ]; then
		printf '%s: not installed at %s\n' "$plugin" "$plugin_dir"
		return 0
	fi
	if patch_applied "$plugin_dir" "$patch_file"; then
		printf '%s: already applied\n' "$plugin"
		return 0
	fi
	if patch -p1 -d "$plugin_dir" -i "$patch_file" >/tmp/nvim-patch.$$.out 2>&1; then
		rm -f /tmp/nvim-patch.$$.out
		printf '%s: applied\n' "$plugin"
	else
		printf '%s: failed\n' "$plugin" >&2
		cat /tmp/nvim-patch.$$.out >&2
		rm -f /tmp/nvim-patch.$$.out
		return 1
	fi
}

for_each_patch()
{
	action=$1
	plugin=${2-}

	if [ -n "$plugin" ]; then
		patch_file=$PATCHES_DIR/$plugin.patch
		[ -f "$patch_file" ] || {
			printf 'no patch found for %s at %s\n' "$plugin" "$patch_file" >&2
			return 1
		}
		"$action" "$patch_file"
		return
	fi

	found=0
	for patch_file in "$PATCHES_DIR"/*.patch; do
		[ -e "$patch_file" ] || continue
		found=1
		"$action" "$patch_file"
	done
	[ "$found" -eq 1 ] || printf 'no patches found in %s\n' "$PATCHES_DIR"
}

case "${1-status}" in
status)
	for_each_patch status_one "${2-}"
	;;
apply)
	for_each_patch apply_one "${2-}"
	;;
--help|-h|help)
	usage
	;;
*)
	usage >&2
	exit 2
	;;
esac
