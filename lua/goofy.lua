local M = {}

local project_metadata = {
	[".devcontainer"] = true,
	[".dockerignore"] = true,
	[".editorconfig"] = true,
	[".forgejo"] = true,
	[".gitattributes"] = true,
	[".github"] = true,
	[".gitignore"] = true,
	[".gitlab-ci.yml"] = true,
	[".gitmodules"] = true,
	[".golangci.yml"] = true,
	[".goreleaser.yaml"] = true,
	[".goreleaser.yml"] = true,
	[".prettierignore"] = true,
	[".woodpecker"] = true,
	[".woodpecker.yml"] = true,
}

function M.is_project_metadata(name)
	return project_metadata[name] == true
end

function M.find(path)
	return vim.fs.find(".goofy", { path = path, upward = true })[1]
end

function M.args(path)
	local file = M.find(path)
	return file and { "--ignore-file", file } or {}
end

return M
