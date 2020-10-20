package exp.ecs.module.physics.component;

class Collisions implements Component {
	public final with:Array<Int>;

	public function clone() {
		return new Collisions(with.copy());
	}
}
