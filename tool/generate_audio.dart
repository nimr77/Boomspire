// Synthesizes all game sound effects as WAV files at build time.
// No external/licensed audio - everything here is generated DSP, royalty-free.
// Run with: dart run tool/generate_audio.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const sampleRate = 44100;

List<double> silence(double seconds) =>
    List.filled((seconds * sampleRate).round(), 0.0);

/// Oscillator with linear frequency sweep from [startFreq] to [endFreq].
List<double> tone(
  double startFreq,
  double endFreq,
  double seconds, {
  double amp = 1,
  String shape = 'sine',
}) {
  final n = (seconds * sampleRate).round();
  final out = List<double>.filled(n, 0);
  var phase = 0.0;
  for (var i = 0; i < n; i++) {
    final t = n <= 1 ? 0.0 : i / n;
    final freq = startFreq + (endFreq - startFreq) * t;
    phase += 2 * pi * freq / sampleRate;
    double v;
    switch (shape) {
      case 'square':
        v = sin(phase) >= 0 ? 1.0 : -1.0;
      case 'saw':
        v = 2 * ((phase / (2 * pi)) % 1) - 1;
      default:
        v = sin(phase);
    }
    out[i] = v * amp;
  }
  return out;
}

List<double> noise(double seconds, {double amp = 1, int seed = 1}) {
  final r = Random(seed);
  final n = (seconds * sampleRate).round();
  return List<double>.generate(n, (_) => (r.nextDouble() * 2 - 1) * amp);
}

List<double> lowPass(List<double> input, double alpha) {
  final out = List<double>.filled(input.length, 0);
  var y = 0.0;
  for (var i = 0; i < input.length; i++) {
    y += alpha * (input[i] - y);
    out[i] = y;
  }
  return out;
}

List<double> highPass(List<double> input, double alpha) {
  final lp = lowPass(input, alpha);
  return List<double>.generate(input.length, (i) => input[i] - lp[i]);
}

/// Fast attack ramp followed by exponential decay.
List<double> envelope(
  List<double> input, {
  double attackSec = 0.005,
  double decayTau = 0.15,
}) {
  final n = input.length;
  final out = List<double>.filled(n, 0);
  final attackSamples = (attackSec * sampleRate).round().clamp(1, max(n, 1));
  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    final env = i < attackSamples
        ? i / attackSamples
        : exp(-(t - attackSec) / decayTau);
    out[i] = input[i] * env;
  }
  return out;
}

List<double> mix(List<List<double>> layers, {List<double>? gains}) {
  final n = layers.map((l) => l.length).reduce(max);
  final out = List<double>.filled(n, 0);
  for (var li = 0; li < layers.length; li++) {
    final g = gains != null ? gains[li] : 1.0;
    final layer = layers[li];
    for (var i = 0; i < layer.length; i++) {
      out[i] += layer[i] * g;
    }
  }
  return out;
}

List<double> concat(List<List<double>> parts) =>
    parts.expand((e) => e).toList(growable: false);

/// Mixes [layer] into [base] starting at [offsetSeconds], extending base if
/// needed.
List<double> addAt(
  List<double> base,
  List<double> layer,
  double offsetSeconds, {
  double gain = 1,
}) {
  final offset = (offsetSeconds * sampleRate).round();
  final needed = offset + layer.length;
  final out = List<double>.from(base);
  if (out.length < needed) {
    out.addAll(List.filled(needed - out.length, 0.0));
  }
  for (var i = 0; i < layer.length; i++) {
    out[offset + i] += layer[i] * gain;
  }
  return out;
}

List<double> normalize(List<double> input, {double peak = 0.9}) {
  var maxAbs = 0.0;
  for (final v in input) {
    if (v.abs() > maxAbs) maxAbs = v.abs();
  }
  if (maxAbs == 0) return input;
  final scale = peak / maxAbs;
  return input.map((v) => v * scale).toList();
}

void writeWav(String path, List<double> samples) {
  final pcm = Int16List(samples.length);
  for (var i = 0; i < samples.length; i++) {
    pcm[i] = (samples[i].clamp(-1.0, 1.0) * 32767).round();
  }
  final dataBytes = pcm.buffer.asUint8List();
  final bytes = BytesBuilder();
  void str(String s) => bytes.add(s.codeUnits);
  void u32(int v) =>
      bytes.add([v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]);
  void u16(int v) => bytes.add([v & 0xff, (v >> 8) & 0xff]);

  str('RIFF');
  u32(36 + dataBytes.length);
  str('WAVE');
  str('fmt ');
  u32(16);
  u16(1); // PCM
  u16(1); // mono
  u32(sampleRate);
  u32(sampleRate * 2); // byte rate
  u16(2); // block align
  u16(16); // bits per sample
  str('data');
  u32(dataBytes.length);
  bytes.add(dataBytes);

  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(bytes.toBytes());
  stdout.writeln('wrote $path (${samples.length} samples)');
}

