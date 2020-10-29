package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.physics.component.*;

private typedef Components = {
	final mass:Mass;
	final force:Force2;
	final velocity:Velocity2;
}

/**
 * Apply force in 2D
 */
@:nullSafety(Off)
class ApplyForce2 extends exp.ecs.system.SingleListSystem<Components> {
	override function update(dt:Float) {
		for (node in nodes) {
			final force = node.data.force;
			final mass = node.data.mass.value;
			final velocity = node.data.velocity;
			velocity.x += force.x / mass * dt;
			velocity.y += force.y / mass * dt;
		}
	}

	public static function getSpec() {
		// @formatter:off
		return NodeList.spec(
			Mass &&
			@:component(force) Force2 &&
			@:component(velocity) Velocity2
		);
		// @formatter:on
	}
}
