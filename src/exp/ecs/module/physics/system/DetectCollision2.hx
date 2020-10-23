package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.geometry.component.*;
import exp.ecs.module.physics.component.*;
import exp.spatial.QuadTree;

private typedef Components = {
	final collider:Collider;
	final transform:Transform2;
	final rectangle:Rectangle;
	final circle:Circle;
}

/**
 * Move in 2D
 */
@:nullSafety(Off)
class DetectCollision2 extends System {
	final list:NodeList<Components>;
	var nodes:Array<Node<Components>>;

	final tree:QuadTree<Node<Components>>;

	public function new(list, width, height, maxElements, maxDepth) {
		this.list = list;
		tree = new QuadTree(width, height, maxElements, maxDepth);
	}

	override function initialize() {
		return list.bind(v -> nodes = v, tink.state.Scheduler.direct);
	}

	override function update(dt:Float) {
		tree.clear();

		for (node in nodes) {
			// insert to quadtree
			final transform = node.components.transform;
			final x = transform.global.tx;
			final y = transform.global.ty;
			final radius = node.components.circle.radius;
			tree.insert(node, x - radius, y - radius, x + radius, y + radius);
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
				final collider1 = node1.components.collider;
				final transform1 = node1.components.transform;
				final circle1 = node1.components.circle;
				final x1 = transform1.global.tx;
				final y1 = transform1.global.ty;

				for (j in i + 1...length) {
					final node2 = elements[j].data;
					final circle2 = node2.components.circle;

					if (circle1 != null && circle2 != null) {
						final collider2 = node2.components.collider;
						final canCollideWith2 = collider1.canCollideWith(collider2);
						final canCollideWith1 = collider2.canCollideWith(collider1);

						if (canCollideWith2 || canCollideWith1) {
							final transform2 = node2.components.transform;
							final x2 = transform2.global.tx;
							final y2 = transform2.global.ty;
							final dx = x2 - x1;
							final dy = y2 - y1;
							final range = circle1.radius + circle2.radius;

							if (dx <= range && dy <= range && dx * dx + dy * dy < range * range) {
								if (canCollideWith2 && !collider1.hits.contains(node2.entity.id))
									collider1.hits.push(node2.entity.id);

								if (canCollideWith1 && !collider2.hits.contains(node2.entity.id))
									collider2.hits.push(node1.entity.id);
							}
						}
					}
				}
			}
		}
	}

	public static function getNodes(world:World) {
		// @formatter:off
		return NodeList.generate(world, Collider && @:field(transform) Transform2 && (Rectangle || Circle));
		// @formatter:on
	}
}
