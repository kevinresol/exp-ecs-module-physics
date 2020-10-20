package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.geometry.component.*;
import exp.ecs.module.physics.component.*;

private typedef Components = {
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

	public function new(nodes:NodeList<Components>) {
		nodes.bind(v -> this.nodes = v, tink.state.Scheduler.direct);
	}

	override function update(dt:Float) {
		// var removed = 0;
		for (node in nodes)
			if (node.entity.has(Collisions)) {
				node.entity.remove(Collisions);
				// removed++;
			}
		// trace('removed $removed out of ${nodes.length}');

		for (i in 0...nodes.length) {
			final node1 = nodes[i];
			final transform1 = node1.components.transform;
			final circle1 = node1.components.circle;
			final x1 = transform1.global.tx;
			final y1 = transform1.global.ty;

			for (j in i + 1...nodes.length) {
				final node2 = nodes[j];
				final transform2 = node2.components.transform;
				final circle2 = node2.components.circle;
				final x2 = transform2.global.tx;
				final y2 = transform2.global.ty;

				if (circle1 != null && circle2 != null) {
					final dx = x2 - x1;
					final dy = y2 - y1;
					final dist = circle1.radius + circle2.radius;
					if (dx * dx + dy * dy < dist * dist) {
						if (!node1.entity.has(Collisions))
							node1.entity.add(new Collisions([]));
						if (!node2.entity.has(Collisions))
							node2.entity.add(new Collisions([]));
						node1.entity.get(Collisions).with.push(node2.entity.id);
						node2.entity.get(Collisions).with.push(node1.entity.id);
					}
				}
			}
		}
	}

	public static function getNodes(world:World) {
		// @formatter:off
		return NodeList.generate(world, @:field(null) Collider && @:field(transform) Transform2 && (Rectangle || Circle));
		// @formatter:on
	}
}
