uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
uniform float time;
uniform float fogStart;
uniform float fogEnd;
uniform float near;
uniform float far;

attribute vec3 position;
attribute vec2 uv;
attribute vec3 translate;
attribute float instanceIndex;

varying vec4 vColor;
varying float vFogFactor;
varying vec2 vUv;

#pragma glslify: PI = require('./lib/PI.glsl')
#pragma glslify: rotateVec3 = require('./lib/rotateVec3.glsl')
#pragma glslify: map = require('./lib/map.glsl')
#pragma glslify: hsv2rgb = require('./lib/hsv2rgb.glsl')
#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')
#pragma glslify: snoise3 = require('glsl-noise/simplex/3d')

float getRad(float scale, float offset) {
  return map(mod(time * scale + offset, PI * 2.0), 0.0, PI * 2.0, -PI, PI, true);
}

void main() {
  vec3 pos = translate;
  float n = map(snoise2(translate.xz * 10.0), 0.0, 1.0, -1.0, 1.0, true);
  pos = rotateVec3(pos, getRad(0.4 * n, n * 100.0), vec3(0.0, 1.0, 0.0));

  vec4 modelPos = modelMatrix * vec4(pos, 1.0);

  // fog
  float linerPos = length(modelPos.xyz - cameraPosition) / (far - near);
  vFogFactor = clamp((fogEnd - linerPos) / (fogEnd - fogStart), 0.0, 1.0);

  // color
  vColor = vec4(
    hsv2rgb(vec3(
      map(sin(getRad(10.0, snoise2(translate.xz * 100.0) * 10.0)), -1.0, 1.0, 0.1, 0.15, true),
      0.8,
      1.0
    )),
    1.0
  );

  // uv
  float index = mod(instanceIndex, 10.0);
  float colIndex = mod(index, 5.0);
  float rowIndex = floor(index / 5.0);
  vUv = vec2(
    (uv.x + colIndex) / 5.0,
    (uv.y + rowIndex) / 2.0
  );

  // position
  vec4 modelViewPos = viewMatrix * modelPos;
  modelViewPos += vec4(position, 1.0);
  gl_Position = projectionMatrix * modelViewPos;
}
