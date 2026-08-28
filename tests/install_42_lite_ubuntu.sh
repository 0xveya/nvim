#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

podman run --rm --network host \
	-v "$root:/config:ro" \
	ubuntu:22.04 \
	bash -lc '
		set -euo pipefail
		apt-get update -qq
		apt-get install -y -qq build-essential ca-certificates curl git python3
		mkdir -p /root/.config
		cp -a /config /root/.config/nvim-42
		/root/.config/nvim-42/scripts/install-42-lite.sh \
			--no-clone \
			--config-dir /root/.config/nvim-42 \
			--coding-dir /root/coding \
			--user testuser \
			--mail testuser@student.42.fr
		/root/.local/bin/nvim-42 --headless "+lua assert(require(\"profile\").lite)" +qa
		test -f /root/.local/share/nvim-42/site/parser/c.so
		test -f /root/.local/share/nvim-42/site/parser/lua.so
		/root/.local/bin/clangd --version
		/root/.local/bin/clang-format --version
		/root/.local/bin/norminette --version
	'
