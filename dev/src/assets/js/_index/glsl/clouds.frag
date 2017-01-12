precision mediump float;

varying vec4 vColor;
varying vec2 vUv;
varying float vFogFactor;

uniform vec4 fogColor;
uniform sampler2D texture;

void main(){
  vec4 color = vColor * texture2D(texture, vUv);
  if(color.a == 0.0) {
    discard;
  } else {
    color.a *= 0.6;
    gl_FragColor = mix(vec4(fogColor.r, fogColor.g, fogColor.b, color.a), color, vFogFactor);
  }
  // gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}
