package exp.ecs.module.physics.system;

import exp.ecs.module.transform.component.*;
import exp.ecs.module.physics.component.*;

private typedef Components = {
	final velocity:AngularVelocity2;
	final transform:Transform2;
}

/**
 * Rotate in 2D
 */
@:nullSafety(Off)
class Rotate2 extends exp.ecs.system.SingleListSystem<Components> {
	public function new() {
		super(NodeList.spec(@:component(velocity) AngularVelocity2 && @:component(transform) Transform2));
	}

	override function update(dt:Float) {
		for (node in nodes) {
			final velocity = node.data.velocity;
			node.data.transform.rotation += velocity.value * dt;
		}
	}
}
