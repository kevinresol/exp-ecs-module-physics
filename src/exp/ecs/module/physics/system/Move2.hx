package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.physics.component.*;

private typedef Components = {
	final velocity:Velocity2;
	final transform:Transform2;
}

/**
 * Move in 2D
 */
@:nullSafety(Off)
class Move2 extends exp.ecs.system.SingleListSystem<Components> {
	override function update(dt:Float) {
		for (node in nodes) {
			final velocity = node.data.velocity;
			final position = node.data.transform.position;
			position.x += velocity.x * dt;
			position.y += velocity.y * dt;
		}
	}

	public static function getSpec() {
		// @formatter:off
		return NodeList.spec(
			@:component(velocity) Velocity2 &&
			@:component(transform) Transform2
		);
		// @formatter:on
	}
}
