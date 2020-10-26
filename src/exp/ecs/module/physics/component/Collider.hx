package exp.ecs.module.physics.component;

class Collider implements Component {
	/**
	 * This entity exists in these layers
	**/
	public final layers:Int;

	/**
	 * This entity can collide with entities in these target layers
	**/
	public final targets:Int;

	public final hits:Array<Int> = [];

	public function clone() {
		return new Collider(layers, targets, hits.copy());
	}

	public inline function canCollideWith(other:Collider) {
		return targets & other.layers > 0;
	}
}
