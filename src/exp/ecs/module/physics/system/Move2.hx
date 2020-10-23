package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.physics.component.*;

private typedef Components = {
	final velocity:Velocity2;
	final position:Position2;
}

/**
 * Move in 2D
 */
@:nullSafety(Off)
class Move2 extends System {
	final list:NodeList<Components>;
	var nodes:Array<Node<Components>>;

	public function new(list) {
		this.list = list;
	}

	override function initialize() {
		return list.bind(v -> nodes = v, tink.state.Scheduler.direct);
	}

	override function update(dt:Float) {
		for (node in nodes) {
			final velocity = node.components.velocity;
			final position = node.components.position;
			position.x += velocity.x * dt;
			position.y += velocity.y * dt;
		}
	}

	public static function getNodes(world:World) {
		// @formatter:off
		return NodeList.generate(world,
			@:field(velocity) Velocity2 &&
			@:field(position) Position2
		);
		// @formatter:on
	}
}
