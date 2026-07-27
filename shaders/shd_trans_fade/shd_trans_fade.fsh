varying vec2 v_vTexcoord;
uniform float u_time;
uniform float u_progress;
uniform vec2  u_resolution;

float hash(float n)  { return fract(sin(n) * 43758.5453); }
float hash2(vec2 p)  { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
    vec2 uv  = v_vTexcoord;
    float t  = u_time;
    float p  = u_progress;


    float row    = floor(uv.y * u_resolution.y);
    float jt     = floor(t * 15.0);
    float jitter = (hash2(vec2(row * 0.008, jt)) - 0.5)
                 * 0.025 * p;
    uv.x        += jitter * step(0.55, hash2(vec2(row * 0.004, jt + 1.0)));

    float ca = 0.003 + 0.015 * p;
    float r  = texture2D(gm_BaseTexture, uv + vec2( ca, 0.0)).r;
    float g  = texture2D(gm_BaseTexture, uv               ).g;
    float b  = texture2D(gm_BaseTexture, uv - vec2( ca, 0.0)).b;
    vec4 col = vec4(r, g, b, 1.0);


    float beat1 = step(0.85, hash(floor(t * 18.0))) * 0.7;
    float beat2 = step(0.90, hash(floor(t * 7.0  ))) * 0.5;
    float beat3 = step(0.80, hash(floor(t * 31.0 ))) * 0.4;
    float flicker_dark = max(max(beat1, beat2), beat3) * smoothstep(0.1, 0.6, p);


    float darkness = smoothstep(0.0, 1.0, p) * 0.6 + flicker_dark;
    darkness       = clamp(darkness, 0.0, 1.0);
    col.rgb       *= (1.0 - darkness);


    col.rgb *= 1.0 - smoothstep(0.82, 1.0, p);

    gl_FragColor = col;
}