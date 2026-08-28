import re
import subprocess
import sys
import tempfile
from pathlib import Path


def clang_format(source, filename):
    style = Path(__file__).with_name("norm42.clang-format")
    command = [
        "clang-format",
        f"--style=file:{style}",
        f"--assume-filename={filename}",
    ]
    try:
        result = subprocess.run(
            command,
            input=source,
            text=True,
            capture_output=True,
            check=False,
        )
    except OSError as error:
        raise RuntimeError(f"could not run clang-format: {error}") from error
    if result.returncode != 0:
        detail = result.stderr.strip() or f"exit status {result.returncode}"
        raise RuntimeError(f"clang-format failed: {detail}")
    return result.stdout


def is_norm_compliant(source, filename):
    try:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / Path(filename).name
            path.write_text(source)
            result = subprocess.run(
                ["uv", "tool", "run", "norminette", "--no-colors", str(path)],
                capture_output=True,
                check=False,
            )
    except OSError:
        return False
    return result.returncode == 0


if len(sys.argv) != 2:
    sys.stderr.write("usage: norm42_fix.py FILE.c|FILE.h\n")
    raise SystemExit(2)

filename = sys.argv[1]
if not filename.endswith((".c", ".h")):
    sys.stderr.write("norm42_fix.py only formats C source and headers\n")
    raise SystemExit(2)
is_header = filename.endswith(".h")
source = sys.stdin.read()
if is_norm_compliant(source, filename):
    sys.stdout.write(source)
    raise SystemExit(0)
try:
    src = clang_format(source, filename)
except RuntimeError as error:
    sys.stderr.write(f"norm42_fix.py: {error}\n")
    raise SystemExit(1) from error
had_newline = src.endswith("\n")
lines = src.splitlines()

if is_header:
    for i, line in enumerate(lines):
        lines[i] = re.sub(r"^#(define|include)\b", r"# \1", line)
        lines[i] = re.sub(r"^} +(?=[A-Za-z_])", "}\t", lines[i])


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
            r'|pid_t'
            r'|u?int(?:8|16|32|64)_t'
            r'|t_[A-Za-z0-9_]+'
            r'|struct\s+[A-Za-z0-9_]+'
            r'|unsigned(?:\s+(?:char|short|int|long))?'
            r'|signed(?:\s+(?:char|short|int|long))?'
        r')'
    r')'
    r'[ \t]+'
    r'(?P<ptr>\**)[ \t]*'
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
        r'|pid_t'
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


# Put tabs between return types and function names. Header prototypes share
# one alignment column; C definitions require exactly one separating tab.
header_func_width = 0

if is_header:
    for line in lines:
        match = FUNC_START.match(line)

        if match:
            header_func_width = max(
                header_func_width,
                width(line[:match.start("name")]),
            )

