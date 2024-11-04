package pinball

import "core:math"

collision_point_circle :: proc(p: Vector2, circle: Circle) -> b8 {
	distance := distance(p, circle.position)
	if (distance <= circle.radius) {
		return true
	}
	return false
}

collision_line_circle :: proc(a: Vector2, b: Vector2, circle: Circle) -> b8 {
	inside1 := collision_point_circle(a, circle)
	inside2 := collision_point_circle(b, circle)
	if (inside1 || inside2) {
		return true
	}

	len := distance(a, b)
	dot := ( ((circle.position.x - a.x) * (b.x - a.x)) + ((circle.position.y - a.y) * (b.y - a.y)) ) / math.pow_f32(len, 2)

	return false
}

collision_polygon_circle :: proc(vertices: []Vector2, circle: Circle) -> b8 {
	next := 0
	for current := 0; current < len(vertices); current += 1 {
		next = current + 1
		if (next == len(vertices)) {
			next = 0
		}

		vc := vertices[current]
		vn := vertices[next]

		collision := collision_line_circle(vc, vn, circle)
		if (collision) {
			return true
		}
	}
	
	return false
}

collision :: proc(ball: Ball, r: Rect) -> (b8, Vector3) {
	test_x := ball.position.x
	test_y := r.e1.y
	
	if (ball.position.x < r.e1.x) {
		test_x = r.e1.x // test left edge
	} else if (ball.position.x > r.e2.x) {
		test_x = r.e2.x // right edge
	}

	if (ball.position.y < r.e1.y) {
		test_y = r.e1.y // top edge
	} else if (ball.position.y > r.e2.y) {
		test_y = r.e2.y // bottom edge
	}

	// get distance from closest edges
	dist_x := ball.position.x - test_x
	dist_y := ball.position.y - test_y
	distance := math.sqrt_f32((dist_x * dist_x) + (dist_y * dist_y))

	// if the distance is less than the radius, collision!
	if (distance <= ball.radius) {
		normal := cross_product(Vector3{1, 0, 0}, Vector3{0, 0, 1})
		
		return true, normal;
	}
	
	return false, Vector3{0, 0, 0};
}
