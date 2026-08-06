return {
	"0xveya/go-mono-repo",
	opts = {
		persist = true,
		entrypoints = {
			fallback_main_packages = true,
			include_main_packages = true,
		},
		companions = {
			auto_svelte = true,
			paths = {
				["tethux/virt"] = {
					"cmd/virt/README.md",
					"nix/modules",
					"nix/hosts",
					"scripts/container-udp-topology.go",
					"scripts/container-udp-topology.sh",
				},
				["tethux/bridge"] = {
					"cmd/bridge/README.md",
					"scripts/bridge-backend-smoke.go",
				},
			},
		},
		presets = {
			{
				label = "Tethux · multicall",
				root = "/home/veya/coding/sme",
				entry = "./cmd/tethux",
			},
			{
				label = "Tethux · virt",
				root = "/home/veya/coding/sme",
				entry = "./cmd/tethux",
				narrow = "virt",
			},
			{
				label = "Tethux · bridge",
				root = "/home/veya/coding/sme",
				entry = "./cmd/tethux",
				narrow = "bridge",
			},
			{
				label = "Tethux · CI results + Svelte viewer",
				root = "/home/veya/coding/sme",
				entry = "./tools/ci-results",
			},
		},
		keymaps = {
			pick_scope = "<leader>ngl",
			preset = "<leader>ngp",
			frontend = "<leader>ngf",
			narrow = "<leader>ngn",
			clear_narrow = "<leader>ngN",
		},
		override = {
			enabled = true,
			files = "<leader>ff",
			grep = "<leader>fg",
			symbols = "<leader>fs",
			handlers = "<leader>fh",
		},
	},
}
