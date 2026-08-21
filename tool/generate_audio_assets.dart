import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  // 1. Count 3, 2, 1 beeps (880 Hz, 350ms)
  saveWav(File('assets/audio/count_3.wav'), generateBeep(freq: 880, durationSec: 0.35, decay: 4));
  saveWav(File('assets/audio/count_2.wav'), generateBeep(freq: 880, durationSec: 0.35, decay: 4));
  saveWav(File('assets/audio/count_1.wav'), generateBeep(freq: 987, durationSec: 0.40, decay: 3.5));

  // 2. Climax GO SHOOT! Launch fanfare (1760 Hz + chord, 0.9s)
  saveWav(File('assets/audio/go_shoot.wav'), generateChord(freqs: [880, 1108, 1320, 1760], durationSec: 0.9, decay: 2.2));

  // 3. Finish Point Fanfare (Spin / Over Finish, 0.8s)
  saveWav(File('assets/audio/finish_point.wav'), generateChime(freq1: 659, freq2: 880, durationSec: 0.8));

  // 4. Finish Xtreme / Burst Fanfare (Xtreme Finish, 1.2s)
  saveWav(File('assets/audio/finish_xtreme.wav'), generateXtremeFanfare(durationSec: 1.2));

  // 5. Fault / Penalty warning buzzer (220 Hz, 0.5s)
  saveWav(File('assets/audio/fault.wav'), generateBuzzer(freq: 220, durationSec: 0.5));

  print('Audio assets generated successfully in assets/audio/!');
}

Uint8List generateBeep({required double freq, required double durationSec, required double decay}) {
  const sampleRate = 44100;
  final numSamples = (durationSec * sampleRate).toInt();
  final samples = Float64List(numSamples);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-decay * t);
    samples[i] = sin(2 * pi * freq * t) * env;
  }
  return encodePcm16(samples);
}

Uint8List generateChord({required List<double> freqs, required double durationSec, required double decay}) {
  const sampleRate = 44100;
  final numSamples = (durationSec * sampleRate).toInt();
  final samples = Float64List(numSamples);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-decay * t);
    var val = 0.0;
    for (final f in freqs) {
      val += sin(2 * pi * f * t);
    }
    samples[i] = (val / freqs.length) * env;
  }
  return encodePcm16(samples);
}

Uint8List generateChime({required double freq1, required double freq2, required double durationSec}) {
  const sampleRate = 44100;
  final numSamples = (durationSec * sampleRate).toInt();
  final halfSamples = numSamples ~/ 2;
  final samples = Float64List(numSamples);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    if (i < halfSamples) {
      final env = exp(-4.0 * t);
      samples[i] = sin(2 * pi * freq1 * t) * env;
    } else {
      final t2 = (i - halfSamples) / sampleRate;
      final env = exp(-3.0 * t2);
      samples[i] = sin(2 * pi * freq2 * t2) * env;
    }
  }
  return encodePcm16(samples);
}

Uint8List generateXtremeFanfare({required double durationSec}) {
  const sampleRate = 44100;
  final numSamples = (durationSec * sampleRate).toInt();
  final samples = Float64List(numSamples);
  final freqs = [523.25, 659.25, 783.99, 1046.50, 1318.51]; // C major energetic chord

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = (1.0 - t / durationSec) * exp(-1.5 * t);
    var val = 0.0;
    for (var fIdx = 0; fIdx < freqs.length; fIdx++) {
      final f = freqs[fIdx];
      val += sin(2 * pi * f * t + 0.3 * sin(20 * pi * t));
    }
    samples[i] = (val / freqs.length) * env;
  }
  return encodePcm16(samples);
}

Uint8List generateBuzzer({required double freq, required double durationSec}) {
  const sampleRate = 44100;
  final numSamples = (durationSec * sampleRate).toInt();
  final samples = Float64List(numSamples);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-2.0 * t);
    // Square wave approximation
    final val = sin(2 * pi * freq * t) > 0 ? 0.7 : -0.7;
    samples[i] = val * env;
  }
  return encodePcm16(samples);
}

Uint8List encodePcm16(Float64List samples) {
  const sampleRate = 44100;
  const numChannels = 1;
  const bitsPerSample = 16;
  const byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  const blockAlign = numChannels * (bitsPerSample ~/ 8);
  final dataSize = samples.length * 2;
  final totalSize = 36 + dataSize;

  final buffer = ByteData(44 + dataSize);

  // RIFF Header
  buffer.setUint8(0, 0x52); // 'R'
  buffer.setUint8(1, 0x49); // 'I'
  buffer.setUint8(2, 0x46); // 'F'
  buffer.setUint8(3, 0x46); // 'F'
  buffer.setUint32(4, totalSize, Endian.little);
  buffer.setUint8(8, 0x57);  // 'W'
  buffer.setUint8(9, 0x41);  // 'A'
  buffer.setUint8(10, 0x56); // 'V'
  buffer.setUint8(11, 0x45); // 'E'

  // fmt Subchunk
  buffer.setUint8(12, 0x66); // 'f'
  buffer.setUint8(13, 0x6D); // 'm'
  buffer.setUint8(14, 0x74); // 't'
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
  buffer.setUint16(22, numChannels, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, blockAlign, Endian.little);
  buffer.setUint16(34, bitsPerSample, Endian.little);

  // data Subchunk
  buffer.setUint8(36, 0x64); // 'd'
  buffer.setUint8(37, 0x61); // 'a'
  buffer.setUint8(38, 0x74); // 't'
  buffer.setUint8(39, 0x61); // 'a'
  buffer.setUint32(40, dataSize, Endian.little);

  // Write PCM Samples
  var offset = 44;
  for (final s in samples) {
    final clamped = s.clamp(-1.0, 1.0);
    final pcmSample = (clamped * 32767).toInt();
    buffer.setInt16(offset, pcmSample, Endian.little);
    offset += 2;
  }

  return buffer.buffer.asUint8List();
}

void saveWav(File file, Uint8List data) {
  file.writeAsBytesSync(data);
}