void main() {
  const dir = 'assets/audio';

  // Machine gun shot: punchy crack (filtered noise transient + tonal click).
  final mgCrack = envelope(
    highPass(noise(0.05, seed: 11), 0.55),
    attackSec: 0.001,
    decayTau: 0.02,
  );
  final mgClick = envelope(
    tone(1800, 850, 0.045, amp: 0.5, shape: 'square'),
    attackSec: 0.001,
    decayTau: 0.025,
  );
  writeWav(
    '$dir/machine_gun_shot.wav',
    normalize(mix([mgCrack, mgClick])),
  );

  // Rocket launch: airy whoosh + low thrust rumble.
  final whoosh = envelope(
    lowPass(noise(0.55, seed: 22), 0.09),
    attackSec: 0.06,
    decayTau: 0.3,
  );
  final thrust = envelope(
    tone(95, 48, 0.55, amp: 0.6, shape: 'sine'),
    attackSec: 0.02,
    decayTau: 0.4,
  );
  writeWav(
    '$dir/rocket_launch.wav',
    normalize(mix([whoosh, thrust], gains: [0.9, 0.6])),
  );

  // Explosion: crack + sub-bass boom + rumbling debris + crackle pops.
  var explosion = <double>[];
  explosion = addAt(
    explosion,
    envelope(highPass(noise(0.18, seed: 33), 0.6), attackSec: 0.001, decayTau: 0.05),
    0,
    gain: 1.0,
  );
  explosion = addAt(
    explosion,
    envelope(tone(130, 42, 1.0, amp: 1.0, shape: 'sine'), attackSec: 0.008, decayTau: 0.5),
    0,
    gain: 1.0,
  );
  explosion = addAt(
    explosion,
    envelope(lowPass(noise(1.3, seed: 44), 0.045), attackSec: 0.02, decayTau: 0.9),
    0,
    gain: 0.85,
  );
  final rnd = Random(7);
  for (var i = 0; i < 10; i++) {
    final offset = 0.05 + rnd.nextDouble() * 0.55;
    final pop = envelope(
      highPass(noise(0.05, seed: 100 + i), 0.5),
      attackSec: 0.001,
      decayTau: 0.015 + rnd.nextDouble() * 0.02,
    );
    explosion = addAt(explosion, pop, offset, gain: 0.35 + rnd.nextDouble() * 0.25);
  }
  writeWav('$dir/explosion.wav', normalize(explosion, peak: 0.95));

  // Bullet impact ping.
  writeWav(
    '$dir/enemy_hit.wav',
    normalize(mix([
      envelope(tone(520, 280, 0.08, amp: 0.6, shape: 'square'), decayTau: 0.04),
      envelope(highPass(noise(0.05, seed: 55), 0.5), attackSec: 0.001, decayTau: 0.02),
    ])),
  );

  // Enemy death thud.
  writeWav(
    '$dir/enemy_death.wav',
    normalize(mix([
      envelope(tone(300, 75, 0.28, amp: 0.8, shape: 'sine'), decayTau: 0.15),
      envelope(lowPass(noise(0.2, seed: 66), 0.1), attackSec: 0.001, decayTau: 0.1),
    ])),
  );

  // Enemy breach alarm (escaped past defenses).
  writeWav(
    '$dir/enemy_escape.wav',
    normalize(concat([
      envelope(tone(660, 660, 0.12, amp: 0.6, shape: 'square'), decayTau: 0.08),
      silence(0.04),
      envelope(tone(550, 550, 0.16, amp: 0.6, shape: 'square'), decayTau: 0.1),
    ])),
  );

  // Gold gain "cha-ching".
  writeWav(
    '$dir/gold_gain.wav',
    normalize(concat([
      envelope(tone(880, 900, 0.07, amp: 0.55, shape: 'sine'), decayTau: 0.05),
      envelope(tone(1320, 1340, 0.1, amp: 0.55, shape: 'sine'), decayTau: 0.08),
    ])),
  );

  // Tower build/placement clunk.
  writeWav(
    '$dir/build_place.wav',
    normalize(mix([
      envelope(tone(220, 160, 0.1, amp: 0.6, shape: 'square'), decayTau: 0.05),
      envelope(lowPass(noise(0.08, seed: 77), 0.2), attackSec: 0.001, decayTau: 0.04),
    ])),
  );

  // Wave start alert.
  writeWav(
    '$dir/wave_start.wav',
    normalize(mix([
      envelope(tone(400, 820, 0.45, amp: 0.55, shape: 'sine'), attackSec: 0.02, decayTau: 0.3),
      envelope(tone(600, 920, 0.4, amp: 0.35, shape: 'square'), attackSec: 0.02, decayTau: 0.25),
    ])),
  );

  // Victory arpeggio.
  var victory = <double>[];
  const notes = [523.25, 659.25, 783.99, 1046.5];
  for (var i = 0; i < notes.length; i++) {
    victory = addAt(
      victory,
      envelope(tone(notes[i], notes[i], 0.45, amp: 0.6, shape: 'sine'), decayTau: 0.5),
      i * 0.16,
    );
  }
  writeWav('$dir/victory.wav', normalize(victory));

  // Defeat descending tone + rumble.
  writeWav(
    '$dir/defeat.wav',
    normalize(mix([
      envelope(tone(300, 70, 1.0, amp: 0.75, shape: 'sine'), attackSec: 0.01, decayTau: 0.6),
      envelope(lowPass(noise(1.0, seed: 88), 0.06), attackSec: 0.02, decayTau: 0.7),
    ])),
  );

  stdout.writeln('Audio generation complete.');
}
