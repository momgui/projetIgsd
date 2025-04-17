
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform float time;

varying vec4 vertTexCoord;

void main() {
  vec2 uv = vertTexCoord.st;
  
  // Obtenir la couleur de la scène
  vec4 originalColor = texture2D(texture, uv);
  
  // Effet de mirage/chaleur
  float distortionStrength = 0.005;
  float yOffset = uv.y * 15.0 + time * 1.5;
  float xOffset = sin(yOffset) * distortionStrength;
  
  // Distorsion plus forte vers "l'horizon" (milieu de l'écran)
  float horizonFactor = 1.0 - abs(uv.y - 0.5) * 2.0;
  xOffset *= horizonFactor * horizonFactor;
  
  // Appliquer la distorsion seulement si on n'est pas au bord de l'image
  if (uv.x > 0.02 && uv.x < 0.98) {
    vec2 distortedUV = vec2(uv.x + xOffset, uv.y);
    originalColor = texture2D(texture, distortedUV);
  }
  
  // Teinte désertique chaude
  vec3 warmTint = vec3(1.1, 0.95, 0.8);
  vec3 tintedColor = originalColor.rgb * warmTint;
  
  // Vignettage
  vec2 center = vec2(0.5, 0.5);
  float dist = distance(uv, center);
  float vignette = smoothstep(0.7, 0.3, dist);
  
  // Contraste amélioré
  vec3 contrastedColor = pow(tintedColor, vec3(1.1));
  
  // Combiner les effets
  vec3 finalColor = contrastedColor * (vignette * 0.7 + 0.3);
  
  gl_FragColor = vec4(finalColor, originalColor.a);
}