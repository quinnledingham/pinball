package pinball

import "core:math"

collision_line_point :: proc(a: Vector2, b: Vector2, p: Vector2) -> (b8, Vector3)  {
	d1 := distance(p, a)
	d2 := distance(p, b)
	line_length := distance(a, b)
	buffer := f32(0.1)

	vec := Vector3{b.x - a.x, b.y - a.y, 0}
	normal := cross_product(vec, Vector3{0, 0, 1})

	if (d1+d2 >= line_length - buffer && d1+d2 <= line_length + buffer) {
		return true, normal
	}
	return false, normal
}

collision_point_circle :: proc(p: Vector2, circle: Circle) -> Collision {
	distance := distance(p, circle.position)
	if (distance <= circle.radius) {
		vec := p - circle.position
		return Collision{ true, Vector3{vec.x, vec.y, 0}, circle.radius - distance }
	}
	return Collision{ false, Vector3{0, 0, 0}, 0 }
}

collision_line_circle :: proc(a: Vector2, b: Vector2, circle: Circle) -> Collision {

	len := distance(a, b)
	dot := ( ((circle.position.x - a.x) * (b.x - a.x)) + ((circle.position.y - a.y) * (b.y - a.y)) ) / math.pow_f32(len, 2)

	closest: Vector2
	closest.x = a.x + (dot * (b.x - a.x))
	closest.y = a.y + (dot * (b.y - a.y))

	on_segment, normal := collision_line_point(a, b, closest)
	if (!on_segment) {
		return Collision{ false, normal, 0}
	}

	dist := distance(closest, circle.position)
	if (dist <= circle.radius) {
		vec := closest - circle.position
		return Collision{ true, Vector3{vec.x, vec.y, 0}, circle.radius - dist}
	}

	inside1 := collision_point_circle(a, circle)
	inside2 := collision_point_circle(b, circle)

	if inside1.active {
		return inside1
	}
	
	if inside2.active {
		return inside2
	}
	
	return Collision{ false, Vector3{0, 0, 0}, 0 }
}

collision_triangle_circle :: proc(vertices: [dynamic]Vector2, circle: Circle) -> Collision {

	next := 0
	tri_index := 0
	for current := 0; current < len(vertices); current += 1 {		
		
		next = current + 1
		if (tri_index == 2) {
			next = current - 2
			tri_index = 0
		} else {
			tri_index += 1 
		}
		
		vc := vertices[current]
		vn := vertices[next]
		
		c := collision_line_circle(vc, vn, circle)
		if c.active {
			return c
		}
		
	}
	
	return Collision{ false, Vector3{0, 0, 0}, 0 }
}

collision_polygon_circle :: proc(vertices: [dynamic]Vector2, circle: Circle) -> Collision {
	next := 0
	for current := 0; current < len(vertices); current += 1 {
		next = current + 1
		if (next == len(vertices)) {
			next = 0
		}

		vc := vertices[current]
		vn := vertices[next]

		c := collision_line_circle(vc, vn, circle)
		if (c.active) {
			return c
		}
	}
	
	return Collision{ false, Vector3{0, 0, 0}, 0 }
}

