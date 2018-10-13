package;

import openfl.Vector;
import openfl.utils.AGALMiniAssembler;
//import com.adobe.utils.AGALMiniAssembler;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;

class Cube 
{
	public var vertexBuffer:VertexBuffer3D;
	public var indexBuffer:IndexBuffer3D;
	public var program:Program3D;
	public var modelMatrix:Matrix3D;
	private var cube_context:Context3D;
	private var vertexShader:ByteArray;
	private var fragmentShader:ByteArray;
	
	public function new(context:Context3D) 
	{
		cube_context = context;
		modelMatrix = new Matrix3D();
		createAndUploadBuffers();
		createAndCompileProgram();
	}
	
	public function pos(x_loc:Float, y_loc:Float, z_loc:Float):Cube {
		modelMatrix.identity();
		modelMatrix.appendTranslation(x_loc, y_loc, z_loc);
		
		return this;
	}

	function createAndCompileProgram() : Void {

		program = cube_context.createProgram();

		var assembler:AGALMiniAssembler = new AGALMiniAssembler();
		
		vertexShader = assembler.assemble(Context3DProgramType.VERTEX, 
			"m44 op, va0, vc0\n"+
			"mov v0, va1\n"
		);
		
		fragmentShader = assembler.assemble(Context3DProgramType.FRAGMENT, 
			"tex ft0, v0, fs0 <2d,linear, nomip>\n" +
			"mov oc, ft0\n");
		program.upload(vertexShader, fragmentShader); 
	}
	
//Creating and uploading buffer to GPU 
	function createAndUploadBuffers():Void {
		var meshIndexData:Vector<UInt> = new Vector<UInt>(
			[
				0, 1, 2,
				2, 3, 0,
				4, 5, 6,
				6, 7, 4,
				8, 9, 5,
				5, 4, 8,
				10, 11, 9,
				9, 8, 10,
				12, 13, 14,
				14, 15, 12,
				16, 17, 18,
				18, 19, 16,
			]);
		var coord:Float = 1.0;
		var meshVertexData:Vector<Float> = new Vector<Float>([
			coord, -coord, -coord, -0.00, 0.00,0, 0, 1,
			coord, -coord, coord, 0.33, 0.00,0, 0, 1,
			-coord, -coord, coord, 0.33, 0.33,0, 0, 1,
			-coord, -coord, -coord, -0.00, 0.33,0, 0, 1,
			coord, coord, -coord, 0.67, 0.33,0, 0, 1,
			coord, -coord, -coord, 0.33, 0.33,0, 0, 1,
			-coord, -coord, -coord, 0.33, 0.00,0, 0, 1,
			-coord, coord, -coord, 0.67, 0.00,0, 0, 1,
			coord, coord, coord, 0.67, 0.67,0, 0, 1,
			coord, -coord, coord, 0.33, 0.67,0, 0, 1,
			-coord, coord, coord, 0.67, 1.00,0, 0, 1,
			-coord, -coord, coord, 0.33, 1.00,0, 0, 1,
			-coord, coord, -coord, 0.33, 1.00,0, 0, 1,
			-coord, -coord, -coord, -0.00, 1.00,0, 0, 1,
			-coord, -coord, coord, -0.00, 0.67,0, 0, 1,
			-coord, coord, coord, 0.33, 0.67,0, 0, 1,
			-coord, coord, coord, -0.00, 0.67,0, 0, 1,
			coord, coord, coord, -0.00, 0.33,0, 0, 1,
			coord, coord, -coord, 0.33, 0.33,0, 0, 1,
			-coord, coord, -coord, 0.33, 0.67,0, 0, 1,
		]);
		
		vertexBuffer = cube_context.createVertexBuffer(Math.floor(meshVertexData.length/8), 8);
		vertexBuffer.uploadFromVector(meshVertexData, 0, Math.floor(meshVertexData.length/8));
		indexBuffer = cube_context.createIndexBuffer(meshIndexData.length);
		indexBuffer.uploadFromVector(meshIndexData, 0, meshIndexData.length);
	}
	
}