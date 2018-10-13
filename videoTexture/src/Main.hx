package;

import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.events.MouseEvent;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.events.NetStatusEvent;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.display3D.textures.VideoTexture;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import com.adobe.utils.PerspectiveMatrix3D;
import openfl.display3D.Context3D;
import openfl.geom.Matrix3D;
import openfl.display.Sprite;

@:access(openfl.net.NetStream)
class Main extends Sprite
{	
	// Initialising  height and width of Stage
	var W:Int=640;
	var H:Int=480;
	
	// Stage3D parameters
	var modelViewProjection:Matrix3D;
	var camera:ArcBallCamera;
	var context:Context3D;
	var cube:Cube;
	var projectionMatrix:PerspectiveMatrix3D;
	static var FILE_NAME:String = "videos/sample.mp4";
	static var BORDER:Float = 20;
	
	var nc:NetConnection;
	var ns:NetStream;
	var texture:VideoTexture;
	var totalTime:Null<Float>;
	var textfield:TextField;

	public function new() {
		super();
		trace("VideoTextureSample");
		if (stage != null) 
			init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
		
	}
	
	
	// Requesting a Context3D to the first Stage3D
	
	function init(event:Event = null):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		trace("init");
		
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE,init);
		
		// requesting a Context3D instance using the Stage3D API
		stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
		stage.stage3Ds[0].requestContext3D();
	}
	
	function onContextCreated(event:Event):Void {
		
		trace("onContextCreated");
		// CONTEXT
		context = stage.stage3Ds[0].context3D;
		context.enableErrorChecking = true;
		context.configureBackBuffer(W, H, 4, true);
		
		// CAMERA
		camera = new ArcBallCamera(stage, 10);
		
		// PROJECTION
		projectionMatrix = new PerspectiveMatrix3D();
		projectionMatrix.perspectiveFieldOfViewLH(45*Math.PI/180, W/H, 0.1, 1000);
		
		// Creating a cube object 
		cube = new Cube(context);
		
		//Creating a VideoTexture object and attaching a NetStream object to the VideoTexture object.
		texture = context.createVideoTexture();
		nc = new NetConnection();
		nc.connect(null);
		ns = new NetStream(nc);
		ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		ns.client = this;
		ns.bufferTime = 2;
		ns.client = { 
			onMetaData: (evt:Dynamic) -> {
				totalTime = evt.duration;
			},
			onXMPData: (evt:Dynamic) -> {
				trace("onXMPData");
			}
		};
		#if (js && html5)
			// DEBUG
			js.Browser.document.body.insertBefore(ns.__video, js.Browser.document.body.firstChild);
			ns.__video.style.setProperty("width", "200px");
		#end
		
		textfield = new TextField();
		addChild(textfield);
		textfield.text = "click anywhere to play video";
		textfield.width = 500;
		textfield.height = 50;
		textfield.x = (stage.stageWidth - textfield.width) / 2;
		textfield.y = (stage.stageHeight - textfield.height) / 2;
		textfield.mouseEnabled = false;

		var format:TextFormat = new TextFormat("_sans", 30, 0xFFFFFFFF);
		format.align = TextFormatAlign.CENTER;
		textfield.setTextFormat(format);

		stage.addEventListener(MouseEvent.CLICK, onClick);
		
	}

	function onClick(e:MouseEvent)
	{
		textfield.visible = false;
		trace("PLAY");
		stage.removeEventListener(MouseEvent.CLICK, onClick);

		texture.attachNetStream(ns);
		texture.addEventListener(Event.TEXTURE_READY, textureRender);
		
		
		ns.play(FILE_NAME);
	}

	function textureRender(event:Event) {
		trace("textureRender");

		stage.removeEventListener(Event.ENTER_FRAME, render);
		stage.addEventListener(Event.ENTER_FRAME, render);
	}
	
	//Rendering the scene 
	function render(event:Event):Void {
		
		// Clear the backbuffer by filling it with the given color
		context.clear(0.1, 0.1, 0.1, 1); 
		var d:Float = 1.2;
		// render first cube
		cube.pos(-d, -d, 0);
		renderCube();
		
		// render second cube
		cube.pos(d, -d, 0);
		renderCube();
		
		// render third cube
		cube.pos(-d, d, 0);
		renderCube();
		
		// render fourth cube
		cube.pos(d, d, 0);
		renderCube();
		
		// render the backbuffer on screen.
		context.present(); 

		if (totalTime != null){
			if (ns.time / totalTime > 0.9){
				stage.removeEventListener(Event.ENTER_FRAME, render);
				ns.play(FILE_NAME);
			}
		}
	}
	
	// Rendering the cube 
	
	function renderCube():Void {
		
		modelViewProjection = new Matrix3D();
		modelViewProjection.append(cube.modelMatrix); 
		modelViewProjection.append(camera.matrix);			
		modelViewProjection.append(projectionMatrix);		
		
		// program
		context.setProgram(cube.program);
		
		// vertices
		context.setVertexBufferAt(0, cube.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3); 
		context.setVertexBufferAt(1, cube.vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3); 
		context.setTextureAt(0,texture);
		//constants
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, modelViewProjection, true);
		
		// render
		context.drawTriangles(cube.indexBuffer);
	}
	function onNetStatus(event:NetStatusEvent):Void
	{
		trace(event.info);
		trace(event.info.code);
		if ( event.info == "NetStream.Play.StreamNotFound" )
			trace("Video File passed not available\n");
	}
}