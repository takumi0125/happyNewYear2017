precision mediump float;

uniform sampler2D texture;
uniform sampler2D posTexture;

uniform float time;
uniform float delta;
uniform float seperationDistance;
uniform float alignmentDistance;
uniform float cohesionDistance;
uniform float numInstances;

const float BOUNDS = 400.0;
const float UPPER_BOUNDS = BOUNDS;
const float LOWER_BOUNDS = -UPPER_BOUNDS;

const float SPEED_LIMIT = 9.0;

#pragma glslify: PI = require('./lib/PI.glsl')
const float PI_2 = PI * 2.0;

void main(){
  // float zoneRadius = seperationDistance + alignmentDistance + cohesionDistance;
  float zoneRadius = 40.0;
  float separationThresh = seperationDistance / zoneRadius;
  float alignmentThresh = (seperationDistance + alignmentDistance) / zoneRadius;
  float zoneRadiusSquared = zoneRadius * zoneRadius;

  // vec3 predator = vec3(sin(time) * 100.0, 0.0, cos(time) * 100.0);
  vec3 predator = vec3(0.0);

  float instanceIndex = gl_FragCoord.y * resolution.x + gl_FragCoord.x;

  // if(instanceIndex >= numInstances) {
  //   discard;
  // }

  vec2 uv = gl_FragCoord.xy / resolution;
  vec3 velocity = texture2D(texture, uv).xyz;
  vec3 pos = texture2D(posTexture, uv).xyz;

  float seperationSquared = seperationDistance * seperationDistance;
  float cohesionSquared = cohesionDistance * cohesionDistance;

  float limit = SPEED_LIMIT;

  vec3 dir = predator * UPPER_BOUNDS - velocity;
  // dir.z = 0.0;
  // dir.z *= 0.6;
  float dist = length(dir);
  float distSquared = dist * dist;

  float preyRadius = 150.0;
  float preyRadiusSq = preyRadius * preyRadius;

  float f;

  // move away from predator
  if (dist < preyRadius) {
    f = (distSquared / preyRadiusSq - 1.0) * delta * 10.0;
    velocity += normalize(dir) * f;
    limit += 5.0;
  }

  // Attract flocks to the center
  vec3 central = vec3(0.0, 0.0, 0.0);
  dir = pos - central;
  // dir.y *= 2.5;
  velocity -= normalize(dir) * delta * 40.0;

  const float width = resolution.x;
  const float height = resolution.y;

  float percent;
  vec2 anotherUv;
  vec3 anotherPos, anotherVelocity;
  float threshDelta;
  float adjustedPercent;
  float anotherIndex;

  for(float y = 0.0; y < height; y++) {
    for(float x = 0.0; x < width; x++) {

      anotherIndex = resolution.x * y + x;
      if (anotherIndex >= numInstances) break;

      anotherUv = vec2(x + 0.5, y + 0.5) / resolution.xy;
      anotherPos = texture2D(posTexture, anotherUv).xyz;

      dir = anotherPos - pos;
      dist = length(dir);

      if (dist < 0.0001) continue;

      distSquared = dist * dist;

      if (distSquared > zoneRadiusSquared) continue;

      percent = distSquared / zoneRadiusSquared;

      if (percent < separationThresh) { // low

        // Separation - Move apart for comfort
        f = (separationThresh / percent - 1.0) * delta;
        velocity -= normalize(dir) * f;

      } else if (percent < alignmentThresh) { // high

        // Alignment - fly the same direction
        threshDelta = alignmentThresh - separationThresh;
        adjustedPercent = (percent - separationThresh) / threshDelta;

        anotherVelocity = texture2D(texture, anotherUv).xyz;
        // anotherVelocity = vec3(0.0);

        f = (0.5 - cos(adjustedPercent * PI_2) * 0.5 + 0.5) * delta;
        velocity += normalize(anotherVelocity) * f;

      } else {

        // Attraction / Cohesion - move closer
        threshDelta = 1.0 - alignmentThresh;
        adjustedPercent = (percent - alignmentThresh) / threshDelta;

        f = (0.5 - (cos(adjustedPercent * PI_2) * -0.5 + 0.5 )) * delta;

        velocity += normalize(dir) * f;
      }
    }
  }

  // Speed Limits
  if (length(velocity) > limit) {
    velocity = normalize(velocity) * limit;
  }

  gl_FragColor = vec4(velocity, 1.0);
}
