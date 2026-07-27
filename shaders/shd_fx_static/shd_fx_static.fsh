varying vec2 v_vTexcoord;
uniform float u_time;
uniform vec2  u_resolution;

float hash(float n)  { return fract(sin(n) * 43758.5453); }
float hash2(vec2 p)  { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
    vec2 uv = v_vTexcoord;
    float t = u_time;

    float ca = 0.004;
    float r  = texture2D(gm_BaseTexture, uv + vec2( ca, 0.0)).r;
    float g  = texture2D(gm_BaseTexture, uv               ).g;
    float b  = texture2D(gm_BaseTexture, uv - vec2( ca, 0.0)).b;
    vec4 col = vec4(r, g, b, 1.0);

    float static_noise  = hash2(uv * u_resolution * 12.0  + floor(t * 30.0));
    float static_coarse = hash2(floor(uv * u_resolution * 4.0) + floor(t * 20.0));
    float noise_final   = mix(static_noise, static_coarse, 0.4);
    vec3  static_col    = vec3(noise_final);

    col.rgb = mix(col.rgb, static_col, 0.80);

    for (int i = 0; i < 4; i++) {
        float fi   = float(i);
        float st   = floor(t * (2.0 + fi * 0.7) + fi * 11.3);
        float ly   = hash(st + fi * 4.1);
        float lw   = 0.003 + hash(st + fi * 1.9) * 0.008;
        float vis  = step(0.45, hash(st + fi * 7.7));
        float mask = smoothstep(lw, 0.0, abs(uv.y - ly));
        col.rgb   += mask * vis * 0.8;
    }

	col.rgb = mix(col.rgb, vec3(0.0), 0.5);
	gl_FragColor = col;
}