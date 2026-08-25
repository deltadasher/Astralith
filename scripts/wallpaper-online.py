#!/usr/bin/env python3
"""Search and download high-resolution wallpapers through DuckDuckGo Images.

The token flow is adapted from the local Serpantinum wallpaper searcher, with
bounded result counts, download sizes, and an Astralith-owned cache.
"""

from __future__ import annotations

import argparse
import hashlib
import http.cookiejar
import json
import mimetypes
import os
from pathlib import Path
import re
import sys
import urllib.error
import urllib.parse
import urllib.request


USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/124 Safari/537.36"
MAX_RESULTS = 24
MAX_DOWNLOAD = 64 * 1024 * 1024


def valid_image_bytes(data: bytes) -> bool:
    header = data[:32]
    return (
        header.startswith(b"\x89PNG\r\n\x1a\n")
        or header.startswith(b"\xff\xd8\xff")
        or header.startswith((b"GIF87a", b"GIF89a"))
        or (header.startswith(b"RIFF") and header[8:12] == b"WEBP")
        or (len(header) >= 12 and header[4:8] == b"ftyp"
            and header[8:12] in {b"avif", b"avis", b"mif1"})
    )


def cache_root() -> Path:
    return Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "astralith" / "online-wallpapers"


def opener() -> urllib.request.OpenerDirector:
    cookies = http.cookiejar.CookieJar()
    return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookies))


def request_json(client: urllib.request.OpenerDirector, url: str, referer: str) -> dict:
    request = urllib.request.Request(url, headers={
        "User-Agent": USER_AGENT,
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Referer": referer,
    })
    with client.open(request, timeout=12) as response:
        return json.loads(response.read().decode("utf-8"))


def token_for(client: urllib.request.OpenerDirector, query: str) -> tuple[str, str]:
    search_url = "https://duckduckgo.com/?" + urllib.parse.urlencode({
        "q": query,
        "iar": "images",
        "iax": "images",
        "ia": "images",
        "kp": "-1",
    })
    request = urllib.request.Request(search_url, headers={"User-Agent": USER_AGENT})
    with client.open(request, timeout=12) as response:
        html = response.read().decode("utf-8", "replace")
    match = re.search(r"vqd=([0-9a-zA-Z_-]+)", html) or re.search(
        r"vqd['\"]?\s*:\s*['\"]?([0-9a-zA-Z_-]+)", html
    )
    if not match:
        raise RuntimeError("DuckDuckGo did not return an image-search token")
    return match.group(1), search_url


def download_thumbnail(client: urllib.request.OpenerDirector, url: str, key: str) -> str:
    directory = cache_root() / "thumbs"
    directory.mkdir(parents=True, exist_ok=True)
    destination = directory / f"{key}.jpg"
    if destination.is_file() and destination.stat().st_size > 512:
        return str(destination)
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with client.open(request, timeout=8) as response:
            data = response.read(3 * 1024 * 1024)
        if len(data) > 512 and valid_image_bytes(data):
            destination.write_bytes(data)
            return str(destination)
    except (OSError, urllib.error.URLError):
        pass
    return ""


def search(raw_query: str) -> list[dict[str, object]]:
    query = raw_query.strip()
    if not query:
        return []
    full_query = query if "wallpaper" in query.lower() else query + " wallpaper"
    client = opener()
    token, referer = token_for(client, full_query)
    params = urllib.parse.urlencode({
        "l": "us-en", "o": "json", "q": full_query, "vqd": token,
        "f": ",,,", "p": "-1", "ex": "-1",
    })
    data = request_json(client, "https://duckduckgo.com/i.js?" + params, referer)
    entries: list[dict[str, object]] = []
    for result in data.get("results", []):
        if len(entries) >= MAX_RESULTS:
            break
        try:
            width, height = int(result.get("width", 0)), int(result.get("height", 0))
        except (TypeError, ValueError):
            continue
        image_url = str(result.get("image", ""))
        thumb_url = str(result.get("thumbnail", ""))
        if width < 1920 or height < 1080 or not image_url or not thumb_url:
            continue
        key = hashlib.sha1(image_url.encode()).hexdigest()[:20]
        preview = download_thumbnail(client, thumb_url, key)
        if not preview:
            continue
        title = str(result.get("title") or urllib.parse.urlparse(image_url).netloc or "Online wallpaper")
        entries.append({
            "path": "",
            "preview": preview,
            "name": title[:90],
            "kind": "image",
            "source": "Online",
            "color": "",
            "bucket": "Unsorted",
            "remoteUrl": image_url,
            "width": width,
            "height": height,
        })
    return entries


def safe_extension(content_type: str, url: str) -> str:
    guessed = mimetypes.guess_extension(content_type.split(";", 1)[0].strip()) or ""
    if guessed in {".jpg", ".jpeg", ".png", ".webp", ".gif", ".avif"}:
        return ".jpg" if guessed == ".jpe" else guessed
    suffix = Path(urllib.parse.urlparse(url).path).suffix.lower()
    return suffix if suffix in {".jpg", ".jpeg", ".png", ".webp", ".gif", ".avif"} else ".jpg"


def download(url: str) -> dict[str, object]:
    directory = Path.home() / "Pictures" / "Wallpapers"
    directory.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=20) as response:
        content_type = response.headers.get("Content-Type", "image/jpeg")
        if not content_type.lower().startswith("image/"):
            raise RuntimeError("Remote result did not return an image")
        extension = safe_extension(content_type, url)
        key = hashlib.sha1(url.encode()).hexdigest()[:18]
        destination = directory / f"astralith-{key}{extension}"
        temporary = destination.with_suffix(destination.suffix + ".part")
        written = 0
        signature = bytearray()
        try:
            with temporary.open("wb") as handle:
                while True:
                    block = response.read(128 * 1024)
                    if not block:
                        break
                    if len(signature) < 32:
                        signature.extend(block[:32 - len(signature)])
                    written += len(block)
                    if written > MAX_DOWNLOAD:
                        raise RuntimeError("Wallpaper exceeded the 64 MB download limit")
                    handle.write(block)
            if written < 1024:
                raise RuntimeError("Remote wallpaper was empty")
            if not valid_image_bytes(bytes(signature)):
                raise RuntimeError("Remote result was not a supported image")
            temporary.replace(destination)
        finally:
            temporary.unlink(missing_ok=True)
    return {"ok": True, "path": str(destination), "name": destination.name, "kind": "image"}


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    search_parser = subparsers.add_parser("search")
    search_parser.add_argument("query")
    download_parser = subparsers.add_parser("download")
    download_parser.add_argument("url")
    args = parser.parse_args()
    try:
        payload: object = search(args.query) if args.command == "search" else download(args.url)
        print(json.dumps(payload, separators=(",", ":")))
    except Exception as error:  # Network failures are surfaced to the QML status line.
        print(json.dumps({"ok": False, "error": str(error)}, separators=(",", ":")))
        raise SystemExit(1)


if __name__ == "__main__":
    main()
