//shader_type spatial;
//render_mode unshaded, cull_disabled;
//
//uniform sampler2D portal_texture;
//uniform vec4 frame_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
//uniform float frame_width : hint_range(0.0, 0.5) = 0.1;
//uniform float corner_length : hint_range(0.1, 1.0) = 0.3;
//
//// Varyings for screen position and normal
//varying vec4 screen_pos;
//varying vec3 view_normal;
//varying vec3 world_normal;
//varying vec3 world_position;
//
//void vertex() {
    //// Calculate screen position for fragment shader
    //screen_pos = PROJECTION_MATRIX * VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0);
    //
    //// Pass normal and position for front/back face determination
    //world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    //world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    //view_normal = (VIEW_MATRIX * vec4(world_normal, 0.0)).xyz;
//}
//
//bool is_in_corner_frame(vec2 uv, float frame_w, float corner_len) {
    //// Convert UV to -0.5 to 0.5 range for easier calculation
    //vec2 pos = uv - 0.5;
    //vec2 abs_pos = abs(pos);
    //
    //// Check if we're near any edge
    //bool near_edge_x = abs_pos.x > 0.5 - frame_w;
    //bool near_edge_y = abs_pos.y > 0.5 - frame_w;
    //
    //// Check if we're in corner region (within corner_length from corner)
    //bool in_corner_x = abs_pos.x > 0.5 - corner_len;
    //bool in_corner_y = abs_pos.y > 0.5 - corner_len;
    //
    //// L-shaped corner: show frame if we're near an edge AND in corner region
    //// Also show frame in the center area between corners
    //bool horizontal_frame = near_edge_x && (in_corner_x || (!in_corner_y && abs_pos.y < 0.5 - frame_w + corner_len));
    //bool vertical_frame = near_edge_y && (in_corner_y || (!in_corner_x && abs_pos.x < 0.5 - frame_w + corner_len));
    //
    //return horizontal_frame || vertical_frame;
//}
//
//void fragment() {
    //// Determine if we're looking at the front face (portal side)
    //vec3 view_direction = normalize(world_position - VIEW_MATRIX[3].xyz);
    //bool is_front_face = dot(view_direction, world_normal) < 0.0;
    //
    //if (is_front_face) {
        //// Front face: show portal texture using screen-space coordinates
        //vec2 screen_uv = (screen_pos.xy / screen_pos.w) * 0.5 + 0.5;
        //vec4 tex_color = texture(portal_texture, screen_uv);
        //ALBEDO = tex_color.rgb;
        //ALPHA = tex_color.a;
    //} else {
        //// Back face: show L-shaped corner frames using mesh UVs
        //if (is_in_corner_frame(UV, frame_width, corner_length)) {
            //ALBEDO = frame_color.rgb;
            //ALPHA = frame_color.a;
        //} else {
            //// Center area is transparent/black
            //ALBEDO = vec3(0.0, 0.0, 0.0);
            //ALPHA = 0.0;
        //}
    //}
//}

shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D portal_texture;
uniform vec4 inactive_colour : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int display_mask : hint_range(0, 1) = 1; // set to 1 to display texture, otherwise will draw inactive colour

varying vec4 screen_pos;

void vertex() {
    // Calculate screen position for fragment shader
    screen_pos = PROJECTION_MATRIX * VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0);
}

void fragment() {
    // Convert screen position to UV coordinates (0-1 range)
    vec2 screen_uv = (screen_pos.xy / screen_pos.w) * 0.5 + 0.5;
    
    // Sample the portal texture
    vec4 portal_color = texture(portal_texture, screen_uv);
    
    // Blend between portal texture and inactive color based on display_mask
    vec4 final_color = portal_color * float(display_mask) + inactive_colour * float(1 - display_mask);
    
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}