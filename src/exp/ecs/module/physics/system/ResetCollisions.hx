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
	public function new() {
		super(NodeList.spec(Collider));
	}

	override function update(dt:Float) {
		for (node in nodes)
			node.data.collider.hits.resize(0);
	}
}
