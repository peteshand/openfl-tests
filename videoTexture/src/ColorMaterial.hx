package;


class ColorMaterial
{	
	public var name:String;
	private var red_value:Float = 0;
	private var green_value:Float = 0;
	private var blue_value:Float = 0;
	
	public var rgb(get, null):Vector.<Float> {
	public var red(get, null):Float {
	public var green(get, null):Float {
	public var blue(get, null):Float {
	
	public function new(color:Int = 0xFFFFFF) {
		red_value = (color >> 16 & 0xFF)/255;
		green_value = (color >> 8 & 0xFF)/255;
		blue_value = (color & 0xFF)/255;
	}
	
	public function setRGB(red:Float, green:Float, blue:Float):Void {
		red_value = red;
		green_value = green;
		blue_value = blue;
	}
	
	function get_rgb():Vector.<Float> {
		return Vector.<Float>([red_value,green_value,blue_value,1]);
	}
	
	function get_red():Float {
		return red_value;
	}
	
	function get_green():Float {
		return green_value;
	}
	
	function get_blue():Float {
		return blue_value;
	}
}