package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.physics.component.*;
import exp.spatial.QuadTree;

private typedef Components = {
	final collider:Collider;
	final transform:Transform2;
	final ?point:HitPoint;
	final ?circle:HitCircle;
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
			&& (@:component(circle) ~HitCircle || @:component(point) ~HitPoint)));
		this.tree = new QuadTree(width, height, maxElements, maxDepth);
	}

	override function update(dt:Float) {
		tree.clear();

		for (node in nodes) {
			// insert to quadtree
			final transform = node.data.transform;
			final x = transform.global.tx;
			final y = transform.global.ty;
			switch node.data.circle {
				case null:
				case circle:
					final radius = circle.radius;
					tree.insert(node, x - radius, y - radius, x + radius, y + radius);
			}
			switch node.data.point {
				case null:
				case point:
					tree.insert(node, x, y, x, y);
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
		final transform1 = node1.data.transform;
		final transform2 = node2.data.transform;
		final x1 = transform1.global.tx;
		final y1 = transform1.global.ty;
		final x2 = transform2.global.tx;
		final y2 = transform2.global.ty;
		final dx = x2 - x1;
		final dy = y2 - y1;

		inline function getRange(node:Node<Components>) {
			return switch node.data.circle {
				case null: 0;
				case circle: circle.radius;
			}
		}

		final range = getRange(node1) + getRange(node2);

		return dx <= range && dy <= range && dx * dx + dy * dy < range * range;
	}
}
