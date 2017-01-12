precision mediump float;

varying vec4 vColor;
varying vec2 vUv;

uniform sampler2D texture;

void main(){
  vec4 color = vColor * texture2D(texture, vUv);
  if(color.a == 0.0) {
    discard;
  } else {
    gl_FragColor = color;
  }
}
