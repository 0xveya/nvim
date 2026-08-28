#!/usr/bin/env bash
set -euo pipefail

repo="https://github.com/0xveya/nvim.git"
ref="master"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim-42"
coding_dir="$HOME/coding"
user42="${USER:-student}"
mail42="${USER:-student}@student.42vienna.com"
skip_clone=0

usage() {
	printf '%s\n' "usage: $0 [--repo URL] [--ref REF] [--config-dir DIR] [--coding-dir DIR]"
	printf '%s\n' "          [--user LOGIN] [--mail EMAIL] [--no-clone]"
}

while (($#)); do
	case "$1" in
		--repo) repo=$2; shift 2 ;;
		--ref) ref=$2; shift 2 ;;
		--config-dir) config_dir=$2; shift 2 ;;
		--coding-dir) coding_dir=$2; shift 2 ;;
		--user) user42=$2; shift 2 ;;
		--mail) mail42=$2; shift 2 ;;
		--no-clone) skip_clone=1; shift ;;
		-h|--help) usage; exit 0 ;;
		*) printf 'unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
	esac
done

for command in curl git python3 cc; do
	if ! command -v "$command" >/dev/null 2>&1; then
		printf 'missing required command: %s\n' "$command" >&2
		printf '%s\n' 'Ubuntu: apt-get install -y build-essential ca-certificates curl git python3' >&2
		exit 1
	fi
done

case "$(uname -m)" in
	x86_64)
		nvim_arch=x86_64
		fd_pattern='fd-v.*-x86_64-unknown-linux-gnu.tar.gz'
		rg_pattern='ripgrep-.*-x86_64-unknown-linux-musl.tar.gz'
		tree_sitter_pattern='tree-sitter-linux-x64.gz'
		uv_pattern='uv-x86_64-unknown-linux-gnu.tar.gz'
		clangd_pattern='clangd-linux-.*.zip'
		;;
	aarch64|arm64)
		nvim_arch=arm64
		fd_pattern='fd-v.*-aarch64-unknown-linux-gnu.tar.gz'
		rg_pattern='ripgrep-.*-aarch64-unknown-linux-gnu.tar.gz'
		tree_sitter_pattern='tree-sitter-linux-arm64.gz'
		uv_pattern='uv-aarch64-unknown-linux-gnu.tar.gz'
		clangd_pattern=''
		;;
	*) printf 'unsupported architecture: %s\n' "$(uname -m)" >&2; exit 1 ;;
esac

bin_dir="$HOME/.local/bin"
share_dir="$HOME/.local/share/nvim-42"
mkdir -p "$bin_dir" "$share_dir" "$coding_dir" "$(dirname "$config_dir")"

