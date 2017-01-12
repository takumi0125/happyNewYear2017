uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 normalMatrix;

uniform float time;
uniform float animationParam1;
uniform float numInstances;
uniform vec2 renderTextureResolution;

uniform sampler2D posTexture;
uniform sampler2D velocityTexture;

attribute vec3 position;
attribute vec3 translate;
attribute vec2 uv;
attribute vec3 normal;
attribute vec3 randomValues;
attribute float lineIndex;
attribute float instanceIndex;

varying vec2 vUv;
varying float vColorParam;
varying vec4 vLineColor;

#pragma glslify: PI = require('./lib/PI.glsl')
#pragma glslify: rotateVec3 = require('./lib/rotateVec3.glsl')
#pragma glslify: map = require('./lib/map.glsl')
#pragma glslify: hsv2rgb = require('./lib/hsv2rgb.glsl')
#pragma glslify: easeInOutExpo = require('glsl-easings/exponential-in-out')
#pragma glslify: snoise3 = require('glsl-noise/simplex/3d')

const vec3 axisX = vec3(1.0, 0.0, 0.0);
const vec3 axisY = vec3(0.0, 1.0, 0.0);
const vec3 axisZ = vec3(0.0, 0.0, 1.0);

float getRad(float scale, float offset) {
  return map(mod(time * scale + offset, PI * 2.0), 0.0, PI * 2.0, -PI, PI, true);
}

float getAnimationParam(float value, float randomValue) {
  float r = randomValue * 0.4;
  return map(value, r, r + 0.6, 0.0, 1.0, true);
}

void main() {
  vec3 pos = position;

  // boids animation
  float p = easeInOutExpo(getAnimationParam(animationParam1, 1.0 - instanceIndex / numInstances));
  vec2 tuv = vec2(
    mod(instanceIndex, renderTextureResolution.x),
    floor(instanceIndex / renderTextureResolution.x)
  ) / renderTextureResolution;

  // shape
  pos.x *= (1.0 - p * 0.8);
  pos.y *= (1.0 + p * 4.0);

  // attitude
  pos = rotateVec3(pos, p * PI * 1.5, axisX);
  pos = rotateVec3(pos, p * sin(getRad(10.0, randomValues.x * 10.0)), axisZ);
  vec3 v = normalize(texture2D(velocityTexture, tuv).xyz);
  float angle = acos(dot(-axisZ, v));
  pos = rotateVec3(pos, angle * p, normalize(cross(-axisZ, v)));
  pos += p * texture2D(posTexture, tuv).xyz;

  // txt position
  pos += translate * (1.0 - p);
  pos = rotateVec3(pos, PI, axisY);
  vec4 modelPos = modelMatrix * vec4(pos, 1.0);
  gl_Position = projectionMatrix * viewMatrix * modelPos;
  vec3 posN = normalize(modelPos.xyz);

  vUv = uv;
  vColorParam = p;
  vLineColor = vec4(hsv2rgb(vec3(
    map(sin(getRad(10.0, snoise3(posN + randomValues / 3.0) * 30.0)), -1.0, 1.0, 0.1, 0.15, true),
    map(sin(getRad(50.0, snoise3(posN + randomValues) * 30.0)), -1.0, 1.0, 0.0, 1.0, true),
    1.0
  )), 0.8);
}
