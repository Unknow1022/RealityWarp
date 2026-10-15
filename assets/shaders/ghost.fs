#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif

extern PRECISION vec2 ghost;
extern PRECISION float time;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
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

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 orig_tex = Texel(texture, texture_coords);
    if (orig_tex.a <= 0.0) {
        return vec4(0.0);
    }

    vec2 uv = (((texture_coords) * (image_details)) - texture_details.xy * texture_details.ba) / texture_details.ba;
    float curr_t = (time > 0.0 ? time : (ghost.y != 0.0 ? ghost.y : 1.0));

    // Luminosity of the original pixel
    float lum = dot(orig_tex.rgb, vec3(0.299, 0.587, 0.114));

    // Invisible Joker authentic ghostly palette:
    // Outlines: soft spectral teal (118, 164, 175)
    // Artwork & folds: ethereal ice-cyan and pale spectral silver
    // Card canvas & bright whites: luminous translucent white (252, 254, 255)
    vec3 c_outline  = vec3(0.463, 0.643, 0.686); // Soft ghostly teal outline
    vec3 c_mid_low  = vec3(0.612, 0.780, 0.843); // Ethereal ice-cyan
    vec3 c_mid_high = vec3(0.733, 0.875, 0.918); // Pale spectral cyan-silver
    vec3 c_canvas   = vec3(0.970, 0.985, 1.000); // Luminous white card canvas

    vec3 ghost_base;
    if (lum <= 0.38) {
        ghost_base = mix(c_outline * 0.88, c_outline, lum / 0.38);
    } else if (lum < 0.90) {
        float t = (lum - 0.38) / (0.90 - 0.38);
        ghost_base = mix(c_mid_low, c_mid_high, t);
    } else {
        float t = (lum - 0.90) / 0.10;
        ghost_base = mix(c_mid_high, c_canvas, t);
    }

    // Preserve a delicate trace (12%) of the card's original color identity
    vec3 ghost_rgb = mix(ghost_base, orig_tex.rgb, 0.12);

    // Ethereal ghostly wave shimmer (flowing diagonally across the card like Invisible Joker / Voucher)
    float wave1 = sin((uv.x + uv.y * 0.75) * 8.0 - curr_t * 1.8);
    float wave2 = cos((uv.x * 1.3 - uv.y) * 11.0 + curr_t * 2.2);
    float spectral_band = clamp(wave1 * 0.5 + 0.5, 0.0, 1.0);
    float shimmer = pow(spectral_band, 3.0) * 0.18 + (wave2 * 0.5 + 0.5) * 0.05;

    // Glowing spectral cyan highlights on wave crests
    vec3 spectral_glow = vec3(0.35, 0.75, 0.95);
    ghost_rgb += spectral_glow * shimmer;

    // Translucency matching Invisible Joker (~0.76 base alpha with gentle breathing pulse)
    float pulse = sin(curr_t * 1.6 + uv.y * 3.0) * 0.04;
    float ghost_alpha = orig_tex.a * clamp(0.76 + pulse + shimmer * 0.12, 0.55, 0.88);

    vec4 final_tex = vec4(ghost_rgb, ghost_alpha);
    return dissolve_mask(final_tex * colour, texture_coords, uv);
}
#endif
