import os
import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FORMATTER = ROOT / "scripts" / "norm42_fix.py"


def format_source(source: str, filename: str = "test.c") -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(FORMATTER), filename],
        input=source,
        text=True,
        capture_output=True,
        check=False,
        env=os.environ.copy(),
    )


class Norm42FixTests(unittest.TestCase):
    def assert_idempotent(self, source: str, filename: str = "test.c") -> str:
        first = format_source(source, filename)
        self.assertEqual(first.returncode, 0, first.stderr)
        second = format_source(first.stdout, filename)
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(second.stdout, first.stdout)
        return first.stdout

    def test_formats_c_and_is_idempotent(self) -> None:
        formatted = self.assert_idempotent(
            "int main(void){int value=1;if(value)return(value);}\n"
        )
        self.assertIn("int\tmain(void)\n{", formatted)
        self.assertIn("\tint\tvalue;", formatted)
        self.assertIn("\tif (value)", formatted)

    def test_aligns_header_prototypes(self) -> None:
        formatted = self.assert_idempotent(
            "int short_name(void);\nunsigned long much_longer_name(int value);\n",
            "test.h",
        )
        lines = formatted.splitlines()
        name_columns = [
            lines[0].expandtabs(4).index("short_name"),
            lines[1].expandtabs(4).index("much_longer_name"),
        ]
        self.assertEqual(name_columns[0], name_columns[1])

    def test_preserves_short_and_long_gnu_attributes(self) -> None:
        source = """\
int read_value(int fd) __attribute__((warn_unused_result));
int read_a_very_long_value_from_the_current_file_descriptor(int fd, char *buffer) __attribute__((warn_unused_result));
"""
        formatted = self.assert_idempotent(source, "test.h")
        self.assertEqual(formatted.count("__attribute__((warn_unused_result))"), 2)
        self.assertIn("read_value", formatted)
        self.assertIn("read_a_very_long_value_from_the_current_file_descriptor", formatted)

    def test_rejects_cpp(self) -> None:
        result = format_source("int main() {}\n", "test.cpp")
        self.assertEqual(result.returncode, 2)
        self.assertIn("only formats C", result.stderr)

    def test_reports_missing_clang_format(self) -> None:
        env = os.environ.copy()
        env["PATH"] = ""
        result = subprocess.run(
            [sys.executable, str(FORMATTER), "test.c"],
            input="int main(void) {}\n",
            text=True,
            capture_output=True,
            check=False,
            env=env,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("could not run clang-format", result.stderr)


if __name__ == "__main__":
    unittest.main()
