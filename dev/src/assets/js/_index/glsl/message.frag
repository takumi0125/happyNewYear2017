precision mediump float;

varying vec2 vUv;
varying float vColorParam;
varying vec4 vLineColor;

uniform sampler2D txtTexture;

// const vec4 lineColor = vec4(1.0, 0.6, 0.0, 0.8);
const vec4 lineColor = vec4(0.8, 0.8, 0.8, 0.4);
const vec4 txtColor = vec4(0.0, 0.0, 0.0, 1.0);

void main(){
  vec4 texColor = texture2D(txtTexture, vUv);
  vec4 color = mix(texColor * txtColor, vLineColor, vColorParam);
  if(color.a == 0.0) {
    discard;
  } else {
    gl_FragColor = color;
  }
}
