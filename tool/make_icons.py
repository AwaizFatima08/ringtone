"""Builds the launcher icons, the Play icon and the feature graphic from the approved homidev art.

Sources (assets/ASSET-REGISTER.md):
  assets/icons/20261126-1441-ringtone-image-01_raw.png    full-square icon → legacy launcher + Play 512
  assets/icons/20261126-1442-ringtone-icon-01_cutout.png  transparent bell → adaptive-icon foreground
  assets/images/20261126-1453-ringtone-image-01_raw.png   navy bell art → feature graphic background
  assets/images/20261126-1503-ringtone-image-0{1,2}_raw.png  couple / old man → home and loud headers

Run:  python3 tool/make_icons.py      (needs Pillow; the feature graphic title needs DejaVu Sans)
"""
import pathlib

from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
RES = ROOT / "android/app/src/main/res"
ICON = ROOT / "assets/icons/20261126-1441-ringtone-image-01_raw.png"
CUTOUT = ROOT / "assets/icons/20261126-1442-ringtone-icon-01_cutout.png"
FEATURE_ART = ROOT / "assets/images/20261126-1453-ringtone-image-01_raw.png"
# Screen headers: (source, top of the 1024×427 band, output). 2.4:1 matches a phone's width at 150 dp.
HEADERS = [
    (ROOT / "assets/images/20261126-1503-ringtone-image-01_raw.png", 160, ROOT / "assets/headers/home.jpg"),
    (ROOT / "assets/images/20261126-1503-ringtone-image-02_raw.png", 125, ROOT / "assets/headers/loud.jpg"),
]
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}

# Bell width as a share of the 108 dp foreground: keeps the waves inside the 66 dp safe circle.
FOREGROUND_WIDTH = 0.52
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def launcher_icons():
    icon = Image.open(ICON).convert("RGB")
    bell = Image.open(CUTOUT).convert("RGBA")
    bell = bell.crop(bell.getbbox())
    for name, scale in DENSITIES.items():
        folder = RES / f"mipmap-{name}"
        icon.resize((round(48 * scale),) * 2, Image.LANCZOS).save(folder / "ic_launcher.png")
        side = round(108 * scale)
        width = round(side * FOREGROUND_WIDTH)
        sized = bell.resize((width, round(width * bell.height / bell.width)), Image.LANCZOS)
        canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        canvas.alpha_composite(sized, ((side - sized.width) // 2, (side - sized.height) // 2))
        canvas.save(folder / "ic_launcher_foreground.png")
    icon.resize((512, 512), Image.LANCZOS).save(ROOT / "store/icon-512.png")
    icon.resize((512, 512), Image.LANCZOS).save(ROOT / "assets/icon/icon-512.png")
    icon.resize((192, 192), Image.LANCZOS).save(ROOT / "assets/icon/icon-192.png")


def feature_graphic():
    art = Image.open(FEATURE_ART).convert("RGB")
    # The bell sits in the lower right of the square: scale the lower part down to 500 px high and
    # put it on the right, on the art's own navy, so the title on the left stays clear of the waves.
    band = art.crop((0, 300, 1024, 1024))
    band = band.resize((round(band.width * 500 / band.height), 500), Image.LANCZOS)
    out = Image.new("RGB", (1024, 500), art.getpixel((4, 1020)))
    # Fade the left edge of the art into the plain navy, so no seam shows.
    fade = Image.linear_gradient("L").rotate(90, expand=True).resize((200, 500))
    mask = Image.new("L", band.size, 255)
    mask.paste(fade, (0, 0))
    out.paste(band, (1024 - band.width, 0), mask)
    draw = ImageDraw.Draw(out)
    draw.text((56, 150), "Easy Ringtone", font=ImageFont.truetype(FONT_BOLD, 66), fill="white")
    draw.text((60, 250), "Big buttons. Loud tones.", font=ImageFont.truetype(FONT, 32), fill="#FFB300")
    draw.text((60, 300), "Your own voice as a ringtone.", font=ImageFont.truetype(FONT, 32), fill="white")
    out.save(ROOT / "store/feature-graphic.png")


def headers():
    # Small JPEG bands are what the app bundles; the 1024² PNGs stay out of pubspec.
    for source, top, out in HEADERS:
        out.parent.mkdir(exist_ok=True)
        Image.open(source).convert("RGB").crop((0, top, 1024, top + 427)).save(out, quality=82)


if __name__ == "__main__":
    launcher_icons()
    feature_graphic()
    headers()
    print("launcher icons, store/icon-512.png, store/feature-graphic.png, assets/headers/")
