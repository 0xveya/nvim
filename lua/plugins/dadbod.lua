local databases = {
	wrapped = "duckdb:~/coding/uuhcordWrapped/data/wrapped.duckdb?access_mode=READ_ONLY",
}

local function select_database(prompt, callback)
	vim.ui.select(vim.tbl_keys(databases), { prompt = prompt }, function(choice)
		if choice then
			callback(databases[choice])
		end
	end)
end

return {
	{
		"tpope/vim-dadbod",
		dependencies = {
			"kristijanhusak/vim-dadbod-completion",
			"kristijanhusak/vim-dadbod-ui",
		},
		init = function()
			local dbs = {}
			for name, url in pairs(databases) do
				table.insert(dbs, { name = name, url = url })
			end
			vim.g.dbs = dbs
			vim.g.vim_dadbod_completion_schemas = 1
			vim.g.omni_sql_no_default_maps = 1
		end,
		keys = {
			{
				"<leader>q",
				function()
					select_database("Select database", function(url)
						vim.cmd("'<,'>DB " .. url)
					end)
				end,
				mode = "x",
			},
			{
				"<leader>db",
				function()
					select_database("Select database for completion", function(url)
						vim.b.db = url
						vim.notify("Attached database")
					end)
				end,
			},
		},
	},
}