for i, line in enumerate(lines):
    if not line or line[0].isspace():
        continue

    m = FUNC_START.match(line)
    if not m:
        continue

    name_tabs = "\t"

    if is_header:
        prefix = m.group("rtype")
        name_tabs = ""

        while width(prefix + name_tabs) < header_func_width:
            name_tabs += "\t"
    elif m.group("rtype") == "static void":
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
            if is_header:
                second = "\t" * (header_func_width // 4 + 1) + last + suffix
            else:
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
                    if is_header:
                        lines[j] = "\t" * (header_func_width // 4 + 1) + stripped
                    else:
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


HEADER_MEMBER = re.compile(
    r"^\t"
    r"(?P<type>(?:struct\s+)?(?:enum\s+)?[A-Za-z_][A-Za-z0-9_]*)"
    r"[ \t]+"
    r"(?P<ptr>\**)(?P<name>[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<rest>.*;)$"
)

if is_header:
    i = 0
    while i < len(lines):
        if not lines[i].startswith("typedef struct "):
            i += 1
            continue
        start = i + 2
        end = start
        members = []
        while end < len(lines):
            match = HEADER_MEMBER.match(lines[end])
            if not match:
                break
            members.append(match)
            end += 1
        if members:
            target = max(width("\t" + match.group("type")) for match in members)
            target = (target // 4 + 1) * 4
            for offset, match in enumerate(members):
                prefix = "\t" + match.group("type")
                while width(prefix) < target:
                    prefix += "\t"
                lines[start + offset] = (
                    prefix
                    + match.group("ptr")
                    + match.group("name")
                    + match.group("rest")
                )
        i = max(end, i + 1)


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
            if is_header:
                second = "\t" * (header_func_width // 4 + 1) + last + " " + attr
            else:
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
            if is_header:
                out.append("\t" * (header_func_width // 4 + 1) + last)
            else:
                out.append("\t\t\t\t\t\t" + last)
            i += 3
            continue

    out.append(lines[i])
    i += 1

lines = out


# Do NOT convert arbitrary leading spaces into tabs here.
# clang-format with UseTab: ForIndentation already emits real tabs for block
# indentation. Extra leading spaces on continuation lines are alignment, and
# converting those spaces to tabs produces Norminette TOO_MANY_TAB /
# MIXED_SPACE_TAB errors.


def leading_tabs(line):
    return len(line) - len(line.lstrip("\t"))


for i in range(1, len(lines)):
    stripped = lines[i].lstrip()
    previous = lines[i - 1]

    if stripped.startswith(("&&", "||")):
        lines[i] = "\t" * (leading_tabs(previous) + 1) + stripped
    elif previous.rstrip().endswith("("):
        lines[i] = "\t" * (leading_tabs(previous) + 2) + stripped


# Calls on the right side of an assignment need two continuation levels in
# addition to their block indentation.
i = 0

while i < len(lines):
    if re.search(r'=\s*[A-Za-z_][A-Za-z0-9_]*\([^)]*$', lines[i]):
        depth = lines[i].count("(") - lines[i].count(")")
        base_tabs = len(lines[i]) - len(lines[i].lstrip("\t"))
        j = i + 1

        while j < len(lines) and depth > 0:
            lines[j] = "\t" * (base_tabs + 2) + lines[j].lstrip()
            depth += lines[j].count("(") - lines[j].count(")")
            j += 1

        i = j
        continue

    i += 1


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
            r'|pid_t'
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
    if is_header or i + 1 >= len(lines) or not FUNC_START.match(lines[i]):
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
        r'(?:static\s+)?'
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
            r'|pid_t'
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
        is_header
        or not lines[i].startswith("\t")
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


# Norminette wants a space after C keywords such as if/while/return.
# Do this anywhere in the code line so constructs like `else if(` are fixed too.
for i, line in enumerate(lines):
    lines[i] = re.sub(
        r'(?<![A-Za-z0-9_])(?P<kw>if|while|switch|return)\(',
        r'\g<kw> (',
        line,
    )
    # Norminette requires a space after bare statement keywords too:
    #     return;    -> return ;
    #     break;     -> break ;
    #     continue;  -> continue ;
    lines[i] = re.sub(
        r'(?<![A-Za-z0-9_])(?P<kw>return|break|continue);',
        r'\g<kw> ;',
        lines[i],
    )


# Move && / || off end-of-line onto the following continuation line.
i = 0
while i + 1 < len(lines):
    m = re.search(r'\s+(&&|\|\|)\s*$', lines[i])

    if m and lines[i + 1].strip():
        op = m.group(1)
        lines[i] = lines[i][:m.start()].rstrip()
        nxt = lines[i + 1]
        indent = nxt[:len(nxt) - len(nxt.lstrip())]
        body = nxt.lstrip()
        lines[i + 1] = indent + op + " " + body

    i += 1


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


# Align the signal state declaration used by 42 projects.
for i, line in enumerate(lines):
    lines[i] = re.sub(
        r'^(volatile\s+sig_atomic_t)[ \t]+',
        r'\1\t',
        line,
    )


formatted = "\n".join(lines) + ("\n" if had_newline else "")
if not is_norm_compliant(formatted, filename):
    formatted = source
sys.stdout.write(formatted)
