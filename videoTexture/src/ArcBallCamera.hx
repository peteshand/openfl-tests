package;

import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

class ArcBallCamera {
	
	private var position:Vector3D;
	private var target:Vector3D;
	private var _stage:Stage;
	private var _radius:Float = 0;
	private var mat:Matrix3D;
	private var MouseX:Float = 0;
	private var MouseY:Float = 0;
	private var zoom_Speed:Int =10;
	
	public var matrix(get, null):Matrix3D;
	public var zoomSpeed(get, set):Int;
	
	public function new(stage:Stage, radius:Float = 5) {
		_radius = radius;
		_stage = stage;
		
		position = new Vector3D(0, 0, _radius);
		target = new Vector3D();
		mat = new Matrix3D();
		mat.appendTranslation(position.x, position.y, position.z);
		_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
	}
	
	private function onMouseWheel(event:MouseEvent):Void {
		_radius += -1*event.delta * zoom_Speed;
		position = new Vector3D(0, 0, _radius);
		mat.appendTranslation(0, 0, -1*event.delta);
	}
	
	private function onMouseDown(event:MouseEvent):Void {
		_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		MouseX = _stage.mouseX;
		MouseY = _stage.mouseY;
	}
	
	private function onMouseMove(event:MouseEvent):Void {
		var dx:Float = _stage.mouseX - MouseX;
		mat.prependRotation((dx / _stage.stageWidth)*360, Vector3D.Y_AXIS);
		var dy:Float = _stage.mouseY - MouseY;
		mat.prependRotation((dy / _stage.stageHeight)*360, Vector3D.X_AXIS);
		
		MouseX = _stage.mouseX;
		MouseY = _stage.mouseY;
	}
	
	private function onMouseUp(event:MouseEvent):Void {
		_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	
	function get_matrix():Matrix3D {
		return mat;
	}
	
	function get_zoomSpeed():Int {
		return zoom_Speed;
	}
	
	function set_zoomSpeed(zoomSpeed:Int):Int {
		return zoom_Speed = zoomSpeed;
	}
}