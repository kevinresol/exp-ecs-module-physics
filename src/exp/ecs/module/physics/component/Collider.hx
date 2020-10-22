package exp.ecs.module.physics.component;

class Collider implements Component {
	public final with:Array<Int>;

	public function clone() {
		return new Collider(with.copy());
	}
}
