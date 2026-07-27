varying vec2 v_vTexcoord;
uniform float u_time;
uniform vec2  u_resolution;

float hash(float n)  { return fract(sin(n) * 43758.5453); }
float hash2(vec2 p)  { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
    vec2 uv = v_vTexcoord;
    float t = u_time;

    float block_size = 24.0 / u_resolution.y;
    vec2 frozen_uv   = floor(uv / block_size) * block_size;
    uv               = mix(uv, frozen_uv, 0.85);

    float row      = floor(uv.y * u_resolution.y);
    float glitch_t = floor(t * 20.0);
    float glitch   = (hash2(vec2(row * 0.01, glitch_t)) - 0.5) * 0.06;
    float g_on     = step(0.5, hash2(vec2(row * 0.005, glitch_t)));
    uv.x          += glitch * g_on;

    float ca = 0.025;
    float r  = texture2D(gm_BaseTexture, uv + vec2( ca, 0.0)).r;
    float g  = texture2D(gm_BaseTexture, uv               ).g;
    float b  = texture2D(gm_BaseTexture, uv - vec2( ca, 0.0)).b;
    vec4 col = vec4(r, g, b, 1.0);

    for (int i = 0; i < 5; i++) {
        float fi   = float(i);
        float st   = floor(t * (1.5 + fi * 0.4) + fi * 13.7);
        float ly   = hash(st + fi * 5.7);
        float lw   = 0.002 + hash(st + fi * 2.1) * 0.006;
        float vis  = step(0.4, hash(st + fi * 9.3));
        float mask = smoothstep(lw, 0.0, abs(uv.y - ly));
        col.rgb   += mask * (0.5 + hash(st) * 0.5) * vis;
    }

    col.rgb = mix(col.rgb, vec3(0.0), 0.92);
	gl_FragColor = col;
}