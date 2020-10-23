package exp.ecs.module.physics.component;

class Collider implements Component {
	public final hits:Array<Int>;
	public final layers:Int; // bitmask
	public final targets:Int; // bitmask

	public function clone() {
		return new Collider(hits.copy(), layers, targets);
	}

	public inline function canCollideWith(other:Collider) {
		return targets & other.layers > 0;
	}
}
