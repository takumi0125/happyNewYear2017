uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform float time;
uniform float radius;

attribute vec3 position;
attribute vec2 uv;
attribute float rotationY;
attribute float rotationZ;

varying vec4 vColor;
varying vec2 vUv;

#pragma glslify: rotateVec3 = require('./lib/rotateVec3.glsl')
#pragma glslify: easeOutSine = require('glsl-easings/sine-out')

void main() {
  vec3 pos = position;

  pos.x += easeOutSine(mod(time, 0.03) / 0.03) * 5.0;
  pos = rotateVec3(pos, rotationZ, vec3(0.0, 0.0, 1.0));
  pos.z = -radius;
  pos = rotateVec3(pos, rotationY, vec3(0.0, 1.0, 0.0));

  vColor = vec4(1.0, 0.6, 0.0, 0.4);
  vUv = uv;

  // position
  vec4 modelPos = modelMatrix * vec4(pos, 1.0);
  vec4 modelViewPos = viewMatrix * modelPos;
  gl_Position = projectionMatrix * modelViewPos;
}
