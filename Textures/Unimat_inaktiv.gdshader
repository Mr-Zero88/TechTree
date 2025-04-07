// NOTE: Shader automatically converted from Godot Engine 4.4.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_RMS : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	UV = UV;
}

void fragment() {
	vec2 base_uv = UV;

	// float lightness = texture(texture_albedo, base_uv).xyz
	//ALBEDO = vec3(0.7, 0.7, 0.7) ;
	ALBEDO = texture(texture_albedo, base_uv).rgb * 0.1;

	vec4 RMS_tex = texture(texture_RMS, base_uv);

	METALLIC = RMS_tex.g;
	SPECULAR = 1.0;//RMS_tex.b;

	float roughness_tex = RMS_tex.r;
	ROUGHNESS = roughness_tex;
}
