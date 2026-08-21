import math
import os
import struct
import wave

OUTPUT_DIR = r"d:\Proyectos\Apps\bleyblade_world\packages\bey_ui\assets\audio"
os.makedirs(OUTPUT_DIR, exist_ok=True)

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    filepath = os.path.join(OUTPUT_DIR, filename)
    with wave.open(filepath, "w") as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        
        max_amp = max(max(abs(s) for s in samples), 1e-5)
        raw_bytes = bytearray()
        for s in samples:
            norm_val = int((s / max_amp) * 32000)
            norm_val = max(-32767, min(32767, norm_val))
            raw_bytes.extend(struct.pack("<h", norm_val))
        
        wav_file.writeframes(raw_bytes)
    print(f"Generated {filepath} ({len(samples)} samples)")

def generate_countdown_beep(freq, duration=0.35, pitch_drop=False):
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 8.0) * min(1.0, t * 100)
        current_freq = freq * (1.0 - (t / duration) * 0.1) if pitch_drop else freq
        s = math.sin(2 * math.pi * current_freq * t) * 0.7
        s += math.sin(2 * math.pi * current_freq * 2 * t) * 0.25
        s += math.sin(2 * math.pi * current_freq * 3 * t) * 0.1
        samples.append(s * env)
    return samples

def generate_go_shoot(duration=0.75):
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        freq = 587.33 + (t / duration) * 880.0
        env = math.exp(-t * 3.5) * min(1.0, t * 150)
        s = math.sin(2 * math.pi * freq * t) * 0.6
        s += math.sin(2 * math.pi * (freq * 1.5) * t) * 0.25
        s += math.sin(2 * math.pi * (freq * 2.0) * t) * 0.15
        if t < 0.08:
            import random
            s += (random.random() * 2 - 1) * 0.3 * (1.0 - t / 0.08)
        samples.append(s * env)
    return samples

def generate_finish_point(duration=0.5):
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 6.0)
        if t < 0.15:
            freq = 523.25
        else:
            freq = 783.99
        s = math.sin(2 * math.pi * freq * t) * 0.7 + math.sin(2 * math.pi * freq * 2 * t) * 0.3
        samples.append(s * env)
    return samples

def generate_finish_xtreme(duration=0.8):
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    import random
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 4.0)
        if t < 0.12:
            freq = 523.25
        elif t < 0.24:
            freq = 659.25
        elif t < 0.36:
            freq = 783.99
        else:
            freq = 1046.50
        s = math.sin(2 * math.pi * freq * t) * 0.6 + math.sin(2 * math.pi * freq * 2 * t) * 0.3
        if t < 0.15:
            s += (random.random() * 2 - 1) * 0.4 * (1.0 - t / 0.15)
        samples.append(s * env)
    return samples

def generate_fault(duration=0.4):
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 5.0)
        s = math.sin(2 * math.pi * 180 * t) * 0.5 + math.sin(2 * math.pi * 230 * t) * 0.5
        samples.append(s * env)
    return samples

if __name__ == "__main__":
    write_wav("count_3.wav", generate_countdown_beep(523.25, duration=0.35))
    write_wav("count_2.wav", generate_countdown_beep(659.25, duration=0.35))
    write_wav("count_1.wav", generate_countdown_beep(783.99, duration=0.35))
    write_wav("go_shoot.wav", generate_go_shoot(duration=0.8))
    write_wav("finish_point.wav", generate_finish_point(duration=0.5))
    write_wav("finish_xtreme.wav", generate_finish_xtreme(duration=0.85))
    write_wav("fault.wav", generate_fault(duration=0.4))
