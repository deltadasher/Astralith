import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


class UmbraUnlockTests(unittest.TestCase):
    def setUp(self):
        self.service = (ROOT / "services" / "Umbra.qml").read_text()
        self.surface = (ROOT / "modules" / "umbra" / "UmbraSurface.qml").read_text()
        self.controller = (ROOT / "scripts" / "astralithctl").read_text()
        self.lock_entry = (ROOT / "umbra-lock.qml").read_text()

    def function_body(self, name: str) -> str:
        marker = f"    function {name}("
        start = self.service.find(marker)
        self.assertNotEqual(start, -1, f"missing Umbra.{name}()")
        next_function = self.service.find("\n    function ", start + len(marker))
        next_property = self.service.find("\n    property ", start + len(marker))
        candidates = [position for position in (next_function, next_property) if position >= 0]
        end = min(candidates) if candidates else len(self.service)
        return self.service[start:end]

    def test_pam_success_holds_lock_for_consume_animation(self):
        begin = self.function_body("beginUnlock")
        finish = self.function_body("completeUnlock")

        self.assertIn("unlocking = true", begin)
        self.assertIn("releaseDelay.restart()", begin)
        self.assertNotIn("active = false", begin)
        self.assertIn("active = false", finish)
        self.assertIn("unlocked()", finish)

    def test_surface_has_terminal_consume_state(self):
        self.assertIn("function onUnlockingChanged()", self.surface)
        self.assertIn('property: "consume"', self.surface)
        self.assertIn("Math.pow(root.consume", self.surface)

    def test_secure_process_arms_desktop_reveal_before_release(self):
        begin = self.function_body("beginUnlock")
        self.assertIn('Quickshell.execDetached([controlPath, "reveal-lock"])', begin)
        self.assertLess(begin.index('"reveal-lock"'), begin.index("releaseDelay.restart()"))

    def test_lock_entrypoint_stays_inside_project_config_root(self):
        self.assertIn('$project_root/umbra-lock.qml', self.controller)
        self.assertIn('import "modules/umbra"', self.lock_entry)
        self.assertIn("WlSessionLock", self.lock_entry)


if __name__ == "__main__":
    unittest.main()
