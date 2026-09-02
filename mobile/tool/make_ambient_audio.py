"""Generates AutiMate's gentle ambient loops.

Written by hand rather than sourced from a library because the constraints
for this audience are specific and non-negotiable:

  * **No transients.** Nothing percussive, no chimes, no bells, no onsets.
    A sudden sound is exactly what a sensory-sensitive child is being
    protected from.
  * **Low-passed.** Energy is concentrated below ~1 kHz. High frequencies
    are the most commonly reported discomfort trigger.
  * **Seamlessly loopable.** The tail is crossfaded into the head so the
    loop point is inaudible; a click at the seam would be a transient.
  * **Gentle fade in and out** at the file edges, so play/stop never snaps.
  * **Headroom.** Peaks are normalised well below full scale; the service
    applies a further volume ceiling on top.

Output: mono, 22.05 kHz, 16-bit PCM WAV. Mono because these are ambient
beds, not stereo images, and it halves the asset size.

Run:  python tool/make_ambient_audio.py
"""
import math
import os
import random
import struct
import wave

RATE = 22050
SECONDS = 10
N = RATE * SECONDS
CROSSFADE = int(RATE * 1.5)   # 1.5 s seam crossfade
EDGE_FADE = int(RATE * 0.35)  # 350 ms fade at the very start/end
PEAK = 0.55                   # leave headroom; the service caps volume again

OUT = 'assets/audio'
os.makedirs(OUT, exist_ok=True)


def one_pole_lowpass(samples, cutoff_hz):
    """Simple one-pole IIR low-pass. Gentle 6 dB/octave roll-off."""
    dt = 1.0 / RATE
    rc = 1.0 / (2 * math.pi * cutoff_hz)
    alpha = dt / (rc + dt)
    out = []
    prev = 0.0
    for s in samples:
        prev = prev + alpha * (s - prev)
        out.append(prev)
    return out


def brown_noise(n, seed):
    """Integrated white noise — far softer than white, no harsh top end."""
    rng = random.Random(seed)
    out = []
    value = 0.0
    for _ in range(n):
        value += rng.uniform(-1, 1) * 0.02
        value = max(-1.0, min(1.0, value))
        value *= 0.996  # leak, so it cannot wander away from zero
        out.append(value)
    return out


def seamless(samples):
    """Crossfades the tail into the head so the loop seam is inaudible."""
    n = len(samples)
    body = samples[:n - CROSSFADE]
    head = samples[:CROSSFADE]
    tail = samples[n - CROSSFADE:]
    blended = []
    for i in range(CROSSFADE):
        t = i / CROSSFADE
        # Equal-power crossfade keeps perceived loudness constant.
        blended.append(tail[i] * math.cos(t * math.pi / 2) +
                       head[i] * math.sin(t * math.pi / 2))
    return blended + body[CROSSFADE:]


def edge_fade(samples):
    """Fades the file's own start and end, so play/stop never snaps."""
    n = len(samples)
    for i in range(min(EDGE_FADE, n)):
        g = i / EDGE_FADE
        samples[i] *= g
        samples[n - 1 - i] *= g
    return samples


def normalise(samples, peak=PEAK):
    high = max(abs(s) for s in samples) or 1.0
    return [s * (peak / high) for s in samples]


def write_wav(name, samples):
    path = os.path.join(OUT, name)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32767))
            for s in samples))
    return path, os.path.getsize(path)


def soft_rain():
    """Brown noise low-passed hard — reads as steady rain, no hiss."""
    s = brown_noise(N, seed=11)
    s = one_pole_lowpass(s, 900)
    s = one_pole_lowpass(s, 900)
    return s


def slow_ocean():
    """Rain bed under a very slow swell. The modulation is ~0.09 Hz — an
    unhurried breathing pace, and far below any flicker-equivalent rate."""
    s = brown_noise(N, seed=29)
    s = one_pole_lowpass(s, 600)
    s = one_pole_lowpass(s, 600)
    out = []
    for i, v in enumerate(s):
        # 0.09 Hz gives a whole number of cycles across the loop, so the
        # swell is continuous across the seam too.
        cycles = round(0.09 * SECONDS)
        phase = 2 * math.pi * cycles * i / N
        out.append(v * (0.55 + 0.45 * (0.5 + 0.5 * math.sin(phase))))
    return out


def warm_hum():
    """Three quiet low sines, each an exact number of cycles across the
    loop so there is no phase discontinuity at the seam."""
    partials = [(110.0, 0.5), (165.0, 0.28), (220.0, 0.16)]
    out = [0.0] * N
    for freq, amp in partials:
        cycles = round(freq * SECONDS)
        for i in range(N):
            out[i] += amp * math.sin(2 * math.pi * cycles * i / N)
    out = one_pole_lowpass(out, 700)
    # A slow tremolo keeps it from feeling static without becoming busy.
    for i in range(N):
        phase = 2 * math.pi * round(0.15 * SECONDS) * i / N
        out[i] *= 0.85 + 0.15 * math.sin(phase)
    return out


if __name__ == '__main__':
    tracks = {
        'soft_rain.wav': soft_rain,
        'slow_ocean.wav': slow_ocean,
        'warm_hum.wav': warm_hum,
    }
    for name, builder in tracks.items():
        samples = builder()
        # warm_hum is already loop-continuous by construction; crossfading
        # it would only blur the partials.
        if name != 'warm_hum.wav':
            samples = seamless(samples)
        samples = edge_fade(normalise(samples))
        path, size = write_wav(name, samples)
        print(f'  {path}  {size / 1024:.0f} KB')
