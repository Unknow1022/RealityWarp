#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif

extern PRECISION vec2 mouse_screen_pos;
extern PRECISION float hovering;
extern PRECISION float screen_scale;
extern PRECISION vec2 glitch;
extern PRECISION vec2 reality_warp_glitch;
extern PRECISION float time;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.0){
        return transform_projection * vertex_position;
    }
    float mid_dist = length(vertex_position.xy - 0.5 * love_ScreenSize.xy) / length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy) / screen_scale;
    float scale = 0.2 * (-0.03 - 0.3 * max(0.0, 0.3 - mid_dist))
                * hovering * (length(mouse_offset) * length(mouse_offset)) / (2.0 - mid_dist);

    return transform_projection * vertex_position + vec4(0.0, 0.0, 0.0, scale);
}
#endif

#ifdef PIXEL
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern PRECISION float dissolve;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.0) : tex.xyz, shadow ? tex.a * 0.3 : tex.a);
    }

    float adjusted_dissolve = (dissolve * dissolve * (3.0 - 2.0 * dissolve)) * 1.02 - 0.01;

    float t = time * 10.0 + 2003.0;
    vec2 floored_uv = (floor((uv * texture_details.ba))) / max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);

    vec2 field_part1 = uv_scaled_centered + 50.0 * vec2(sin(-t / 143.6340), cos(-t / 99.4324));
    vec2 field_part2 = uv_scaled_centered + 50.0 * vec2(cos(t / 53.1532),  cos(t / 61.4532));
    vec2 field_part3 = uv_scaled_centered + 50.0 * vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.0 + (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) )) / 2.0;
    vec2 borders = vec2(0.2, 0.8);

    float res = (0.5 + 0.5 * cos((adjusted_dissolve) / 82.612 + (field - 0.5) * 3.14159265))
        - (floored_uv.x > borders.y ? (floored_uv.x - borders.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.y > borders.y ? (floored_uv.y - borders.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.x < borders.x ? (borders.x - floored_uv.x) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.y < borders.x ? (borders.x - floored_uv.x) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve;

    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8 * (0.5 - abs(adjusted_dissolve - 0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5 * (0.5 - abs(adjusted_dissolve - 0.5)) && res > adjusted_dissolve) {
            tex.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            tex.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.0) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a * 0.3 : tex.a) : 0.0);
}

float g_hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 orig_tex = Texel(texture, texture_coords);
    if (orig_tex.a <= 0.0) {
        return vec4(0.0);
    }

    vec2 uv = (((texture_coords) * (image_details)) - texture_details.xy * texture_details.ba) / texture_details.ba;

    // Use continuous real-time clock: advances 1 second every real second everywhere
    float t_clock = time;
    if (t_clock <= 0.0) t_clock = glitch.y;
    if (t_clock <= 0.0) t_clock = reality_warp_glitch.y;
    if (t_clock <= 0.0) t_clock = (glitch.x > 0.0 ? glitch.x : reality_warp_glitch.x);
    if (t_clock <= 0.0) t_clock = 1.0;
    float curr_t = t_clock;
    float sec = floor(curr_t);
    float sec_mode = mod(sec, 8.0); // 8 distinct glitch styles swapping every 1.0s
    float fast_t = curr_t * 30.0;   // High-frequency 30 FPS tick
    float t_step = floor(fast_t);
    float strobe_step = floor(curr_t * 24.0);

    // Procedural style randomness generated per second
    float sec_rand1 = g_hash(vec2(sec, 3.17));
    float sec_rand2 = g_hash(vec2(sec, 7.89));

    // Dynamic slice displacement based on active style
    float slice_freq = 24.0 + sec_rand1 * 40.0;
    float slice_intensity = 0.12 + sec_rand2 * 0.12;

    float slice_y = floor(uv.y * slice_freq);
    float slice_offset = (g_hash(vec2(slice_y * 3.7, t_step * 1.3)) - 0.5) * slice_intensity;

    // Digital block artifacts & corrupt noise tiles
    vec2 block_size = vec2(8.0 + floor(sec_rand1 * 14.0), 12.0 + floor(sec_rand2 * 18.0));
    vec2 block_grid = floor(uv * block_size);
    float block_hash = g_hash(block_grid + vec2(t_step * 0.17, t_step * 0.43));
    float is_corrupt_block = step(0.55, block_hash);
    vec2 block_offset = (vec2(g_hash(block_grid), g_hash(block_grid + 2.1)) - 0.5) * 0.10 * is_corrupt_block;

    // Continuous sine-wave glitch ripple
    float wave_tear = sin(uv.y * 35.0 + fast_t * 1.5) * 0.03;
    slice_offset += wave_tear;

    // Rolling CRT bar in styles 2 and 6
    float roll_bar = 0.0;
    if (sec_mode == 2.0 || sec_mode == 6.0) {
        float roll_y = fract(curr_t * 1.2);
        roll_bar = smoothstep(0.12, 0.0, abs(uv.y - roll_y));
        slice_offset += sin(uv.y * 30.0 + fast_t) * 0.06 * roll_bar;
    }

    // Clamp displaced UV to prevent sprite atlas bleeding
    vec2 displaced_uv = clamp(uv + vec2(slice_offset, 0.0) + block_offset, vec2(0.002), vec2(0.998));

    // Chromatic aberration
    float split_amt = 0.022 + 0.025 * abs(slice_offset) + 0.020 * roll_bar;
    vec2 r_uv = clamp(displaced_uv + vec2(split_amt, 0.0), vec2(0.002), vec2(0.998));
    vec2 g_uv = displaced_uv;
    vec2 b_uv = clamp(displaced_uv - vec2(split_amt, (sec_mode >= 1.0 && sec_mode < 3.0) ? split_amt * 0.7 : 0.0), vec2(0.002), vec2(0.998));

    vec2 r_tc = (r_uv * texture_details.ba + texture_details.xy * texture_details.ba) / image_details;
    vec2 g_tc = (g_uv * texture_details.ba + texture_details.xy * texture_details.ba) / image_details;
    vec2 b_tc = (b_uv * texture_details.ba + texture_details.xy * texture_details.ba) / image_details;

    vec4 tex_r = Texel(texture, r_tc);
    vec4 tex_g = Texel(texture, g_tc);
    vec4 tex_b = Texel(texture, b_tc);

    vec3 rgb = vec3(tex_r.r, tex_g.g, tex_b.b);
    float alpha = orig_tex.a;

    // High-speed strobe palette
    float color_t = curr_t * 36.0;
    vec3 strobe_palette = vec3(
        sin(color_t + uv.y * 14.0) * 0.5 + 0.5,
        sin(color_t + 2.094 + uv.x * 16.0) * 0.5 + 0.5,
        sin(color_t + 4.188 + (uv.x + uv.y) * 12.0) * 0.5 + 0.5
    );

    float flash_hash = g_hash(vec2(strobe_step, 9.17));
    vec3 flash_color = vec3(
        step(0.4, fract(flash_hash * 7.1)),
        step(0.4, fract(flash_hash * 13.3)),
        step(0.4, fract(flash_hash * 19.7))
    );

    // 8 Procedural Glitch Styles (One unique style every second, constantly cycling)
    if (sec_mode == 0.0) {
        // Style 0: Cyberpunk Neon Horizontal Slices & Strobe
        if (is_corrupt_block > 0.5) {
            rgb = mix(1.0 - rgb, strobe_palette, 0.75);
        } else {
            float scanline = sin(uv.y * 220.0 + fast_t * 3.0) * 0.5 + 0.5;
            rgb = mix(rgb, rgb * strobe_palette * 1.8, 0.55 + 0.25 * scanline);
        }
    } else if (sec_mode == 1.0) {
        // Style 1: Digital Voxel Bit-Inversion & Diagonal Glitch
        if (is_corrupt_block > 0.5) {
            rgb = mix(vec3(1.0) - rgb, flash_color, 0.65);
        } else {
            rgb.rb = mix(rgb.rb, rgb.br, 0.5 + 0.5 * sin(fast_t));
            rgb = mix(rgb, strobe_palette * 1.4, 0.35);
        }
    } else if (sec_mode == 2.0) {
        // Style 2: CRT Rolling Bar & Phosphor Scanlines
        float crt_scan = sin(uv.y * 320.0) * 0.5 + 0.5;
        rgb *= (0.75 + 0.35 * crt_scan);
        if (roll_bar > 0.2) {
            rgb = mix(1.0 - rgb, strobe_palette * 2.0, 0.70);
        }
        rgb = mix(rgb, rgb * vec3(0.5, 1.4, 1.2), 0.30);
    } else if (sec_mode == 3.0) {
        // Style 3: Thermal Solarization & Channel Rotation
        rgb = abs(sin(rgb * 3.14159 + color_t * 0.5));
        rgb = mix(rgb, strobe_palette, 0.40);
        if (fract(fast_t * 0.25) > 0.75) {
            rgb = rgb.bgr;
        }
    } else if (sec_mode == 4.0) {
        // Style 4: High-Contrast Static & Binary Glitch Noise
        vec3 threshold_rgb = step(vec3(0.5), rgb + (flash_hash - 0.5) * 0.4);
        rgb = mix(rgb, threshold_rgb * strobe_palette * 1.5, 0.60);
        if (is_corrupt_block > 0.5) {
            rgb = flash_color;
        }
    } else if (sec_mode == 5.0) {
        // Style 5: Emerald Green Matrix Cascade & Code Corruption
        float matrix_lines = sin(uv.y * 180.0 - fast_t * 4.0) * 0.5 + 0.5;
        vec3 green_code = vec3(0.1, 0.95, 0.3) * (matrix_lines * 1.4 + 0.4);
        rgb = mix(rgb * vec3(0.3, 1.2, 0.4), green_code, 0.45);
        if (is_corrupt_block > 0.5) {
            rgb = vec3(0.2, 1.0, 0.5);
        }
    } else if (sec_mode == 6.0) {
        // Style 6: Negative Acid Melt & Cyan-Magenta Inversion
        rgb = vec3(1.0) - rgb;
        rgb.rg = mix(rgb.rg, rgb.gr, 0.6 + 0.4 * sin(fast_t * 2.0));
        rgb *= vec3(0.8, 1.2, 1.5);
    } else {
        // Style 7: Deep Violet Quantum Warp & Strobe Silhouette
        rgb.rb = mix(rgb.rb, vec2(1.0, 0.3), 0.4 + 0.3 * sin(fast_t));
        rgb *= (sin(uv.y * 240.0) * 0.2 + 0.9);
        if (is_corrupt_block > 0.5) {
            rgb = mix(rgb, vec3(0.7, 0.2, 1.0), 0.8);
        }
    }

    // High frequency static burst
    float static_noise = g_hash(uv * 180.0 + vec2(fast_t * 1.3, -fast_t * 1.7));
    if (static_noise > 0.91) {
        rgb = mix(rgb, (flash_hash > 0.5 ? vec3(1.0) : flash_color), 0.85);
    }

    vec4 final_tex = vec4(rgb, alpha);
    return dissolve_mask(final_tex * colour, texture_coords, uv);
}
#endif
