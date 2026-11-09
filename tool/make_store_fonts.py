"""Builds the fonts test_store/ needs: Roboto + Noto Naskh Arabic + a ✓ merged into one family.

The Flutter test engine has no font fallback, so Urdu text and ✓ must sit inside 'Roboto'.
Run:  python3 tool/make_store_fonts.py <out_dir>     (needs fontTools, Debian fonts-noto + fonts-dejavu)
"""
import os
import pathlib
import sys

from fontTools import subset
from fontTools.merge import Merger
from fontTools.ttLib import TTFont
from fontTools.ttLib.scaleUpem import scale_upem

ROBOTO = pathlib.Path(os.environ.get("FLUTTER_ROOT", "/mnt/storage/projects/flutter")) / "bin/cache/artifacts/material_fonts"
NOTO = pathlib.Path("/usr/share/fonts/truetype/noto")
DEJAVU = pathlib.Path("/usr/share/fonts/truetype/dejavu")
OUT = pathlib.Path(sys.argv[1])


def clean(font, path):
    """Drops tables the merger can't combine."""
    for tag in ["MATH", "STAT", "fvar", "gvar", "avar", "HVAR", "meta", "DSIG", "vhea", "vmtx"]:
        if tag in font:
            del font[tag]
    font.save(path)
    return str(path)


OUT.mkdir(parents=True, exist_ok=True)
for weight, naskh, dejavu in [("Regular", "Regular", "DejaVuSans"), ("Medium", "Regular", "DejaVuSans"),
                              ("Bold", "Bold", "DejaVuSans-Bold")]:
    urdu = TTFont(NOTO / f"NotoNaskhArabic-{naskh}.ttf")
    scale_upem(urdu, 2048)  # same units as Roboto, or the merge fails
    check = TTFont(DEJAVU / f"{dejavu}.ttf")
    sub = subset.Subsetter()
    sub.populate(unicodes=[0x2713])
    sub.subset(check)
    parts = [clean(TTFont(ROBOTO / f"Roboto-{weight}.ttf"), OUT / f"part-roboto-{weight}.ttf"),
             clean(urdu, OUT / f"part-urdu-{weight}.ttf"),
             clean(check, OUT / f"part-check-{weight}.ttf")]
    Merger().merge(parts).save(OUT / f"Roboto-{weight}.ttf")
    print(f"Roboto-{weight}.ttf")
