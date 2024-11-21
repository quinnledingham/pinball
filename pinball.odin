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

draw_rect :: proc(r: []Vector2, color: raylib.Color) {
	raylib.DrawTriangle(r[0], r[2], r[3], color)
	raylib.DrawTriangle(r[0], r[3], r[1], raylib.ORANGE)
}

draw_triangles :: proc(t: [dynamic]Vector2, color: raylib.Color) {
	for vertex_index := 0; vertex_index < len(t); vertex_index += 3 {
		raylib.DrawTriangle(t[vertex_index], t[vertex_index + 1], t[vertex_index + 2], color)
	}
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

Collision :: struct {
	active: b8,
	normal: Vector3,
	amount: f32, // how far it collided
}

ball: Ball
window_width := i32(800)
window_height := i32(600)

triangles: [dynamic]Vector2

/*
a00000
000000
00000b
*/
create_rect :: proc(a: Vector2, b: Vector2) -> [6]Vector2 {
	top_left := a
	bottom_right := b
	top_right := Vector2{ b.x, a.y }
	bottom_left := Vector2{ a.x, b.y }
	
	arr := [6]Vector2{
		top_left,
		bottom_left,
		bottom_right,

		top_left,
		bottom_right,
		top_right,
	}

	return arr
}

update :: proc(dt: f32) {

	if (raylib.IsMouseButtonDown(raylib.MouseButton.LEFT)) {
		ball.position.x = cast(f32)raylib.GetMouseX()
		ball.position.y = cast(f32)raylib.GetMouseY()
		ball.velocity = Vector2{0, 0}
	}

	ball.velocity.y = ball.velocity.y + (9.8 * dt)
	ball.position += ball.velocity

	circle := Circle{ ball.position, ball.radius }
	c := collision_triangle_circle(triangles, circle)
		
	if (c.active) {
		c.normal = normalized(c.normal)
		ball.velocity = ball.velocity - 2 * multiply(c.normal.xy, dot_product(ball.velocity, c.normal.xy))
		ball.velocity = multiply(ball.velocity, 0.9)
		ball.position += c.amount * normalized(ball.velocity)
	}

	raylib.DrawCircle(cast(i32)ball.position.x, cast(i32)ball.position.y, ball.radius, ball.color)
	draw_triangles(triangles, raylib.BLUE)
}

main :: proc() {
	fmt.println("Starting application...");

	raylib.SetConfigFlags({.WINDOW_RESIZABLE});
	raylib.InitWindow(window_width, window_height, "Pinball");
	raylib.SetTargetFPS(60);

	r1 := create_rect(Vector2{ 0, 0 }, Vector2{ cast(f32)window_width, 5 })
	r2 := create_rect(Vector2{ 0, 0 }, Vector2{ 5, cast(f32)window_height })
	r3 := create_rect(Vector2{ cast(f32)window_width - 5, 0 }, Vector2{ cast(f32)window_width, cast(f32)window_height })
	r4 := create_rect(Vector2{ 0, cast(f32)window_height - 5 }, Vector2{ cast(f32)window_width, cast(f32)window_height })
	append(&triangles, ..r1[:])
	append(&triangles, ..r2[:])
	append(&triangles, ..r3[:])
	append(&triangles, ..r4[:])

	right_slope := []Vector2{ 
		Vector2{ cast(f32)window_width, cast(f32)window_height - 300 }, 
		Vector2{ cast(f32)window_width - 300, cast(f32)window_height},
		Vector2{ cast(f32)window_width, cast(f32)window_height }, 
	}
	append(&triangles, ..right_slope[:])
	
	left_slope := []Vector2{ 
		Vector2{ 0, cast(f32)window_height - 300 }, 
		Vector2{ 0, cast(f32)window_height }, 
		Vector2{ 300, cast(f32)window_height},
	}
	append(&triangles, ..left_slope[:])
	
	for vertex_index := 0; vertex_index < len(triangles); vertex_index += 1 {
		fmt.println(triangles[vertex_index])
	}
	
	ball.velocity.x = 1
	ball.position = Vector2{400, 300}
	ball.radius = 30.0
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
