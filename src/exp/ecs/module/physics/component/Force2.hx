package exp.ecs.module.physics.component;

class Force2 implements Component {
	public var x:Float;
	public var y:Float;

	public inline function set(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}

	public inline function setWithRotation(value:Float, radians:Float) {
		set(Math.cos(radians) * value, Math.sin(radians) * value);
	}
}
