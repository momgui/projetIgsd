#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform float time;
uniform float pulseSpeed;
uniform float flickerIntensity;
uniform vec2 playerPos;

varying vec4 vertTexCoord;

// Fonction de bruit pour les effets aléatoires
float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Bruit de Perlin simplifié
float noise(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);
  
  float a = random(i);
  float b = random(i + vec2(1.0, 0.0));
  float c = random(i + vec2(0.0, 1.0));
  float d = random(i + vec2(1.0, 1.0));
  
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
  vec2 uv = vertTexCoord.st;
  
  // 1. DISTORSION ONDULANTE
  // -----------------------
  // Effet de distorsion subtil qui simule des murs qui semblent "respirer"
  float wallPulse = sin(time * pulseSpeed) * 0.002;
  float distortion = sin(uv.y * 20.0) * wallPulse;
  
  // 2. EFFET DE SCINTILLEMENT
  // ------------------------
  // Simuler un éclairage défectueux/torche vacillante
  float flicker = 1.0;
  
  // Scintillement rapide aléatoire
  float fastFlicker = random(vec2(time * 50.0, 0.0));
  fastFlicker = step(0.93, fastFlicker); // Seulement occasionnellement
  
  // Scintillement lent
  float slowFlicker = 0.95 + sin(time * 1.5) * 0.05;
  
  // Combiner les scintillements
  flicker = mix(slowFlicker, fastFlicker, flickerIntensity * 0.4);
  
  // 3. VIGNETTAGE FORT
  // ----------------
  // Centre du vignettage près de la position du joueur (simulé par la souris)
  vec2 vignetteCenter = playerPos;
  float dist = distance(uv, vignetteCenter);
  
  // Vignettage plus intense aux bords (comme une torche/vision limitée)
  float vignette = 1.0 - dist * 1.3;
  vignette = smoothstep(0.2, 0.8, vignette);
  
  // 4. GRAIN/BRUIT
  // ------------
  // Ajouter du grain pour l'ambiance film d'horreur
  float grain = random(uv * time) * 0.1 - 0.05;

  
  // 6. OBTENIR LA COULEUR DE BASE
  // ---------------------------
  vec2 distortedUV = vec2(uv.x + distortion, uv.y);
  vec4 originalColor = texture2D(texture, distortedUV);
  
  // 7. PALETTE DE COULEURS SOMBRE
  // ---------------------------
  // Teinte bleu-verdâtre sombre pour l'ambiance horreur
  vec3 darkTint = vec3(0.2, 0.3, 0.4);
  vec3 tintedColor = mix(originalColor.rgb, darkTint, 0.4);
  
  // 8. APPLIQUER LES EFFETS
  // ---------------------
  // Appliquer le vignettage
  vec3 vignetteColor = tintedColor;
  
  
  // Appliquer le scintillement et le grain
  vec3 flickerColor = vignetteColor * flicker + grain;

  
  gl_FragColor = vec4(flickerColor, originalColor.a);
}