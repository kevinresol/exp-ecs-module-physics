package exp.ecs.module.physics.component;

class Velocity2 implements Component {
	public var x:Float;
	public var y:Float;

	public inline function set(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}
}
