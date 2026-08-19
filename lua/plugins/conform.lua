local function in_42_dir(bufnr)
	local lazy = require("lazy.core.config")
	local plugin = lazy.plugins["dogshitnorm.nvim"]
	local dirs = plugin and plugin.opts and plugin.opts.active_dirs or {}
	local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))

	for _, dir in ipairs(dirs) do
		dir = vim.fs.normalize(vim.fn.expand(dir))
		if vim.startswith(path, dir) then
			return true
		end
	end
	return false
end

local prettier = vim.fn.resolve(vim.fn.exepath("prettier"))
local prettier_root = prettier ~= "" and vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(prettier))) or nil

local astro_plugin = prettier_root and vim.fs.joinpath(prettier_root, "prettier-plugin-astro", "dist", "index.js")
	or "prettier-plugin-astro"

return {
	{
		"stevearc/conform.nvim",

		opts = {
			notify_on_error = false,

			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},

			formatters_by_ft = {
				lua = { "stylua" },

				astro = { "prettier_astro" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },

				python = function(bufnr)
					if in_42_dir(bufnr) then
						return { "ruff_format_42" }
					end
					return { "ruff_format" }
				end,

				c = function(bufnr)
					if in_42_dir(bufnr) then
						if vim.api.nvim_buf_get_name(bufnr):sub(-2) == ".h" then
							return { "c_formatter_42" }
						end
						return {
							"clang-format",
							"norm42_fix",
						}
					end
					return { "clang-format" }
				end,

				cpp = function(bufnr)
					if in_42_dir(bufnr) and vim.api.nvim_buf_get_name(bufnr):sub(-2) == ".h" then
						return { "c_formatter_42" }
					end
					return { "clang-format" }
				end,

				go = { "goimports" },
				powershell = { "ps_formatter" },
				sql = { "sleek" },
			},

			formatters = {
				c_formatter_42 = {
					command = "c_formatter_42",
					stdin = true,
				},
				norm42_fix = {
					command = "python3",
					args = {
						"-c",
						[[
import re
import sys

src = sys.stdin.read()
had_newline = src.endswith("\n")
lines = src.splitlines()


def width(line):
    return len(line.expandtabs(4))


FUNC_START = re.compile(
    r'^'
    r'(?P<rtype>'
        r'(?:static\s+)?'
        r'(?:inline\s+)?'
        r'(?:const\s+)?'
        r'(?:'
            r'void'
            r'|char'
            r'|short'
            r'|int'
            r'|long'
            r'|float'
            r'|double'
            r'|size_t'
            r'|ssize_t'
            r'|u?int(?:8|16|32|64)_t'
            r'|t_[A-Za-z0-9_]+'
            r'|struct\s+[A-Za-z0-9_]+'
            r'|unsigned(?:\s+(?:char|short|int|long))?'
            r'|signed(?:\s+(?:char|short|int|long))?'
        r')'
    r')'
    r'[ \t]+'
    r'(?P<ptr>\**)'
    r'(?P<name>[A-Za-z_][A-Za-z0-9_]*)'
    r'(?P<rest>\s*\(.*)$'
)


RETURN_ONLY = re.compile(
    r'^'
    r'(?:static\s+)?'
    r'(?:inline\s+)?'
    r'(?:const\s+)?'
    r'(?:'
        r'void'
        r'|char'
        r'|short'
        r'|int'
        r'|long'
        r'|float'
        r'|double'
        r'|size_t'
        r'|ssize_t'
        r'|u?int(?:8|16|32|64)_t'
        r'|t_[A-Za-z0-9_]+'
        r'|struct\s+[A-Za-z0-9_]+'
        r'|unsigned(?:\s+(?:char|short|int|long))?'
        r'|signed(?:\s+(?:char|short|int|long))?'
    r')'
    r'\s*\**\s*$'
)

FUNC_NAME_ONLY = re.compile(
    r'^[A-Za-z_][A-Za-z0-9_]*\s*\('
)


# Join split return type + function name.
out = []
i = 0

while i < len(lines):
    if (
        i + 1 < len(lines)
        and RETURN_ONLY.match(lines[i])
        and FUNC_NAME_ONLY.match(lines[i + 1])
    ):
        out.append(
            lines[i].rstrip()
            + " "
            + lines[i + 1].lstrip()
        )
        i += 2
        continue

    out.append(lines[i])
    i += 1

lines = out


# Put tabs between return types and function names.
for i, line in enumerate(lines):
    if not line or line[0].isspace():
        continue

    m = FUNC_START.match(line)
    if not m:
        continue

    name_tabs = "\t"

    if m.group("rtype") == "static void":
        j = i

        while j < len(lines) and "{" not in lines[j] and ";" not in lines[j]:
            j += 1

        if j < len(lines) and ";" in lines[j]:
            name_tabs = "\t\t"

    lines[i] = (
        m.group("rtype")
        + name_tabs
        + m.group("ptr")
        + m.group("name")
        + m.group("rest")
    )


# Split long single-line function signatures before final parameter.
out = []

for line in lines:
    if (
        line
        and not line[0].isspace()
        and FUNC_START.match(line)
        and width(line) > 75
        and "," in line
        and ")" in line
    ):
        close = line.rfind(")")
        before_close = line[:close]
        suffix = line[close:]
        split = before_close.rfind(",")

        if split != -1:
            first = before_close[:split + 1]
            last = before_close[split + 1:].strip()
            second = "\t\t\t\t\t\t" + last + suffix

            if width(first) <= 80 and width(second) <= 80:
                out.append(first)
                out.append(second)
                continue

    out.append(line)

lines = out


# Fix multiline function/prototype parameter indentation.
i = 0

while i < len(lines):
    line = lines[i]

    if (
        line
        and not line[0].isspace()
        and FUNC_START.match(line)
    ):
        depth = line.count("(") - line.count(")")

        if depth > 0:
            j = i + 1

            while j < len(lines) and depth > 0:
                stripped = lines[j].lstrip()

                if stripped:
                    lines[j] = "\t\t\t\t\t\t" + stripped

                depth += lines[j].count("(")
                depth -= lines[j].count(")")
                j += 1

            i = j
            continue

    i += 1


# Attach GCC attributes to the previous line when it fits.
out = []
i = 0

while i < len(lines):
    if (
        i + 1 < len(lines)
        and lines[i + 1].lstrip().startswith("__attribute__(")
    ):
        combined = (
            lines[i].rstrip()
            + " "
            + lines[i + 1].strip()
        )

        if width(combined) <= 80:
            out.append(combined)
            i += 2
            continue

    out.append(lines[i])
    i += 1

lines = out


# If attribute attachment is too long, split before final parameter.
out = []
i = 0

while i < len(lines):
    if (
        i + 1 < len(lines)
        and lines[i + 1].lstrip().startswith("__attribute__(")
        and "," in lines[i]
        and ")" in lines[i]
    ):
        line = lines[i]
        attr = lines[i + 1].strip()
        split = line.rfind(",")

        if split != -1:
            first = line[:split + 1]
            last = line[split + 1:].strip()
            second = "\t\t\t\t\t\t" + last + " " + attr

            if width(first) <= 80 and width(second) <= 80:
                out.append(first)
                out.append(second)
                i += 2
                continue

    out.append(lines[i])
    i += 1

lines = out


# If clang-format already produced three lines for an attributed prototype,
# collapse the middle parameter upward when possible.
out = []
i = 0

while i < len(lines):
    if (
        i + 2 < len(lines)
        and FUNC_START.match(lines[i])
        and "__attribute__(" in lines[i + 2]
        and "," in lines[i]
    ):
        first = lines[i]
        middle = lines[i + 1].strip()
        last = lines[i + 2].strip()

        candidate = first.rstrip() + " " + middle

        if width(candidate) <= 80:
            out.append(candidate)
            out.append("\t\t\t\t\t\t" + last)
            i += 3
            continue

    out.append(lines[i])
    i += 1

lines = out


# Split initialized top-level locals and declare them at function start.
INITIALIZED_LOCAL = re.compile(
    r'^\t'
    r'(?P<type>'
        r'(?:const\s+)?'
        r'(?:'
            r'void'
            r'|char'
            r'|short'
            r'|int'
            r'|long'
            r'|float'
            r'|double'
            r'|size_t'
            r'|ssize_t'
            r'|u?int(?:8|16|32|64)_t'
            r'|__m(?:64|128|256|512)i'
            r'|__m(?:128|256|512)'
            r'|t_[A-Za-z0-9_]+'
            r'|struct\s+[A-Za-z0-9_]+'
            r'|unsigned(?:\s+(?:char|short|int|long))?'
            r'|signed(?:\s+(?:char|short|int|long))?'
        r')'
    r')'
    r'[ \t]+'
    r'(?P<ptr>\**)'
    r'(?P<name>[A-Za-z_][A-Za-z0-9_]*)'
    r'\s*=\s*'
    r'(?P<value>.+);$'
)

out = []
i = 0

while i < len(lines):
    if i + 1 >= len(lines) or not FUNC_START.match(lines[i]):
        out.append(lines[i])
        i += 1
        continue

    brace = i + 1

    while brace < len(lines) and lines[brace] != "{":
        if ";" in lines[brace] or not lines[brace]:
            break
        brace += 1

    if brace == len(lines) or lines[brace] != "{":
        out.append(lines[i])
        i += 1
        continue

    end = brace + 1
    block_depth = 1

    while end < len(lines) and block_depth > 0:
        block_depth += lines[end].count("{")
        block_depth -= lines[end].count("}")

        if block_depth > 0:
            end += 1

    if end == len(lines):
        out.append(lines[i])
        i += 1
        continue

    body = lines[brace + 1:end]
    declarations = []

    for j, body_line in enumerate(body):
        match = INITIALIZED_LOCAL.match(body_line)

        if not match:
            continue

        declarations.append(
            "\t"
            + match.group("type")
            + "\t"
            + match.group("ptr")
            + match.group("name")
            + ";"
        )
        body[j] = (
            "\t"
            + match.group("name")
            + " = "
            + match.group("value")
            + ";"
        )

    out.extend(lines[i:brace + 1])

    if declarations:
        out.extend(declarations)
        out.append("")

    out.extend(body)
    out.append(lines[end])
    i = end + 1

lines = out


# Align top-level local declaration blocks.
LOCAL_DECL = re.compile(
    r'^\t'
    r'(?P<type>'
        r'(?:const\s+)?'
        r'(?:'
            r'void'
            r'|char'
            r'|short'
            r'|int'
            r'|long'
            r'|float'
            r'|double'
            r'|size_t'
            r'|ssize_t'
            r'|u?int(?:8|16|32|64)_t'
            r'|__m(?:64|128|256|512)i'
            r'|__m(?:128|256|512)'
            r'|t_[A-Za-z0-9_]+'
            r'|struct\s+[A-Za-z0-9_]+'
            r'|unsigned(?:\s+(?:char|short|int|long))?'
            r'|signed(?:\s+(?:char|short|int|long))?'
        r')'
    r')'
    r'[ \t]+'
    r'(?P<ptr>\**)'
    r'(?P<name>[A-Za-z_][A-Za-z0-9_]*)'
    r'(?P<rest>\s*(?:;|=|\[).*)$'
)


def decl_prefix_width(type_name):
    return width("\t" + type_name)


i = 0

while i < len(lines):
    if (
        not lines[i].startswith("\t")
        or lines[i].startswith("\t\t")
        or not LOCAL_DECL.match(lines[i])
    ):
        i += 1
        continue

    start = i
    decls = []

    while i < len(lines):
        if (
            not lines[i].startswith("\t")
            or lines[i].startswith("\t\t")
        ):
            break

        m = LOCAL_DECL.match(lines[i])

        if not m:
            break

        decls.append(m)
        i += 1

    max_type = max(
        decl_prefix_width(m.group("type"))
        for m in decls
    )
    target = ((max_type // 4) + 1) * 4

    for off, m in enumerate(decls):
        prefix = "\t" + m.group("type")

        while width(prefix) < target:
            prefix += "\t"

        lines[start + off] = (
            prefix
            + m.group("ptr")
            + m.group("name")
            + m.group("rest")
        )


# Concatenated string literals.
in_return_string = False

for i, line in enumerate(lines):
    stripped = line.lstrip()

    if re.match(r'^\treturn\s*\(\s*"', line):
        in_return_string = True
        continue

    if in_return_string:
        if stripped.startswith('"'):
            lines[i] = "\t\t" + stripped

        if stripped.endswith(');'):
            in_return_string = False


# Ensure a space before GCC attributes.
for i, line in enumerate(lines):
    lines[i] = re.sub(
        r'\)(?=__attribute__)',
        r') ',
        line,
    )


sys.stdout.write(
    "\n".join(lines)
    + ("\n" if had_newline else "")
)
	]],
					},
					stdin = true,
				},
			},
		},

		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
}
