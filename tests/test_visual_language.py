import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
QML_ROOTS = (ROOT / "components", ROOT / "modules")


class VisualLanguageTests(unittest.TestCase):
    def qml_files(self):
        for root in QML_ROOTS:
            yield from root.rglob("*.qml")

    def test_ui_has_no_literal_decorative_borders(self):
        # NetworkPill's concentric radio arcs are illustration, not component
        # chrome. All other UI boundaries must be expressed with filled state.
        allowed = {ROOT / "components" / "NetworkPill.qml"}
        violations = []
        pattern = re.compile(r"border\.width\s*:\s*([^;\n]+)")
        for path in self.qml_files():
            if path in allowed:
                continue
            for number, line in enumerate(path.read_text().splitlines(), 1):
                match = pattern.search(line)
                if match and match.group(1).strip() != "0":
                    violations.append(f"{path.relative_to(ROOT)}:{number}: {line.strip()}")
        self.assertEqual([], violations, "decorative QML borders returned:\n" + "\n".join(violations))

    def test_ui_text_has_a_readable_floor(self):
        violations = []
        pattern = re.compile(r"font\.pixelSize\s*:\s*([0-9]+)\b")
        for path in self.qml_files():
            for number, line in enumerate(path.read_text().splitlines(), 1):
                match = pattern.search(line)
                if match and int(match.group(1)) < 10:
                    violations.append(f"{path.relative_to(ROOT)}:{number}: {line.strip()}")
        self.assertEqual([], violations, "microtext returned:\n" + "\n".join(violations))


if __name__ == "__main__":
    unittest.main()
