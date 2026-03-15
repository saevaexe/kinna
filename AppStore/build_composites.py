from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path("/Users/osmanseven/Kinna")
RAW_TR_DIR = ROOT / "design" / "AppStore_20260314" / "raw_tr"
COMPOSITE_TR_DIR = ROOT / "design" / "AppStore_20260314" / "composite" / "tr"

CANVAS = (1290, 2796)
SCREEN_WIDTH = 1040
SCREEN_TOP = 540
SCREEN_RADIUS = 72
SCREEN_SHADOW_OFFSET = (0, 24)
SCREEN_SHADOW_BLUR = 38

BG_TOP = (248, 242, 236)
BG_BOTTOM = (239, 231, 223)
TERRA = (196, 120, 90)
TERRA_SOFT = (224, 186, 167)
SAGE = (90, 132, 110)
SAGE_SOFT = (208, 226, 217)
INK = (47, 42, 38)
MUTED = (112, 103, 95)
WHITE = (255, 255, 255)

GEORGIA_BOLD = "/System/Library/Fonts/Supplemental/Georgia Bold.ttf"
GEORGIA_BOLD_ITALIC = "/System/Library/Fonts/Supplemental/Georgia Bold Italic.ttf"
HELVETICA = "/System/Library/Fonts/Helvetica.ttc"


@dataclass(frozen=True)
class Slide:
    key: str
    label: str
    title_lines: tuple[str, ...]
    subline: str
    raw_name: str


SLIDES: tuple[Slide, ...] = (
    Slide(
        key="01_home_tr",
        label="GÜNLÜK REHBER",
        title_lines=("Her gün sana", "*özel* rehber"),
        subline="Gelişim, aşı ve günlük rehberlik tek ekranda.",
        raw_name="01_home_tr.png",
    ),
    Slide(
        key="02_vaccination_tr",
        label="AŞI TAKİBİ",
        title_lines=("Aşı takvimi,", "*hatırlatmalarla*"),
        subline="Doğum tarihine göre planlanan dozları kolayca takip et.",
        raw_name="02_vaccination_tr.png",
    ),
    Slide(
        key="03_tracking_tr",
        label="GÜNLÜK TAKİP",
        title_lines=("Beslenme, uyku,", "büyüme *tek yerde*"),
        subline="Günlük rutini bir bakışta gör, hızlıca kaydet.",
        raw_name="03_tracking_tr.png",
    ),
    Slide(
        key="04_growth_tr",
        label="WHO REFERANSI",
        title_lines=("WHO büyüme", "*eğrileri*"),
        subline="Kilo ve boyu beklenen aralıkla birlikte gör.",
        raw_name="04_growth_tr.png",
    ),
    Slide(
        key="05_milestones_tr",
        label="GELİŞİM",
        title_lines=("Gelişim adımlarını", "*takip et*"),
        subline="Ayına uygun taşları işaretle, ilerlemeyi net gör.",
        raw_name="05_milestones_tr.png",
    ),
    Slide(
        key="06_foods_tr",
        label="EK GIDA",
        title_lines=("Yeni besinleri", "*güvenle* takip et"),
        subline="Reaksiyonları not al, iyi gelenleri kolayca gör.",
        raw_name="06_foods_tr.png",
    ),
)


def font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(path, size=size)


TITLE_FONT = font(GEORGIA_BOLD, 118)
TITLE_EM_FONT = font(GEORGIA_BOLD_ITALIC, 122)
LABEL_FONT = font(HELVETICA, 30)
KICKER_FONT = font(HELVETICA, 22)
SUBLINE_FONT = font(HELVETICA, 44)


def lerp(a: int, b: int, t: float) -> int:
    return round(a + (b - a) * t)


def vertical_gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    width, height = size
    image = Image.new("RGB", size, bottom)
    draw = ImageDraw.Draw(image)
    for y in range(height):
        t = y / max(height - 1, 1)
        color = tuple(lerp(top[i], bottom[i], t) for i in range(3))
        draw.line((0, y, width, y), fill=color)
    return image


def add_blobs(canvas: Image.Image) -> None:
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    draw.ellipse((-140, -120, 520, 420), fill=(196, 120, 90, 46))
    draw.ellipse((830, -160, 1390, 360), fill=(122, 158, 142, 42))
    draw.ellipse((720, 1180, 1500, 1940), fill=(122, 158, 142, 24))
    draw.ellipse((-220, 1880, 540, 2600), fill=(196, 120, 90, 22))
    overlay = overlay.filter(ImageFilter.GaussianBlur(54))
    canvas.alpha_composite(overlay)


