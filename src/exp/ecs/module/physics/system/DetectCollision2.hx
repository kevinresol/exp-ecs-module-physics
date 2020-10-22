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
@:analyzer(no_local_dce)
@:nullSafety(Off)
class DetectCollision2 extends System {
	var nodes:Array<Node<Components>>;

	final tree:QuadTree<Node<Components>>;

	public function new(nodes:NodeList<Components>, width, height, maxElements, maxDepth) {
		nodes.bind(v -> this.nodes = v, tink.state.Scheduler.direct);
		tree = new QuadTree(width, height, maxElements, maxDepth);
	}

	override function update(dt:Float) {
		tree.clear();

		for (node in nodes) {
			// reset collisions
			node.components.collider.with.resize(0);

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
				final transform1 = node1.components.transform;
				final circle1 = node1.components.circle;
				final x1 = transform1.global.tx;
				final y1 = transform1.global.ty;

				for (j in i + 1...length) {
					final node2 = elements[j].data;
					final transform2 = node2.components.transform;
					final circle2 = node2.components.circle;
					final x2 = transform2.global.tx;
					final y2 = transform2.global.ty;

					if (circle1 != null && circle2 != null) {
						final dx = x2 - x1;
						final dy = y2 - y1;
						final dist = circle1.radius + circle2.radius;
						if (dx * dx + dy * dy < dist * dist) {
							node1.entity.get(Collider).with.push(node2.entity.id);
							node2.entity.get(Collider).with.push(node1.entity.id);
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
