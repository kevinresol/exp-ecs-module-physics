package exp.ecs.module.physics.system;

import exp.ecs.module.physics.component.*;

private typedef Components = {
	final collider:Collider;
}

/**
 * Reset collision array
 */
@:nullSafety(Off)
class ResetCollisions extends System {
	final list:NodeList<Components>;
	var nodes:Array<Node<Components>>;

	public function new(list) {
		this.list = list;
	}

	override function initialize() {
		return list.bind(v -> nodes = v, tink.state.Scheduler.direct);
	}

	override function update(dt:Float) {
		for (node in nodes)
			node.components.collider.hits.resize(0);
	}

	public static function getNodes(world:World) {
		return NodeList.generate(world, Collider);
	}
}
