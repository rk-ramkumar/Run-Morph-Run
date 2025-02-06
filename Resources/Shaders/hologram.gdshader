shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform vec4 hologram_color : source_color = vec4(0.0, 0.8, 1.0, 0.3);
uniform float scan_speed = 2.0;
uniform float scan_intensity = 0.02;
uniform float edge_glow_intensity = 1.5;

void fragment() {
    float scanline = sin(UV.y * 100.0 + TIME * scan_speed) * scan_intensity; 
    
    // Edge glow effect
    float edge = abs(NORMAL.y) * edge_glow_intensity;

    // Hologram color and transparency
    ALBEDO = hologram_color.rgb + edge;
    EMISSION = hologram_color.rgb * (1.5 + scanline);
    ALPHA = hologram_color.a * (0.3 + scanline); // Transparent but visible
}
