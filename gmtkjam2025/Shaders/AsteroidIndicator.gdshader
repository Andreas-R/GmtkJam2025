shader_type canvas_item;

const float STEPS = 100.0;

varying vec4 MODULATE;

void vertex() {
	MODULATE = COLOR;
}

void fragment() {
    float y = abs(UV.y - 0.5);
	float t = (UV.x - TIME / STEPS * 2.0) * STEPS + y * 0.25;
    float s = floor(t);
    float a = t - s;
    COLOR = MODULATE * vec4(1.0, 1.0, 1.0, a);
}
