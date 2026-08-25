#!/usr/bin/env python3

import argparse
import json
import os
import subprocess


def main() -> None:
    parser = argparse.ArgumentParser(description="Index cliphist entries for Astralith")
    parser.add_argument(
        "cache_dir",
        nargs="?",
        default=os.path.expanduser("~/.cache/astralith/clipboard"),
    )
    cache_dir = parser.parse_args().cache_dir
    os.makedirs(cache_dir, exist_ok=True)

    result = subprocess.run(
        ["cliphist", "list"], capture_output=True, text=True, check=False
    )
    entries = []

    for line in result.stdout.splitlines()[:120]:
        if "\t" not in line:
            continue
        entry_id, preview = line.split("\t", 1)
        is_image = "[[ binary data" in preview
        content = preview.strip()

        if is_image:
            image_path = os.path.join(cache_dir, f"{entry_id}.png")
            if not os.path.exists(image_path):
                with open(image_path, "wb") as image_file:
                    subprocess.run(
                        ["cliphist", "decode", entry_id],
                        stdout=image_file,
                        check=False,
                    )
            content = image_path

        entries.append(
            {
                "id": entry_id,
                "type": "image" if is_image else "text",
                "content": content,
                "search": "image" if is_image else content.lower(),
            }
        )

    print(json.dumps(entries, ensure_ascii=False))


if __name__ == "__main__":
    main()