install_github_binary() {
	local project=$1 pattern=$2 binary=$3 destination=$4 release=${5:-latest}
	python3 - "$project" "$pattern" "$binary" "$destination" "$release" <<'PY'
import gzip
import io
import json
import os
import re
import stat
import sys
import tarfile
import urllib.request
import zipfile

project, pattern, binary, destination, release = sys.argv[1:]
release_path = "releases/latest" if release == "latest" else f"releases/tags/{release}"
request = urllib.request.Request(
    f"https://api.github.com/repos/{project}/{release_path}",
    headers={"Accept": "application/vnd.github+json", "User-Agent": "nvim-42-installer"},
)
with urllib.request.urlopen(request) as response:
    release = json.load(response)
asset = next((item for item in release["assets"] if re.fullmatch(pattern, item["name"])), None)
if asset is None:
    raise SystemExit(f"no {project} release asset matched {pattern}")
with urllib.request.urlopen(asset["browser_download_url"]) as response:
    data = response.read()
name = asset["name"]
if name.endswith(".tar.gz"):
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
        member = next((item for item in archive.getmembers() if os.path.basename(item.name) == binary), None)
        if member is None:
            raise SystemExit(f"{binary} missing from {name}")
        content = archive.extractfile(member).read()
elif name.endswith(".zip"):
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        member = next((item for item in archive.namelist() if os.path.basename(item) == binary), None)
        if member is None:
            raise SystemExit(f"{binary} missing from {name}")
        content = archive.read(member)
elif name.endswith(".gz"):
    content = gzip.decompress(data)
else:
    content = data
temporary = destination + ".new"
with open(temporary, "wb") as output:
    output.write(content)
os.chmod(temporary, os.stat(temporary).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
os.replace(temporary, destination)
print(f"installed {binary} from {name}")
PY
}

install_github_binary sharkdp/fd "$fd_pattern" fd "$bin_dir/fd"
install_github_binary BurntSushi/ripgrep "$rg_pattern" rg "$bin_dir/rg"
install_github_binary tree-sitter/tree-sitter "$tree_sitter_pattern" tree-sitter "$bin_dir/tree-sitter" v0.25.10
install_github_binary astral-sh/uv "$uv_pattern" uv "$bin_dir/uv"
if [[ -n "$clangd_pattern" ]]; then
	install_github_binary clangd/clangd "$clangd_pattern" clangd "$bin_dir/clangd"
elif ! command -v clangd >/dev/null 2>&1; then
	printf '%s\n' 'clangd has no standalone ARM release; install it through your distribution.' >&2
	exit 1
fi

appimage="$bin_dir/nvim.appimage"
curl --fail --location --retry 3 \
	"https://github.com/neovim/neovim-releases/releases/download/stable/nvim-linux-${nvim_arch}.appimage" \
	--output "$appimage.new"
chmod +x "$appimage.new"
mv "$appimage.new" "$appimage"
if "$appimage" --version >/dev/null 2>&1; then
	ln -sfn nvim.appimage "$bin_dir/nvim"
else
	extract_dir=$(mktemp -d)
	(
		cd "$extract_dir"
		"$appimage" --appimage-extract >/dev/null
	)
	python3 - "$share_dir/nvim-appimage" <<'PY'
import os
import shutil
import sys

path = os.path.abspath(sys.argv[1])
if not path.startswith(os.path.abspath(os.path.expanduser("~/.local/share")) + os.sep):
    raise SystemExit(f"refusing to replace unexpected path: {path}")
shutil.rmtree(path, ignore_errors=True)
PY
	mv "$extract_dir/squashfs-root" "$share_dir/nvim-appimage"
	rmdir "$extract_dir"
	ln -sfn "$share_dir/nvim-appimage/AppRun" "$bin_dir/nvim"
fi

export PATH="$bin_dir:$PATH"
uv tool install --force clang-format
{
	printf '#!/usr/bin/env bash\n'
	printf 'exec %q tool run --from norminette norminette "$@"\n' "$bin_dir/uv"
} >"$bin_dir/norminette"
chmod +x "$bin_dir/norminette"
norminette --version

if ((skip_clone == 0)); then
	if [[ -e "$config_dir" ]]; then
		printf 'config path already exists: %s\n' "$config_dir" >&2
		printf '%s\n' 'Use --config-dir with an empty destination or --no-clone for an existing checkout.' >&2
		exit 1
	fi
	git clone --depth 1 --branch "$ref" "$repo" "$config_dir"
elif [[ ! -f "$config_dir/init.lua" ]]; then
	printf 'no init.lua in --no-clone config directory: %s\n' "$config_dir" >&2
	exit 1
fi

wrapper="$bin_dir/nvim-42"
{
	printf '#!/usr/bin/env bash\n'
	printf 'export VEYA_NVIM_LITE=1\n'
	printf 'export VEYA_CODING_DIR=%q\n' "$coding_dir"
	printf 'export VEYA_42_USER=%q\n' "$user42"
	printf 'export VEYA_42_MAIL=%q\n' "$mail42"
	printf 'export NVIM_APPNAME=nvim-42\n'
	printf 'export PATH=%q:"$PATH"\n' "$bin_dir"
	printf 'exec %q "$@"\n' "$bin_dir/nvim"
} >"$wrapper"
chmod +x "$wrapper"

"$wrapper" --headless '+Lazy! sync' +qa
"$wrapper" --headless '+TSInstallSync c lua query vim vimdoc' +qa

printf '\ninstalled nvim-42\n'
printf 'add this to your shell if needed: export PATH="%s:$PATH"\n' "$bin_dir"
printf 'open a project with: nvim-42 %s\n' "$coding_dir"
