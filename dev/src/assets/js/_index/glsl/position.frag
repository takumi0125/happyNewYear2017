precision highp float;

uniform sampler2D texture;
uniform sampler2D velocityTexture;
uniform float delta;

void main(){
  float instanceIndex = gl_FragCoord.y * resolution.x + gl_FragCoord.x;
  vec2 tUV = gl_FragCoord.xy / resolution;
  vec3 pos = texture2D(texture, tUV).xyz;

  // 速度を加算
  pos += texture2D(velocityTexture, tUV).xyz * delta * 10.0;

  gl_FragColor = vec4(pos, 1.0);
}
