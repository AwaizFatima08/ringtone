"""Makes the app's loud tones (assets/tones/*.ogg). Original HomiLabs sounds, synthesised here, no samples.

Low pitches (about 400-1200 Hz) because age-related hearing loss takes the high notes first; strong
harmonics and heavy, clean compression so they sound loud at any volume; repeated so a call is not missed.

Run:  python3 tool/make_tones.py     (needs numpy and ffmpeg)
"""
import pathlib
import subprocess
import tempfile
import wave

import numpy as np

RATE = 44100
OUT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "tones"


def t(seconds):
    return np.arange(int(RATE * seconds)) / RATE


def env(n, attack=0.005, release=0.03):
    """Short fade in/out so no click."""
    e = np.ones(n)
    a, r = int(RATE * attack), int(RATE * release)
    e[:a] = np.linspace(0, 1, a)
    e[-r:] = np.linspace(1, 0, r)
    return e


def rich(freq, seconds, harmonics=(1, 0.5, 0.3, 0.15)):
    """A tone with a few harmonics: much easier to hear than a pure sine."""
    x = t(seconds)
    s = sum(a * np.sin(2 * np.pi * freq * (i + 1) * x) for i, a in enumerate(harmonics))
    return s * env(len(x))


def silence(seconds):
    return np.zeros(int(RATE * seconds))


def decay(sig, rate):
    return sig * np.exp(-rate * t(len(sig) / RATE))


def bell():
    """Two-tone ringing like an old desk phone: 20 Hz tremolo, ring-ring, pause."""
    x = t(0.4)
    tremolo = 0.5 + 0.5 * np.sign(np.sin(2 * np.pi * 20 * x))
    burst = (rich(800, 0.4) + 0.7 * rich(1000, 0.4)) * tremolo * env(len(x))
    ring = np.concatenate([burst, silence(0.2), burst])
    return np.concatenate([ring, silence(1.2)] * 4)


def deep_beep():
    beep = rich(520, 0.35, (1, 0.7, 0.5, 0.3, 0.2))
    group = np.concatenate([beep, silence(0.15)] * 3)
    return np.concatenate([group, silence(0.9)] * 5)


def warm_chime():
    notes = [784, 659, 523]  # G5 E5 C5, falling
    hit = [decay(rich(f, 0.7, (1, 0.4, 0.25, 0.1)), 4) for f in notes]
    phrase = np.concatenate([np.concatenate([h, silence(0.05)]) for h in hit])
    return np.concatenate([phrase, silence(0.8)] * 4)


def strong_pulse():
    pulse = rich(950, 0.12, (1, 0.6, 0.4, 0.3))
    fast = np.concatenate([pulse, silence(0.08)] * 4)
    return np.concatenate([fast, silence(0.5)] * 10)


def double_tone():
    a = rich(700, 0.25, (1, 0.6, 0.4, 0.2))
    b = rich(900, 0.35, (1, 0.6, 0.4, 0.2))
    return np.concatenate([a, silence(0.06), b, silence(0.4), a, silence(0.06), b])


def knock():
    # Low thud with a short click on top: like knocking on a wooden door.
    thud = decay(rich(320, 0.18, (1, 0.8, 0.5, 0.4, 0.3)), 18)
    noise = decay(np.random.default_rng(7).normal(0, 0.6, len(thud)), 60)
    hit = thud + noise
    return np.concatenate([hit, silence(0.12), hit, silence(0.12), hit])


def loud(sig):
    """Even loudness without harsh clipping: soft limiter, then peak at -0.5 dBFS."""
    sig = sig / np.max(np.abs(sig))
    sig = np.tanh(2.2 * sig) / np.tanh(2.2)
    return sig * 10 ** (-0.5 / 20)


def write_ogg(name, sig):
    OUT.mkdir(parents=True, exist_ok=True)
    pcm = (loud(sig) * 32767).astype(np.int16)
    with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
        with wave.open(tmp.name, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(pcm.tobytes())
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", tmp.name, "-c:a", "libvorbis", "-q:a", "5",
             "-map_metadata", "-1", "-metadata", f"title={name}", str(OUT / f"{name}.ogg")],
            check=True,
        )
    print(f"{name}.ogg  {len(sig) / RATE:.1f} s")


if __name__ == "__main__":
    for name, fn in [
        ("loud_bell", bell),
        ("loud_deep_beep", deep_beep),
        ("loud_warm_chime", warm_chime),
        ("loud_strong_pulse", strong_pulse),
        ("loud_double_tone", double_tone),
        ("loud_knock", knock),
    ]:
        write_ogg(name, fn())
