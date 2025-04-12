#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vTexCoord;

uniform vec3 lightPos;      // Position du joueur, source de lumière
uniform vec3 lightColor;    // Couleur de la lumière (ex. blanc, légèrement chaud pour une ambiance inquiétante)
uniform float lightIntensity;
uniform vec3 ambientColor;  // Couleur ambiante pour la scène sombre

// Paramètres du spotlight
uniform vec3 spotDirection;
uniform float spotCutOff;   // Angle (en cosinus) du cône de lumière
uniform float spotExponent; // Pour moduler la répartition de l’intensité dans le cône

void main() {
  // Normaliser la normale de l'objet
  vec3 N = normalize(vNormal);
  // Calculer le vecteur allant de la position du fragment à la source lumineuse
  vec3 L = normalize(lightPos - vPosition);
  
  // Calcul de l’éclairage diffus (Lambert)
  float diff = max(dot(N, L), 0.0);

  // Calcul de l’éclairage spéculaire (exemple Phong simplifié)
  vec3 viewDir = normalize(-vPosition); // Si la caméra est située à l'origine
  vec3 reflectDir = reflect(-L, N);
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16.0);

  // Calcul du spotlight
  float theta = dot(L, normalize(-spotDirection));
  float epsilon = spotCutOff - 0.05;  // zone de transition pour adoucir les bords du cône
  float intensity = clamp((theta - epsilon) / (spotCutOff - epsilon), 0.0, 1.0);
  intensity = pow(intensity, spotExponent);

  // Combiner les composantes de lumière
  vec3 ambient = ambientColor;
  vec3 diffuse = lightColor * diff * lightIntensity;
  vec3 specular = lightColor * spec * lightIntensity;

  // Appliquer le spotlight (la lumière influence uniquement à l'intérieur du cône)
  diffuse *= intensity;
  specular *= intensity;
  
  // Finalement, on peut également ajouter un effet de brouillard ou attenuation
  // Exemple d'atténuation simple en fonction de la distance
  float distance = length(lightPos - vPosition);
  float attenuation = 1.0 / (1.0 + 0.1 * distance + 0.05 * (distance * distance));

  vec3 color = (ambient + diffuse + specular) * attenuation;

  // Vous pouvez combiner avec une texture si vous avez un sampler2D :
  // vec4 texColor = texture2D(sampler, vTexCoord);
  // gl_FragColor = vec4(color, 1.0) * texColor;
  gl_FragColor = vec4(color, 1.0);
}
