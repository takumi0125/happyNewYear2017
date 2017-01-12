uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 normalMatrix;

uniform float f;
uniform float time;
uniform vec3 cameraPosition;
uniform vec3 eyeDir;
uniform float rotateY;
uniform float cameraRotateY;
uniform float animationParam1;
uniform float animationParam2;

attribute vec3 position;
attribute vec2 uv;
attribute vec3 translate;
attribute vec3 translate2;
attribute vec3 normal;
attribute vec3 randomValues;

varying vec4 vColor;

#pragma glslify: PI = require('./lib/PI.glsl')
#pragma glslify: rotateVec3 = require('./lib/rotateVec3.glsl')
#pragma glslify: map = require('./lib/map.glsl')
#pragma glslify: hsv2rgb = require('./lib/hsv2rgb.glsl')
#pragma glslify: easeInOutExpo = require('glsl-easings/exponential-in-out')
#pragma glslify: easeInOutSine = require('glsl-easings/sine-in-out')
#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')
#pragma glslify: snoise3 = require('glsl-noise/simplex/3d')

const vec4 ambientColor = vec4(0.1, 0.1, 0.1, 0.0);
const vec3 lightPos = vec3(0.0, -100.0, 0.0);

const vec3 axisX = vec3(1.0, 0.0, 0.0);
const vec3 axisY = vec3(0.0, 1.0, 0.0);
const vec3 axisZ = vec3(0.0, 0.0, 1.0);

float getRad(float scale, float offset) {
  return map(mod(time * scale + offset, PI * 2.0), 0.0, PI * 2.0, -PI, PI, true);
}

float getAnimationParam(float value, float randomValue) {
  float r = randomValue * 0.2;
  return map(value, r, r + 0.8, 0.0, 1.0, true);
}

void main() {
  vec3 pos = position;
  vec3 n = normal;
  float theta;

  float r = snoise3(translate / 10.0);
  float scale = (sin(getRad(20.0, r * 60.0)) + 1.0) + 1.0;
  pos *= scale;

  theta = getRad(10.0, r * 120.0);
  pos = rotateVec3(pos, theta, axisX);
  n   = rotateVec3(n,   theta, axisX);
  pos = rotateVec3(pos, theta, axisY);
  n   = rotateVec3(n,   theta, axisY);
  pos = rotateVec3(pos, theta, axisZ);
  n   = rotateVec3(n,   theta, axisZ);

  // 文字
  float p = easeInOutExpo(getAnimationParam(animationParam1, snoise3(translate2)));
  pos += (translate * p + translate2 * (1.0 - p));

  // ランダム
  p = easeInOutSine(abs(abs(cameraRotateY) - rotateY) / PI);
  theta = getRad(0.1, r * 120.0);
  pos.x += p * sin(theta) * 700.0;

  theta = getRad(0.1 * p, snoise2(randomValues.xy * 100.0) * 10.0 * p);
  pos = rotateVec3(pos, theta, axisZ);
  n   = rotateVec3(n,   theta, axisZ);

  theta = getRad(0.1 * p, snoise2(randomValues.yz * 100.0) * 10.0 * p);
  pos = rotateVec3(pos, theta, axisX);
  n   = rotateVec3(n,   theta, axisX);

  theta = getRad(0.1 * p, snoise2(randomValues.zx * 100.0) * 10.0 * p);
  pos = rotateVec3(pos, theta, axisY);
  n   = rotateVec3(n,   theta, axisY);


  vec4 modelPos = modelMatrix * vec4(pos, 1.0);

  vec3 light = normalize(lightPos - modelPos.xyz);
  vec3 eye = normalize(eyeDir).xyz;
  float diffuse = clamp(dot(n, light), 0.0, 1.0) + 0.2;

  gl_Position = projectionMatrix * viewMatrix * modelPos;
  vColor = vec4(1.0, 0.6, 0.0, 1.0) * vec4(vec3(diffuse), 1.0) + ambientColor;
}
