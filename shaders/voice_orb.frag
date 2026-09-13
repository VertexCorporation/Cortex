// shaders/voice_orb.frag
//
// The Voice Mode V2 orb — a SEALED, soft pastel liquid sphere.
//
// ART DIRECTION (product spec):
//   * broad, blurry organic color fields INSIDE the circle — soft
//     translucent clouds behind frosted glass; lavender / powder blue /
//     blush pink / pale cyan / warm cream, never neon, never Siri;
//   * low-frequency movement only: the fields drift slowly; the audio
//     level nudges warp amplitude and speed VERY subtly — the whole sphere
//     never pulses;
//   * ABSOLUTELY NOTHING outside the circle: no halo, no glow, no bloom,
//     no edge light, no aura. The shader alpha is a hard circle mask; the
//     static AppColors.border stroke is painted by the widget ABOVE this
//     layer (see _VoiceOrbPainter).
//
// Uniforms (float slot order, samplers ignored — setFloat from 0):
//   uRes        0..1    paint-area size in pixels
//   uTime       2       seconds since the visual started (phase continuity)
//   uMic        3       smoothed microphone amplitude 0..1 (listening)
//   uTts        4       smoothed output/TTS amplitude 0..1 (speaking)
//   uState      5       0 subdued, 1 listening, 2 speaking, 3 thinking, 4 flow
//   uExpand     6       compact->fullscreen transition progress 0..1
//   uIntensity  7       overall energy 0..1 (dimmed while connecting/failed)
//   uColorA     8..10   base pastel rgb (lavender / flow identity)
//   uColorB     11..13  field pastel rgb (powder blue / companion)
//   uMulticolor 14      0..1 participant color mixing (flow listening)
//   uColorC     15..17  accent pastel rgb (blush pink / companion)

#include <flutter/runtime_effect.glsl>

uniform vec2 uRes;
uniform float uTime;
uniform float uMic;
uniform float uTts;
uniform float uState;
uniform float uExpand;
uniform float uIntensity;
uniform vec3 uColorA;
uniform vec3 uColorB;
uniform float uMulticolor;
uniform vec3 uColorC;

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float amp = 0.55;
  for (int i = 0; i < 5; i++) {
    v += amp * noise(p);
    p = p * 2.03 + vec2(17.3, 9.1);
    amp *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = (FlutterFragCoord().xy - 0.5 * uRes) / min(uRes.x, uRes.y);
  float r = length(uv);

  // The sealed circle: a hard mask with a sub-pixel AA band. The edge
  // radius meets the widget's static border exactly — nothing exists past
  // it. The circle does NOT breathe with the audio level; all motion
  // lives inside.
  float edge = 0.478;
  float mask = 1.0 - smoothstep(edge - 0.006, edge + 0.002, r);

  float level = max(uMic, uTts);

  // Accumulated on the continuous controller clock with interpolated speed.
  // Changing speaking state cannot jump the liquid phase.
  float tt = uTime;

  // Big soft blobs: LOW-frequency field coordinates — never streaks, never
  // high-frequency turbulence.
  vec2 p = uv * (1.30 - 0.22 * uExpand);

  vec2 w1 = vec2(
    fbm(p + vec2(tt * 0.8, -tt * 0.45)),
    fbm(p + vec2(-tt * 0.5, tt * 0.9) + 31.4)
  );
  vec2 w2 = vec2(
    fbm(p * 1.65 + vec2(-tt * 0.6, tt * 0.5) + 57.2),
    fbm(p * 1.85 + vec2(tt * 0.35, -tt * 0.95) + 12.7)
  );

  float f1 = fbm(p * 1.60 + w1 * (0.85 + 0.20 * level) + vec2(0.0, tt));
  float f2 = fbm(p * 2.05 + w2 * (1.10 + 0.25 * level) + vec2(tt * 0.8, 0.0));
  float f3 = fbm(p * 2.55 - w1 * 0.75 + vec2(44.0 - tt * 0.5, tt * 0.6));

  // Base: a soft warped vertical wash of the two base pastels.
  vec3 col = mix(
    uColorA,
    uColorB,
    smoothstep(-0.42, 0.42, uv.y + 0.55 * (f1 - 0.5))
  );

  // Broad internal color fields — clouds behind frosted glass. Very soft
  // transitions, wide smoothstep ranges, no hard edges anywhere.
  col = mix(col, uColorB, 0.55 * smoothstep(0.42, 0.82, f2));
  col = mix(col, uColorC, 0.50 * smoothstep(0.48, 0.88, f3));
  col = mix(col, uColorA, 0.45 * smoothstep(0.55, 0.95, f1));
  // A pale-cyan vein and a warm cream breath — both extremely subtle.
  col = mix(
    col,
    vec3(0.80, 0.93, 0.95),
    0.10 * smoothstep(0.40, 0.86, f2 - 0.5 * f3)
  );
  col = mix(
    col,
    vec3(1.00, 0.98, 0.94),
    0.08 * smoothstep(0.60, 1.0, f1 + 0.35 * f2)
  );

  // Flow listening/interrupt: participant colors drift through as one more
  // soft field — the orb never becomes a flat identity disc.
  vec3 participant = mix(
    uColorB,
    uColorC,
    0.5 + 0.5 * sin(uTime * 0.35 + f3 * 4.0)
  );
  col = mix(col, participant, uMulticolor * 0.35 * smoothstep(0.45, 0.85, f2));

  // Very subtle luminance movement — internal, never a whole-sphere pulse.
  col *= 0.985 + 0.030 * fbm(p * 3.1 + w2 * 0.55 + vec2(tt * 1.15, -tt * 0.7));

  // Soft internal depth: a gentle center-lit falloff INSIDE the glass —
  // never an edge light, never a rim ring.
  float rim = smoothstep(edge * 0.35, edge, r);
  col *= 1.0 - 0.10 * rim;

  // Grain: kills banding across the wide soft gradients. Extremely subtle.
  col += (hash(FlutterFragCoord().xy) - 0.5) * 0.012;

  // Energy: dim the interior while connecting/failed — the alpha never
  // changes (the sphere stays sealed; only the interior light dims).
  col *= 0.55 + 0.45 * uIntensity;

  fragColor = vec4(col * mask, mask);
}