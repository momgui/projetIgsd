#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

// Attributs obligatoires de Processing
attribute vec4 vertex;
attribute vec3 normal;
attribute vec2 texcoord;

varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vTexCoord;

uniform mat4 transform;    // Matrice combinée (projection * modelview)

void main() {
  // Calculer la position transformée
  gl_Position = transform * vertex;
  // Transmettre la position dans l'espace monde (ou approximatif) pour calculer la distance avec la lumière
  vPosition = vertex.xyz;
  // Transmettre la normale
  vNormal = normal;
  // Transmettre les coordonnées de texture éventuelles
  vTexCoord = texcoord;
}
