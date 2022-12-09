package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.physics.component.*;
import exp.spatial.QuadTree;

private typedef Components = {
	final collider:Collider;
	final transform:Transform2;
	final ?point:HitPoint;
	final ?circle:HitCircle;
	final ?rectangle:HitRectangle;
}

/**
 * Move in 2D
 */
@:nullSafety(Off)
class DetectCollision2 extends exp.ecs.system.SingleListSystem<Components> {
	final tree:QuadTree<Node<Components>>;

	public function new(width, height, maxElements, maxDepth) {
		super(NodeList.spec(Collider
			&& @:component(transform) Transform2
			&& (@:component(point) HitPoint || @:component(circle) HitCircle || @:component(rectangle) HitRectangle)));
		this.tree = new QuadTree(width, height, maxElements, maxDepth);
	}

	override function update(dt:Float) {
		tree.clear();

		for (node in nodes) {
			// insert to quadtree
			final transform = node.data.transform;
			final x = transform.global.tx;
			final y = transform.global.ty;
			switch node.data.point {
				case null:
				case point:
					tree.insert(node, x, y, x, y);
			}
			switch node.data.circle {
				case null:
				case circle:
					final radius = circle.radius;
					tree.insert(node, x - radius, y - radius, x + radius, y + radius);
			}
			switch node.data.rectangle {
				case null:
				case rectangle:
					final dx = rectangle.width / 2;
					final dy = rectangle.height / 2;
					tree.insert(node, x - dx, y - dy, x + dx, y + dy);
			}
		}

		// traverse tree and check for collisions
		tree.traverse(visitor);
	}

	static function visitor(quad:QuadNode<Node<Components>>) {
		if (quad.isLeaf) {
			final elements = quad.elements;
			final length = elements.length;

			for (i in 0...length) {
				final node1 = elements[i].data;
				final collider1 = node1.data.collider;

				for (j in i + 1...length) {
					final node2 = elements[j].data;
					final collider2 = node2.data.collider;
					final canCollideWith2 = collider1.canCollideWith(collider2);
					final canCollideWith1 = collider2.canCollideWith(collider1);

					if (canCollideWith2 || canCollideWith1) {
						if (overlaps(node1, node2)) {
							if (canCollideWith2 && !collider1.hits.contains(node2.entity.id))
								collider1.hits.push(node2.entity.id);

							if (canCollideWith1 && !collider2.hits.contains(node1.entity.id))
								collider2.hits.push(node1.entity.id);
						}
					}
				}
			}
		}
	}

	static function overlaps(node1:Node<Components>, node2:Node<Components>) {
		return switch [getType(node1), getType(node2)] {
			case [None, _] | [_, None]:
				false;
			case [Point, Point]:
				// @formatter:off
				final x1 = node1.data.transform.global.tx;
				final y1 = node1.data.transform.global.ty;
				final x2 = node2.data.transform.global.tx;
				final y2 = node2.data.transform.global.ty;
				x1 == x2 && y1 == y2;
				// @formatter:on
			case [Point, Circle]:
				pointInCircle(node1, node2);
			case [Circle, Point]:
				pointInCircle(node2, node1);
			case [Circle, Circle]:
				circleOverlaps(node1, node2);
			case [Point, Rectangle]:
				pointInRect(node1, node2);
			case [Rectangle, Point]:
				pointInRect(node2, node1);
			case [Rectangle, Rectangle]:
				rectangleOverlaps(node1, node2);
			case [Rectangle, Circle]:
				false; // TODO
			case [Circle, Rectangle]:
				false; // TODO
			case [t1, t2]:
				trace('Unhandled collision types: [$t1, $t2]');
				false; // TODO
		}
	}

	static function getType(node:Node<Components>):HitType {
		return if (node.data.point != null) Point; else if (node.data.circle != null) Circle; else if (node.data.rectangle != null) Rectangle; else None;
	}

	static function getRange(node:Node<Components>) {
		return switch node.data.circle {
			case null: 0;
			case circle: circle.radius;
		}
	}

	static function pointInRect(point:Node<Components>, rect:Node<Components>) {
		// TODO: properly handle rect transformations
		final px = point.data.transform.global.tx;
		final py = point.data.transform.global.ty;
		final rx = rect.data.transform.global.tx;
		final ry = rect.data.transform.global.ty;
		final rw = rect.data.rectangle.width / 2;
		final rh = rect.data.rectangle.height / 2;
		return px >= rx - rw && px <= rx + rw && py >= ry - rh && py <= ry + rh;
	}

	static function pointInCircle(point:Node<Components>, circle:Node<Components>) {
		// TODO: properly handle circle transformations
		final px = point.data.transform.global.tx;
		final py = point.data.transform.global.ty;
		final cx = circle.data.transform.global.tx;
		final cy = circle.data.transform.global.ty;
		final dx = cx - px;
		final dy = cy - py;
		final r = circle.data.circle.radius;
		return dx * dx + dy * dy < r * r;
	}

	static function circleOverlaps(node1:Node<Components>, node2:Node<Components>) {
		// TODO: properly handle transformations
		final x1 = node1.data.transform.global.tx;
		final y1 = node1.data.transform.global.ty;
		final x2 = node2.data.transform.global.tx;
		final y2 = node2.data.transform.global.ty;
		final dx = x2 - x1;
		final dy = y2 - y1;
		final range = node1.data.circle.radius + node2.data.circle.radius;
		return dx <= range && dy <= range && dx * dx + dy * dy < range * range;
	}

	static function rectangleOverlaps(node1:Node<Components>, node2:Node<Components>) {
		// TODO: properly handle transformations
		final x1 = node1.data.transform.global.tx;
		final y1 = node1.data.transform.global.ty;
		final x2 = node2.data.transform.global.tx;
		final y2 = node2.data.transform.global.ty;
		final w1 = node1.data.rectangle.width;
		final h1 = node1.data.rectangle.height;
		final w2 = node2.data.rectangle.width;
		final h2 = node2.data.rectangle.height;

		final tlx1 = x1 - w1 / 2;
		final tly1 = y1 - h1 / 2;
		final brx1 = x1 + w1 / 2;
		final bry1 = y1 + h1 / 2;
		final tlx2 = x2 - w2 / 2;
		final tly2 = y2 - h2 / 2;
		final brx2 = x2 + w2 / 2;
		final bry2 = y2 + h2 / 2;

		// if rectangle has area 0, no overlap
		if (tlx1 == brx1 || tly1 == bry1 || brx2 == tlx2 || tly2 == bry2)
			return false;

		// If one rectangle is on left side of other
		if (tlx1 > brx2 || tlx2 > brx1) {
			return false;
		}

		// If one rectangle is above other
		if (bry1 > tly2 || bry2 > tly1) {
			return false;
		}

		return true;
	}
}

private enum abstract HitType(Int) {
	final None;
	final Point;
	final Circle;
	final Rectangle;
}
