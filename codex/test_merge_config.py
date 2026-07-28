import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

import tomlkit


CODEX_DIR = Path(__file__).resolve().parent
MERGE_SCRIPT = CODEX_DIR / "merge-config.py"
MANAGED_CONFIG = CODEX_DIR / "config.toml"


class MergeConfigTest(unittest.TestCase):
    def run_merge(self, target: Path) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(
            [
                sys.executable,
                str(MERGE_SCRIPT),
                str(MANAGED_CONFIG),
                str(target),
            ],
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def assert_idempotent(self, target: Path) -> None:
        contents = target.read_bytes()
        before = target.stat()

        result = self.run_merge(target)

        after = target.stat()
        self.assertEqual(result.stdout, "")
        self.assertEqual(target.read_bytes(), contents)
        self.assertEqual(after.st_ino, before.st_ino)
        self.assertEqual(after.st_mtime_ns, before.st_mtime_ns)

    def test_overwrites_existing_managed_settings(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / ".codex" / "config.toml"
            target.parent.mkdir()
            target.write_text(
                """\
# Codex-owned settings must be preserved.
model = "gpt-test"

[plugins."example@local"]
enabled = true

[projects."/work/example"]
trust_level = "trusted"

[tui]
status_line = ["model"]

[tui.keymap.composer]
submit = ["enter"]

[tui.keymap.editor]
insert_newline = ["enter"]
""",
                encoding="utf-8",
            )

            self.run_merge(target)

            merged_text = target.read_text(encoding="utf-8")
            merged = tomlkit.parse(merged_text)
            managed = tomlkit.parse(MANAGED_CONFIG.read_text(encoding="utf-8"))
            self.assertEqual(merged["tui"], managed["tui"])
            self.assertEqual(merged["model"], "gpt-test")
            self.assertTrue(merged["plugins"]["example@local"]["enabled"])
            self.assertEqual(
                merged["projects"]["/work/example"]["trust_level"], "trusted"
            )
            self.assertIn("# Codex-owned settings must be preserved.", merged_text)
            self.assert_idempotent(target)

    def test_adds_managed_settings_when_not_present(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / ".codex" / "config.toml"
            target.parent.mkdir()
            target.write_text(
                """\
model = "gpt-test"

[plugins."example@local"]
enabled = true
""",
                encoding="utf-8",
            )

            self.run_merge(target)

            merged = tomlkit.parse(target.read_text(encoding="utf-8"))
            managed = tomlkit.parse(MANAGED_CONFIG.read_text(encoding="utf-8"))
            self.assertEqual(merged["tui"], managed["tui"])
            self.assertEqual(merged["model"], "gpt-test")
            self.assertTrue(merged["plugins"]["example@local"]["enabled"])
            self.assert_idempotent(target)

    def test_creates_codex_directory_and_config(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            target = Path(temp_dir) / ".codex" / "config.toml"
            self.assertFalse(target.parent.exists())

            self.run_merge(target)

            self.assertTrue(target.is_file())
            self.assertEqual(
                target.read_text(encoding="utf-8"),
                MANAGED_CONFIG.read_text(encoding="utf-8"),
            )
            self.assertEqual(stat.S_IMODE(target.stat().st_mode), 0o600)
            self.assert_idempotent(target)


if __name__ == "__main__":
    unittest.main()
