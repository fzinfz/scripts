# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "openai>=1.0",
#     "pillow>=10.0",
# ]
# ///
"""OCR images using a local OpenAI-compatible LLM server."""

from __future__ import annotations

import base64
import glob
import io
import os
import re
import sys
from pathlib import Path

from PIL import Image
from openai import OpenAI

# Local LLM server (OpenAI-compatible, e.g. LM Studio, llama.cpp-server, etc.)
BASE_URL = os.environ.get("AI_LOCAL_URL", "http://192.168.88.162:1234/v1")
API_KEY = "not-needed"
MODEL = "local"  # many local servers ignore the model name

# Supported image extensions
SUPPORTED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tif"}

OCR_PROMPT = (
    "Please extract and return all readable text from this image. "
    "Preserve the layout as much as possible. "
    "If there is no text, respond with '(no text found)'."
)

HTML_TAG_RE = re.compile(r"<\/?[a-zA-Z][^>]*>")


def has_html_tags(text: str) -> bool:
    """Return True if the text contains HTML-like tags."""
    return bool(HTML_TAG_RE.search(text))


def get_workdir() -> Path:
    """Return the working directory from OCR_WORKDIR env var."""
    return Path(os.environ.get("OCR_WORKDIR", r"G:\_images"))


def load_image_dirs() -> list[Path]:
    """Read directory list from OCR_DIR_LIST, resolve wildcards and relative paths."""
    workdir = get_workdir()
    dir_list = Path(os.environ.get("OCR_DIR_LIST", str(workdir / "OCR.TXT")))
    if not dir_list.is_absolute():
        dir_list = workdir / dir_list

    if not dir_list.exists():
        print(f"Warning: directory list not found: {dir_list}")
        return []

    dirs: list[Path] = []
    for line in dir_list.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue

        line = os.path.expandvars(line)
        path = Path(line)
        if not path.is_absolute():
            path = workdir / path

        if not glob.has_magic(str(path)):
            if path.is_dir():
                dirs.append(path)
            else:
                print(f"Warning: not a directory: {path}")
        else:
            matched = glob.glob(str(path))
            for match in matched:
                p = Path(match)
                if p.is_dir():
                    dirs.append(p)
            if not matched:
                print(f"Warning: no match for pattern: {path}")

    return sorted(set(dirs))


def get_output_dir() -> Path:
    """Return and create the OCR output directory from OCR_OUTPUT env var."""
    workdir = get_workdir()
    output_dir = Path(os.environ.get("OCR_OUTPUT", str(workdir / "OCR")))
    if not output_dir.is_absolute():
        output_dir = workdir / output_dir
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir


def encode_image_to_base64(image_path: Path) -> str:
    """Encode an image file as a base64 JPEG string for the LLM API."""
    with Image.open(image_path) as img:
        # Convert to RGB for formats that may have alpha or palette modes
        rgb_image = img.convert("RGB")
        buffer = io.BytesIO()
        rgb_image.save(buffer, format="JPEG", quality=90)
        return base64.b64encode(buffer.getvalue()).decode("utf-8")


def list_images(dirs: list[Path]) -> list[Path]:
    """Collect supported image files from the given directories."""
    images: list[Path] = []
    for directory in dirs:
        if not directory.exists() or not directory.is_dir():
            print(f"Warning: directory not found, skipping: {directory}")
            continue
        for entry in os.scandir(directory):
            if entry.is_file():
                ext = Path(entry.name).suffix.lower()
                if ext in SUPPORTED_EXTENSIONS:
                    images.append(Path(entry.path))
    return sorted(images)


def ocr_image(client: OpenAI, image_path: Path) -> str:
    """Send an image to the local LLM and return the extracted text."""
    b64_image = encode_image_to_base64(image_path)
    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": OCR_PROMPT},
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{b64_image}"},
                    },
                ],
            }
        ],
        max_tokens=4096,
        temperature=0.0,
    )
    return response.choices[0].message.content.strip() if response.choices else ""


def save_text(output_path: Path, text: str) -> None:
    """Save the OCR text to a .txt file, creating parent directories as needed."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(text, encoding="utf-8")


def main() -> int:
    client = OpenAI(base_url=BASE_URL, api_key=API_KEY)

    output_dir = get_output_dir()
    workdir = get_workdir()
    image_dirs = load_image_dirs()
    if not image_dirs:
        print("No image directories to scan.")
        return 0

    print(f"Scanning images under: {', '.join(str(d) for d in image_dirs)}")
    images = list_images(image_dirs)
    if not images:
        print("No supported images found.")
        return 0

    print(f"Found {len(images)} image(s). Output directory: {output_dir}")
    for image_path in images:
        try:
            rel = image_path.relative_to(workdir)
        except ValueError:
            rel = image_path.name
        base_output_path = output_dir / rel

        txt_path = base_output_path.with_suffix(".txt")
        html_path = base_output_path.with_suffix(".html")
        error_path = base_output_path.with_suffix(".error")
        if txt_path.exists() or html_path.exists() or error_path.exists():
            print(f"Skipped (output exists): {image_path}")
            continue

        print(f"\nProcessing: {image_path}")
        try:
            text = ocr_image(client, image_path)
            output_path = html_path if has_html_tags(text) else txt_path
            save_text(output_path, text)
            print(f"Saved: {output_path}")
        except Exception as exc:  # noqa: BLE001
            error = str(exc)
            print(f"ERROR: {error}", file=sys.stderr)
            if "cannot identify image file" in error:
                error_path.parent.mkdir(parents=True, exist_ok=True)
                error_path.touch()
                print(f"Marked: {error_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
