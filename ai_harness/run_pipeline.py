"""Valida el proyecto Godot headless: importa recursos y corre tests GUT.

Uso: python ai_harness/run_pipeline.py
Godot se localiza vía env GODOT_BIN o PATH (godot / godot4).
Exit 0 = todo verde. Cualquier fallo imprime el log crudo para que el
agente parsee la línea exacta del error antes de escribir código nuevo.
"""
import os
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME = os.path.join(ROOT, "game")


def find_godot() -> str:
    candidates = [os.environ.get("GODOT_BIN"), "godot", "godot4"]
    for c in candidates:
        if c and shutil.which(c):
            return shutil.which(c)
    # instalación winget sin admin (sin alias en PATH)
    import glob
    hits = glob.glob(
        os.path.expandvars(
            r"%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine*\Godot*.exe"
        )
    )
    if hits:
        return hits[0]
    sys.exit("ERROR: Godot no encontrado. Define GODOT_BIN o agrega godot al PATH.")


def run(args: list[str], step: str) -> None:
    print(f"--- {step} ---")
    result = subprocess.run(args, cwd=GAME, capture_output=True, text=True)
    output = result.stdout + result.stderr
    print(output)
    if result.returncode != 0 or "SCRIPT ERROR" in output or "Parse Error" in output:
        sys.exit(f"FALLO en paso: {step} (exit {result.returncode})")


def main() -> None:
    godot = find_godot()
    run([godot, "--headless", "--import"], "import")
    run(
        [godot, "--headless", "-s", "res://addons/gut/gut_cmdln.gd", "-gexit"],
        "tests GUT",
    )
    print("PIPELINE OK")


if __name__ == "__main__":
    main()
