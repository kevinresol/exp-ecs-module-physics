package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.physics.component.*;

private typedef Components = {
	final velocity:AngularVelocity2;
	final rotation:Rotation2;
}

/**
 * Rotate in 2D
 */
@:nullSafety(Off)
class Rotate2 extends System {
	var nodes:Array<Node<Components>>;

	public function new(nodes:NodeList<Components>) {
		nodes.bind(v -> this.nodes = v, tink.state.Scheduler.direct);
	}

	override function update(dt:Float) {
		for (node in nodes) {
			final velocity = node.components.velocity;
			final rotation = node.components.rotation;
			rotation.angle += velocity.value * dt;
		}
	}

	public static function getNodes(world:World) {
		// @formatter:off
		return NodeList.generate(world,
			@:field(velocity) AngularVelocity2 &&
			@:field(rotation) Rotation2
		);
		// @formatter:on
	}
}
