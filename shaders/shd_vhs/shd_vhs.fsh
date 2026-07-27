varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform vec2  u_resolution;
uniform float u_intensity;

uniform vec3  u_ambient;
uniform vec4  u_lights[16];
uniform vec4  u_light_colors[16];
uniform int   u_light_count;
uniform float u_flicker_intensity;
uniform sampler2D u_shadowmap;

uniform vec2  u_player_pos;
uniform float u_player_radius;

float hash(float n)  { return fract(sin(n) * 43758.5453); }
float hash2(vec2 p)  { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

float sample_shadow(vec2 sp) {
    vec2 spc = clamp(sp, 0.0, 1.0);
    float inside = step(0.0001, 1.0 - abs(sign(sp.x - spc.x)) - abs(sign(sp.y - spc.y)));
    return texture2D(u_shadowmap, spc).r * inside;
}

void main() {
    vec2 uv = v_vTexcoord;
    float t = u_time;

    float row      = floor(uv.y * u_resolution.y);
    float jitter_t = floor(t * 12.0);
    float jitter   = (hash2(vec2(row * 0.01, jitter_t)) - 0.5) * 0.004 * u_intensity;
    float jitter_on= step(0.72, hash2(vec2(row * 0.003, jitter_t + 1.0)));
    uv.x += jitter * jitter_on;

    uv.y += sin(uv.y * 4.0 + t * 0.3) * 0.0015 * u_intensity;
    uv = clamp(uv, 0.0, 1.0);

    float ca = 0.003 * u_intensity;
    float r  = texture2D(gm_BaseTexture, clamp(uv + vec2(ca, 0.0), 0.0, 1.0)).r;
    float g  = texture2D(gm_BaseTexture, uv).g;
    float b  = texture2D(gm_BaseTexture, clamp(uv - vec2(ca, 0.0), 0.0, 1.0)).b;
    vec4 col = vec4(r, g, b, 1.0);

    for (int i = 0; i < 6; i++) {
        float fi     = float(i);
        float speed  = 0.9 + fi * 0.3;
        float seed_t = floor(t * speed + fi * 17.3);
        float line_y = hash(seed_t + fi * 5.7);
        float line_w = 0.001 + hash(seed_t + fi * 2.1) * 0.004;
        float life   = hash(seed_t + fi * 9.3);
        float vis    = step(0.55, life);
        float mask   = smoothstep(line_w, 0.0, abs(uv.y - line_y));
        float bright = 0.4 + hash(seed_t + fi * 3.3) * 0.6;
        col.rgb     += mask * bright * vis * u_intensity;
    }

    float glitch_on  = step(0.93, hash(floor(t * 2.0)));
    float glitch_y   = hash(floor(t * 7.3));
    float glitch_w   = 0.01 + hash(floor(t * 3.1)) * 0.035;
    float in_band    = step(abs(uv.y - glitch_y), glitch_w);
    float glitch_amt = (hash(floor(t * 99.1)) - 0.5) * 0.07 * u_intensity;
    vec2  uv_g       = uv;
    uv_g.x          += glitch_on * in_band * glitch_amt;
    uv_g = clamp(uv_g, 0.0, 1.0);
    if (glitch_on * in_band > 0.5) {
        col.r = texture2D(gm_BaseTexture, clamp(uv_g + vec2(ca, 0.0), 0.0, 1.0)).r;
        col.g = texture2D(gm_BaseTexture, uv_g).g;
        col.b = texture2D(gm_BaseTexture, clamp(uv_g - vec2(ca, 0.0), 0.0, 1.0)).b;
    }

    float noise = hash2(uv * u_resolution + t * 7.0);
    float luma  = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    float grain = mix(0.07, 0.02, luma) * u_intensity;
    col.rgb    += (noise - 0.5) * grain;

    float flicker_slow = 0.97 + 0.03 * hash(floor(t * 8.0));
    float flicker_fast = 1.0  - 0.06 * step(0.91, hash(floor(t * 24.0)));
    col.rgb *= flicker_slow * flicker_fast;

    vec2  vig      = uv * (1.0 - uv);
    float vignette = pow(vig.x * vig.y * 15.0, 0.35);
    col.rgb *= vignette;

    col.rgb = mix(col.rgb, col.rgb * vec3(1.0, 0.95, 0.85), 0.2);

    vec3 light_accum = u_ambient;

    for (int i = 0; i < 16; i++) {
        float fi     = float(i);
        float active = step(fi, float(u_light_count) - 1.0);

        float lx      = u_lights[i].x / u_resolution.x;
        float ly      = u_lights[i].y / u_resolution.y;
        float lradius = u_lights[i].z;
        float lbright = u_lights[i].w;
        float ltype   = u_light_colors[i].w;

        float seed = fi * 13.7;

        float is_candle = step(abs(ltype - 1.0), 0.1);
        float flicker_c = sin(t * 13.0 + seed) * 0.08 + sin(t * 31.0 + seed * 2.1) * 0.04;
        lbright *= 1.0 + flicker_c * is_candle;
        lradius *= 1.0 + flicker_c * 0.15 * is_candle;

        float is_lantern = step(abs(ltype - 2.0), 0.1);
        float sway       = sin(t * 7.0 + seed) * 0.06;
        lbright *= 1.0 + sway * 0.5 * is_lantern;
        lradius *= 1.0 + sway * 0.1 * is_lantern;

        float is_window = step(abs(ltype - 3.0), 0.1);
        float pulse     = sin(t * 2.0 + seed) * 0.02;
        lbright *= 1.0 + pulse * is_window;

        float dx      = (uv.x - lx) * u_resolution.x;
        float dy      = (uv.y - ly) * u_resolution.y;
        float dist    = sqrt(dx * dx + dy * dy);
        float falloff = clamp(1.0 - (dist / max(lradius, 1.0)), 0.0, 1.0);
        falloff       = falloff * falloff;

        float sOcclusion = 0.0;
        vec2  from_light = uv - vec2(lx, ly);
        for (float s = 1.0; s < 16.0; s++) {
            sOcclusion += sample_shadow(vec2(lx, ly) + from_light * (s / 16.0));
        }
        float shadow = 1.0 - smoothstep(0.08, 0.35, sOcclusion / 15.0);

        light_accum += u_light_colors[i].rgb * lbright * falloff * shadow * active;
    }

    float room_flicker = 1.0
        + sin(t * 1.7)  * 0.015 * u_flicker_intensity
        + sin(t * 4.3)  * 0.010 * u_flicker_intensity
        + sin(t * 11.0) * 0.005 * u_flicker_intensity
        + step(0.97, hash(floor(t * 6.0))) * (-0.04 * u_flicker_intensity);

    light_accum *= room_flicker;
    col.rgb *= clamp(light_accum, 0.0, 2.0);

    if (u_player_radius > 0.0) {
        float pdx = (uv.x - u_player_pos.x) * u_resolution.x;
        float pdy = (uv.y - u_player_pos.y) * u_resolution.y;
        float pdist = sqrt(pdx * pdx + pdy * pdy);

        float pfalloff = smoothstep(u_player_radius, u_player_radius * 0.65, pdist);

        vec2 from_player = uv - u_player_pos;
        float pOcclusion = 0.0;
        for (float s = 2.0; s < 32.0; s++) {
            pOcclusion += sample_shadow(u_player_pos + from_player * (s / 32.0));
        }

        float pvis = 1.0 - smoothstep(0.06, 0.30, pOcclusion / 30.0);
        float visibility = pfalloff * pvis;
        col.rgb *= max(visibility, 0.02);
    }

    gl_FragColor = col;
}