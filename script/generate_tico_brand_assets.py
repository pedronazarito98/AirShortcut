#!/usr/bin/env python3
"""Generate deterministic Tico brand exports from the approved raster master."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageOps


LIGHT = {
    "background": "#F8F7FC",
    "surface": "#FFFFFF",
    "primary": "#6366F1",
    "accent": "#FF6B6B",
    "text": "#111827",
}

DARK = {
    "background": "#0B1220",
    "surface": "#151E2E",
    "primary": "#7C8CFF",
    "accent": "#FF7A72",
    "text": "#F3F5FA",
}


def hex_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4))


def canonical_mask(source: Image.Image, size: int = 1024) -> Image.Image:
    source = source.convert("RGBA")
    alpha = source.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("The source symbol has no visible pixels.")

    cropped = source.crop(bbox)
    content_size = round(size * 0.70)
    scale = min(content_size / cropped.width, content_size / cropped.height)
    resized = cropped.resize(
        (round(cropped.width * scale), round(cropped.height * scale)),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    origin = ((size - resized.width) // 2, (size - resized.height) // 2)
    canvas.alpha_composite(resized, origin)
    return canvas


def classify_pixels(source: Image.Image) -> tuple[Image.Image, Image.Image, Image.Image]:
    """Return alpha masks for the primary, accent, and face regions."""
    source = source.convert("RGBA")
    primary = Image.new("L", source.size, 0)
    accent = Image.new("L", source.size, 0)
    face = Image.new("L", source.size, 0)

    source_pixels = source.load()
    primary_pixels = primary.load()
    accent_pixels = accent.load()
    face_pixels = face.load()

    for y in range(source.height):
        for x in range(source.width):
            red, green, blue, alpha = source_pixels[x, y]
            if alpha == 0:
                continue
            if red > blue * 1.15 and red > green * 1.25:
                accent_pixels[x, y] = alpha
            elif max(red, green, blue) < 125:
                face_pixels[x, y] = alpha
            else:
                primary_pixels[x, y] = alpha

    return normalize_geometry(primary, face)


def normalize_geometry(
    primary: Image.Image,
    face: Image.Image,
) -> tuple[Image.Image, Image.Image, Image.Image]:
    """Make the gesture terminals and fingertip dots optically identical."""
    width, height = primary.size
    center = width // 2
    dot_cutoff = round(height * 0.32)

    dot_mask = Image.new("L", primary.size, 0)
    dot_mask.paste(primary.crop((0, 0, center, dot_cutoff)), (0, 0))
    accent_dot = ImageOps.mirror(dot_mask)

    left_gesture = Image.new("L", primary.size, 0)
    left_gesture.paste(primary.crop((0, dot_cutoff, center + 1, height)), (0, dot_cutoff))
    right_gesture = ImageOps.mirror(left_gesture)
    gesture = ImageChops.lighter(left_gesture, right_gesture)
    normalized_primary = ImageChops.lighter(gesture, dot_mask)

    return normalized_primary, accent_dot, face


def render_symbol(
    masks: tuple[Image.Image, Image.Image, Image.Image],
    primary_color: str,
    accent_color: str,
    face_color: str,
) -> Image.Image:
    canvas = Image.new("RGBA", masks[0].size, (0, 0, 0, 0))
    for mask, color in zip(
        masks,
        (primary_color, accent_color, face_color),
        strict=True,
    ):
        layer = Image.new("RGBA", canvas.size, (*hex_rgb(color), 255))
        layer.putalpha(mask)
        canvas.alpha_composite(layer)
    return canvas


def render_monochrome(
    masks: tuple[Image.Image, Image.Image, Image.Image],
    color: str,
) -> Image.Image:
    alpha = Image.new("L", masks[0].size, 0)
    for mask in masks:
        alpha = ImageChops.lighter(alpha, mask)
    canvas = Image.new("RGBA", alpha.size, (*hex_rgb(color), 255))
    canvas.putalpha(alpha)
    return canvas


def font_with_weight(path: Path, size: int, weight: int = 600) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(str(path), size=size)
    try:
        font.set_variation_by_axes([weight])
    except (AttributeError, OSError):
        pass
    return font


def render_wordmark(
    symbol: Image.Image,
    font_path: Path,
    text_color: str,
) -> Image.Image:
    height = 360
    symbol_size = 280
    gap = 42
    font = font_with_weight(font_path, 190)
    text = "Tico"
    text_bbox = font.getbbox(text)
    text_width = text_bbox[2] - text_bbox[0]
    width = 80 + symbol_size + gap + text_width + 80
    canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    symbol_bbox = symbol.getchannel("A").getbbox()
    if symbol_bbox is None:
        raise ValueError("The canonical symbol has no visible pixels.")
    cropped_symbol = symbol.crop(symbol_bbox)
    cropped_symbol.thumbnail((symbol_size, symbol_size), Image.Resampling.LANCZOS)
    symbol_origin = (80, (height - cropped_symbol.height) // 2)
    canvas.alpha_composite(cropped_symbol, symbol_origin)

    draw = ImageDraw.Draw(canvas)
    text_x = symbol_origin[0] + cropped_symbol.width + gap
    text_y = (height - (text_bbox[3] - text_bbox[1])) // 2 - text_bbox[1]
    draw.text((text_x, text_y), text, font=font, fill=(*hex_rgb(text_color), 255))
    return canvas


def render_app_icon(symbol: Image.Image, size: int = 1024) -> Image.Image:
    canvas = Image.new("RGB", (size, size), hex_rgb(DARK["surface"]))
    bbox = symbol.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("The app icon symbol has no visible pixels.")
    cropped = symbol.crop(bbox)
    target = round(size * 0.66)
    cropped.thumbnail((target, target), Image.Resampling.LANCZOS)
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    origin = ((size - cropped.width) // 2, (size - cropped.height) // 2)
    layer.alpha_composite(cropped, origin)
    canvas = canvas.convert("RGBA")
    canvas.alpha_composite(layer)
    return canvas.convert("RGB")


def save_scaled(source: Image.Image, output: Path, size: int) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    source.resize((size, size), Image.Resampling.LANCZOS).save(output, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--font", type=Path, required=True)
    parser.add_argument("--design-dir", type=Path, required=True)
    parser.add_argument("--resources-dir", type=Path, required=True)
    args = parser.parse_args()

    canonical = canonical_mask(Image.open(args.source))
    masks = classify_pixels(canonical)

    light_symbol = render_symbol(
        masks,
        LIGHT["primary"],
        LIGHT["accent"],
        LIGHT["text"],
    )
    dark_symbol = render_symbol(
        masks,
        DARK["primary"],
        DARK["accent"],
        DARK["text"],
    )
    black_symbol = render_monochrome(masks, LIGHT["text"])
    white_symbol = render_monochrome(masks, DARK["text"])

    design = args.design_dir
    resources = args.resources_dir
    design.mkdir(parents=True, exist_ok=True)
    resources.mkdir(parents=True, exist_ok=True)

    light_symbol.save(design / "tico-symbol-light.png", optimize=True)
    dark_symbol.save(design / "tico-symbol-dark.png", optimize=True)
    black_symbol.save(design / "tico-symbol-monochrome-black.png", optimize=True)
    white_symbol.save(design / "tico-symbol-monochrome-white.png", optimize=True)

    wordmark_light = render_wordmark(light_symbol, args.font, LIGHT["text"])
    wordmark_dark = render_wordmark(dark_symbol, args.font, DARK["text"])
    wordmark_light.save(design / "tico-wordmark-light.png", optimize=True)
    wordmark_dark.save(design / "tico-wordmark-dark.png", optimize=True)

    app_icon = render_app_icon(dark_symbol)
    app_icon.save(design / "tico-app-icon-master-1024.png", optimize=True)
    app_icon.save(design / "Tico.icns", format="ICNS")

    iconset = design / "Tico.iconset"
    icon_sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }
    for filename, size in icon_sizes.items():
        save_scaled(app_icon, iconset / filename, size)

    for filename, asset in {
        "TicoSymbolLight.png": light_symbol,
        "TicoSymbolDark.png": dark_symbol,
        "TicoWordmarkLight.png": wordmark_light,
        "TicoWordmarkDark.png": wordmark_dark,
    }.items():
        asset.save(resources / filename, optimize=True)

    app_icon.save(resources / "Tico.icns", format="ICNS")
    save_scaled(black_symbol, resources / "TicoMenuBarTemplate.png", 18)
    save_scaled(black_symbol, resources / "TicoMenuBarTemplate@2x.png", 36)


if __name__ == "__main__":
    main()
