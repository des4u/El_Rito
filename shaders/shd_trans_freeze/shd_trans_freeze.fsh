varying vec2 v_vTexcoord;
uniform float u_time;
uniform float u_progress;
uniform vec2  u_resolution;

float hash(float n)       { return fract(sin(n) * 43758.5453); }
float hash2(vec2 p)       { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
    vec2 uv = v_vTexcoord;
    float t  = u_time;
    float p  = u_progress;

    float block_size = mix(1.0, 32.0, p) / u_resolution.y;
    vec2 frozen_uv   = floor(uv / block_size) * block_size;
    uv               = mix(uv, frozen_uv, smoothstep(0.2, 0.7, p));

    float row      = floor(uv.y * u_resolution.y);
    float glitch_t = floor(t * 20.0);
    float glitch   = (hash2(vec2(row * 0.01, glitch_t)) - 0.5)
                   * 0.06 * smoothstep(0.1, 0.9, p);
    float g_on     = step(0.5, hash2(vec2(row * 0.005, glitch_t)));
    uv.x          += glitch * g_on;


    float ca  = mix(0.003, 0.04, smoothstep(0.5, 1.0, p));
    float r   = texture2D(gm_BaseTexture, uv + vec2( ca, 0.0)).r;
    float g   = texture2D(gm_BaseTexture, uv               ).g;
    float b   = texture2D(gm_BaseTexture, uv - vec2( ca, 0.0)).b;
    vec4 col  = vec4(r, g, b, 1.0);


    for (int i = 0; i < 5; i++) {
        float fi   = float(i);
        float st   = floor(t * (1.5 + fi * 0.4) + fi * 13.7);
        float ly   = hash(st + fi * 5.7);
        float lw   = 0.002 + hash(st + fi * 2.1) * 0.006;
        float vis  = step(0.4, hash(st + fi * 9.3))
                   * smoothstep(0.2, 0.8, p);
        float mask = smoothstep(lw, 0.0, abs(uv.y - ly));
        col.rgb   += mask * (0.5 + hash(st) * 0.5) * vis;
    }

    col.rgb *= 1.0 - smoothstep(0.75, 1.0, p);

    gl_FragColor = col;
}