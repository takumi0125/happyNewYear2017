precision mediump float;

uniform vec4 fogColor;

varying vec4 vColor;
varying float vFogFactor;

void main(){
  vec4 fragColor = mix(fogColor, vColor, vFogFactor);
  gl_FragColor = fragColor;
}
