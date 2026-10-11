"""
ZoeyOS Widget Helper
Performs local state file operations for the Plasma 6 applet.
"""

import json
import os
import sys
from pathlib import Path
from datetime import date

STATE_FILE = Path.home() / ".config" / "zooey" / "state.json"

def load_state() -> dict:
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text(encoding="utf-8"))
        except Exception:
            pass
    return {
        "water_tracker": {
            "date": str(date.today()),
            "cups_logged": 0,
            "daily_goal": 8
        },
        "system": {
            "last_update_check_epoch": 0,
            "pending_updates_count": 0,
            "last_sos_timestamp": 0
        }
    }

def save_state(state: dict) -> None:
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state, indent=2), encoding="utf-8")

def add_water() -> int:
    state = load_state()
    today_str = str(date.today())
    tracker = state.setdefault("water_tracker", {})

    if tracker.get("date") != today_str:
        tracker["date"] = today_str
        tracker["cups_logged"] = 0

    tracker["cups_logged"] = tracker.get("cups_logged", 0) + 1
    save_state(state)
    return tracker["cups_logged"]

def main():
    if len(sys.argv) < 2:
        print("Usage: helper.py [add-water|get-water]")
        sys.exit(1)

    action = sys.argv[1]
    if action == "add-water":
        cups = add_water()
        print(f"Logged cup of water. Total: {cups}")
    elif action == "get-water":
        state = load_state()
        print(state.get("water_tracker", {}).get("cups_logged", 0))

if __name__ == "__main__":
    main()
