package pinball

import "core:fmt"
import raylib "vendor:raylib"
import "core:math"

Rect :: struct {
	e1, e2: Vector2,
	width: f32,
	height: f32
}

init_rect :: proc(r: ^Rect) {
	r.width = r.e2.x - r.e1.x
	r.height = r.e2.y - r.e1.y
}

rotate :: proc(v: Vector2, angle: f32) -> Vector2 {
	return {
		v.x * math.cos_f32(angle) - v.y * math.sin_f32(angle),
		v.x * math.sin_f32(angle) + v.y * math.cos_f32(angle)
	}
}

rotate_rect :: proc(r: ^Rect, angle: f32) {
	v := Vector2{   }
	r.e1 = rotate(r.e1, angle)
	r.e2 = rotate(r.e2, angle)
}

draw_rect :: proc(r: Rect, color: raylib.Color) {
	raylib.DrawTriangle(r.e1, Vector2{r.e1.x, r.e1.y + r.height}, r.e2, color)
	raylib.DrawTriangle(r.e1, r.e2, Vector2{r.e1.x + r.width, r.e1.y}, raylib.ORANGE)
}

Circle :: struct {
	position: Vector2,
	radius: f32
}

Ball :: struct {
	position: Vector2,
	radius: f32,
	color: raylib.Color,

	velocity: Vector2,
}

rect: Rect
ball: Ball
window_width := i32(800)
window_height := i32(600)


update :: proc(dt: f32) {

	ball.velocity.y = ball.velocity.y + (9.8 * dt)
	ball.position += ball.velocity

	c, n := collision(ball, rect)
	if (c) {
		fmt.println("COLLISION")
		y := rect.e1.y
		d := (ball.position.y + ball.radius) - y;
		ball.position.y = y - (d + ball.radius);

		n_v2 := Vector2{ n.x, n.y }
		r := ball.velocity - (2 * multiply(n_v2, dot_product(ball.velocity, n_v2)))
		ball.velocity = r
	}

	raylib.DrawCircle(cast(i32)ball.position.x, cast(i32)ball.position.y, ball.radius, ball.color)
	draw_rect(rect, raylib.BLUE)
}

main :: proc() {
	fmt.println("Starting application...");

	raylib.SetConfigFlags({.WINDOW_RESIZABLE});
	raylib.InitWindow(window_width, window_height, "Pinball");
	raylib.SetTargetFPS(60);

	rect.e1 = Vector2{ 0, cast(f32)window_height - 10 }
	rect.e2 = Vector2{ cast(f32)window_width, cast(f32)window_height }
	init_rect(&rect)
	//rotate_rect(&rect, 45.0 * (PI / 180.0))

	ball.velocity.x = 1
	ball.position = Vector2{400, 300}
	ball.radius = 50.0
	ball.color = raylib.RED

	for !raylib.WindowShouldClose() {
		raylib.BeginDrawing();
		raylib.ClearBackground(raylib.RAYWHITE);

		dt := raylib.GetFrameTime();
		update(dt);
		
		raylib.EndDrawing();
	}

	raylib.CloseWindow();
}
