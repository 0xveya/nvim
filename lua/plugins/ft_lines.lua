return {
	"Stefanistkuhl/ft_count_lines.nvim",
	ft = "c",
	opts = {
		enable_on_start = true,
		formatter = function(count)
			local icon = "🤓"
			if count > 25 then
				icon = "⚠️"
			end
			return icon .. " " .. count
		end,
	},
}