def draw_pill(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], fill: tuple[int, int, int], text: str, text_fill: tuple[int, int, int], text_font: ImageFont.FreeTypeFont) -> None:
    draw.rounded_rectangle(box, radius=(box[3] - box[1]) // 2, fill=fill)
    bbox = draw.textbbox((0, 0), text, font=text_font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = box[0] + ((box[2] - box[0]) - tw) / 2
    y = box[1] + ((box[3] - box[1]) - th) / 2 - 2
    draw.text((x, y), text, font=text_font, fill=text_fill)


def parse_segments(line: str) -> list[tuple[str, bool]]:
    parts: list[tuple[str, bool]] = []
    current = []
    emphasis = False
    for char in line:
        if char == "*":
            if current:
                parts.append(("".join(current), emphasis))
                current = []
            emphasis = not emphasis
            continue
        current.append(char)
    if current:
        parts.append(("".join(current), emphasis))
    return parts


def draw_title(draw: ImageDraw.ImageDraw, x: int, y: int, lines: Iterable[str]) -> int:
    line_height = 124
    current_y = y
    for line in lines:
        current_x = x
        for segment, emph in parse_segments(line):
            text_font = TITLE_EM_FONT if emph else TITLE_FONT
            text_fill = TERRA if emph else INK
            draw.text((current_x, current_y), segment, font=text_font, fill=text_fill)
            current_x += draw.textlength(segment, font=text_font)
        current_y += line_height
    return current_y


def wrap_text(draw: ImageDraw.ImageDraw, text: str, text_font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if draw.textlength(candidate, font=text_font) <= max_width or not current:
            current = candidate
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def add_screenshot(canvas: Image.Image, screenshot_path: Path) -> None:
    shot = Image.open(screenshot_path).convert("RGB")
    scaled_height = round(shot.height * (SCREEN_WIDTH / shot.width))
    shot = shot.resize((SCREEN_WIDTH, scaled_height), Image.Resampling.LANCZOS)

    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, shot.width, shot.height), radius=SCREEN_RADIUS, fill=255)

    shot_rgba = shot.convert("RGBA")
    shot_rgba.putalpha(mask)

    x = (CANVAS[0] - SCREEN_WIDTH) // 2
    y = SCREEN_TOP

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_box = (x, y, x + SCREEN_WIDTH, y + scaled_height)
    ImageDraw.Draw(shadow).rounded_rectangle(
        (
            shadow_box[0] + SCREEN_SHADOW_OFFSET[0],
            shadow_box[1] + SCREEN_SHADOW_OFFSET[1],
            shadow_box[2] + SCREEN_SHADOW_OFFSET[0],
            shadow_box[3] + SCREEN_SHADOW_OFFSET[1],
        ),
        radius=SCREEN_RADIUS,
        fill=(76, 58, 44, 48),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(SCREEN_SHADOW_BLUR))
    canvas.alpha_composite(shadow)

    frame = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle(shadow_box, radius=SCREEN_RADIUS, fill=(255, 255, 255, 110), outline=(214, 202, 190, 150), width=3)
    canvas.alpha_composite(frame)
    canvas.alpha_composite(shot_rgba, dest=(x, y))


def render_slide(slide: Slide) -> Image.Image:
    canvas = vertical_gradient(CANVAS, BG_TOP, BG_BOTTOM).convert("RGBA")
    add_blobs(canvas)
    draw = ImageDraw.Draw(canvas)

    draw_pill(draw, (88, 118, 312, 176), fill=(255, 255, 255), text=slide.label, text_fill=(176, 110, 83), text_font=KICKER_FONT)
    draw_pill(draw, (1036, 118, 1202, 176), fill=(255, 255, 255), text="KINNA", text_fill=SAGE, text_font=KICKER_FONT)

    title_bottom = draw_title(draw, 92, 220, slide.title_lines)
    subline_lines = wrap_text(draw, slide.subline, SUBLINE_FONT, 920)
    y = title_bottom + 20
    for line in subline_lines:
        draw.text((92, y), line, font=SUBLINE_FONT, fill=MUTED)
        y += 56

    add_screenshot(canvas, RAW_TR_DIR / slide.raw_name)
    return canvas.convert("RGB")


def build_contact_sheet(images: list[Image.Image]) -> Image.Image:
    gap = 28
    thumb_width = 390
    thumbs = []
    for image in images:
        thumb_height = round(image.height * (thumb_width / image.width))
        thumbs.append(image.resize((thumb_width, thumb_height), Image.Resampling.LANCZOS))

    width = gap + (thumb_width * 3) + (gap * 2) + gap
    height = gap + (thumbs[0].height * 2) + gap + gap
    sheet = vertical_gradient((width, height), BG_TOP, BG_BOTTOM).convert("RGBA")
    add_blobs(sheet)
    for index, thumb in enumerate(thumbs):
        col = index % 3
        row = index // 3
        x = gap + col * (thumb_width + gap)
        y = gap + row * (thumb.height + gap)
        framed = Image.new("RGBA", sheet.size, (0, 0, 0, 0))
        ImageDraw.Draw(framed).rounded_rectangle((x, y, x + thumb.width, y + thumb.height), radius=26, fill=(255, 255, 255, 190))
        framed = framed.filter(ImageFilter.GaussianBlur(8))
        sheet.alpha_composite(framed)
        thumb_mask = Image.new("L", thumb.size, 0)
        ImageDraw.Draw(thumb_mask).rounded_rectangle((0, 0, thumb.width, thumb.height), radius=26, fill=255)
        thumb_rgba = thumb.convert("RGBA")
        thumb_rgba.putalpha(thumb_mask)
        sheet.alpha_composite(thumb_rgba, dest=(x, y))
    return sheet.convert("RGB")


def main() -> None:
    COMPOSITE_TR_DIR.mkdir(parents=True, exist_ok=True)
    rendered: list[Image.Image] = []
    for slide in SLIDES:
        image = render_slide(slide)
        rendered.append(image)
        image.save(COMPOSITE_TR_DIR / f"{slide.key}_composite.png", quality=95)

    build_contact_sheet(rendered).save(COMPOSITE_TR_DIR / "_contact_sheet.png", quality=95)


if __name__ == "__main__":
    main()
