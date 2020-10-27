package exp.ecs.module.physics.system;

import exp.ecs.module.physics.component.*;

private typedef Components = {
	final collider:Collider;
}

/**
 * Reset collision array
 */
@:nullSafety(Off)
class ResetCollisions extends exp.ecs.system.SingleListSystem<Components> {
	override function update(dt:Float) {
		for (node in nodes)
			node.components.collider.hits.resize(0);
	}

	public static function getSpec() {
		return NodeList.spec(Collider);
	}
}
