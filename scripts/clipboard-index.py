#!/usr/bin/env python3

import json
import os
import subprocess
import sys


def main() -> None:
    cache_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser(
        "~/.cache/astralith/clipboard"
    )
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
