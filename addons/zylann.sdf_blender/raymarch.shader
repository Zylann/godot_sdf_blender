shader_type spatial;
//render_mode unshaded;//, depth_draw_alpha_prepass;

//<uniforms>
//</uniforms>

const int MAX_STEPS = 64;
const float MAX_DISTANCE = 100.0;
const float SURFACE_DISTANCE = 0.005;
const float NORMAL_PRECISION = 0.0005;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

float get_sphere(vec3 p, vec3 center, float radius) {
	return length(p - center) - radius;
}

float get_box(vec3 p, vec3 b) {
	vec3 q = abs(p) - b;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float get_rounded_box(vec3 p, vec3 b, float r) {
	vec3 q = abs(p) - b;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float get_torus(vec3 p, vec2 r) {
	vec2 q = vec2(length(p.xz) - r.x, p.y);
	return length(q) - r.y;
}

float get_rounded_cylinder(vec3 p, float radius, float rounding, float h) {
	vec2 d = vec2(length(p.xz) - radius + rounding, abs(p.y) - h);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - rounding;
}

// Note: `union` is a reserved keyword but Godot doesn't seem to catch that
float sharp_union(float a, float b) {
	return min(a, b);
}

float smooth_union(float a, float b, float k) {
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return mix(b, a, h) - k * h * (1.0 - h);
}

vec4 smooth_union_c(float da, float db, vec3 ca, vec3 cb, float k) {
	float h = clamp(0.5 + 0.5 * (db - da) / k, 0.0, 1.0);
	float d = mix(db, da, h) - k * h * (1.0 - h);
	vec3 col = mix(cb, ca, h);
	return vec4(col, d);
}

vec3 smooth_color(float da, float db, vec3 ca, vec3 cb, float k) {
	float h = clamp(0.5 + 0.5 * (db - da) / k, 0.0, 1.0);
	vec3 col = mix(cb, ca, h);
	return col;
}

vec4 smooth_subtract_c(float db, float da, vec3 ca, vec3 cb, float k) {
	float h = clamp(0.5 - 0.5 * (db + da) / k, 0.0, 1.0);
    float d = mix(db, -da, h) + k * h * (1.0 - h);
	vec3 col = mix(ca, cb, h);
	return vec4(col, d);
}

float subtract(float a, float b) {
	return max(a, -b);
}

float intersect(float a, float b) {
	return max(a, b);
}

vec3 repeat_domain_inf(vec3 p, vec3 c) {
	return mod(p + 0.5 * c, c) - 0.5 * c;
}

vec3 repeat_domain(vec3 p, vec3 c, vec3 l) {
	return p - c * clamp(round(p / c), -l, l);
}

//<functions>
//</functions>

vec4 get_scene(vec3 p, float time) {
	vec4 s = vec4(1.0, 1.0, 1.0, 99999.0);
	
	//<scene>
	s.w = sharp_union(s.w, get_sphere(p, vec3(0.0), 1.0));
	s.w = subtract(s.w, get_sphere(p, vec3(1.0, 0.0, 0.0), 0.8));
	p = repeat_domain(p, vec3(3.0), vec3(5.0, 0.0, 0.0));
	s = smooth_union_c(s.w, get_box(p, vec3(0.1, 0.5, 1.5)), s.rgb, vec3(1.0, 0.0, 0.0), 0.3);
	s.w = subtract(s.w, get_sphere(p, vec3(0.6, 0.2, 0.5), 0.4));
	s = smooth_subtract_c(s.w, get_sphere(p, vec3(0.3, 0.0, 1.5), 0.5), s.rgb, vec3(0.0, 1.0, 0.0), 0.1);
	//</scene>
	
	return s;
}

vec3 get_normal(vec3 p, float time) {
	float d = get_scene(p, time).w;
	vec2 e = vec2(NORMAL_PRECISION, 0.0);
	vec3 n = d - vec3(
		get_scene(p - e.xyy, time).w,
		get_scene(p - e.yxy, time).w,
		get_scene(p - e.yyx, time).w);
	return normalize(n);
}

vec4 raymarch(vec3 ray_origin, vec3 ray_dir, out vec3 out_normal, float time) {
	// Sphere marching
	float d = 0.0;
	vec3 rgb;
	for (int i = 0; i < MAX_STEPS; ++i) {
		vec3 p = ray_origin + ray_dir * d;
		vec4 scene_info = get_scene(p, time);
		rgb = scene_info.rgb;
		float ds = scene_info.w;
		d += ds;
		if (d > MAX_DISTANCE || ds < SURFACE_DISTANCE) {
			break;
		}
	}

	vec3 hit_pos = ray_origin + ray_dir * d;
	out_normal = get_normal(hit_pos, time);

	return vec4(rgb, d);
}

float linear_depth_to_depth(float linear_depth, mat4 projection_matrix) {
	vec4 clip_space_pos = projection_matrix * vec4(0.0, 0.0, linear_depth, 1.0);
	float ndc_depth = clip_space_pos.z / clip_space_pos.w;
	return ndc_depth * 0.5 + 0.5;
}

void fragment() {
	// Could certainly be optimized I think
	vec3 ndc = vec3(SCREEN_UV, 0.0) * 2.0 - 1.0;
	vec4 view_coords = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_coords.xyz /= view_coords.w;
	vec3 world_cam_pos = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec4 world_coords = CAMERA_MATRIX * vec4(view_coords.xyz, 1.0);
	
	vec3 ray_origin = world_coords.xyz;
	vec3 ray_dir = normalize(world_coords.xyz - world_cam_pos);
	
	float time = 0.0;
	
	vec3 normal;
	vec4 rm = raymarch(ray_origin, ray_dir, normal, time);
	float d = rm.w;

	// TODO Why the fuck is this not working?
	// That 1/x is not right, but somehow it does something almost right?
	DEPTH = 1.0/linear_depth_to_depth(d, PROJECTION_MATRIX);
	if (d > 99.0) {
		discard;
	}
	
	NORMAL = (INV_CAMERA_MATRIX * vec4(normal, 0.0)).xyz;
	
	//ALBEDO = ray_dir * 0.1;
	ALBEDO = rm.rgb;
	//ALBEDO = normal;
	/*if(d > 0.0) {
		ALBEDO = vec3(0.0, 1.0, 0.0);
	}*/
}