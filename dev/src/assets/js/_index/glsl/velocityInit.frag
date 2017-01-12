precision highp float;

#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')

void main(){
  // gl_FragColor = vec4(
  //   snoise2(gl_FragCoord.xy),
  //   snoise2(gl_FragCoord.yx),
  //   snoise2(gl_FragCoord.xy * gl_FragCoord.yx),
  //   0.0
  // ) * 1.0;
  gl_FragColor = vec4(1.0, 1.0, 1.0, 0.0) * 1.0;
}
