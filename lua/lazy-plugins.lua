local specs = require("profile").lite and require("lite-plugins") or {
	"tpope/vim-sleuth",
	{ import = "plugins" },
}

require("lazy").setup(specs, {})
