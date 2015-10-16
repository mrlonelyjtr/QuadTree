package
{
	import advancedCollisionDetection.*;
	
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.core.events.Event3D;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.compiler.Variable;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.objects.WireFrame;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	import alternativa.engine3d.utils.Object3DUtils;
	
	import collisionDetection.BSP.*;
	import collisionDetection.utils.CollTime;
	
	import com.adobe.utils.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import flashx.textLayout.elements.BreakElement;
	
	import mx.containers.Panel;
	import mx.controls.List;
	import mx.effects.easing.Quadratic;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.TimeEvent;
	
	public class Demo extends Sprite
	{
		[Embed( source = "character.jpg" )]
		private const TextureBitmap:Class;

		private var dragging:Boolean = false;
	    //通用对象
		private var stage3D:Stage3D;
		private var newstage3D:Stage3D;
		private var camera:Camera3D;
		private var scene:Object3D = new Object3D();//场景，所有物体的容器
		private var mesh:BVHMesh;
		private var meshes:Vector.<BVHMesh> = new Vector.<BVHMesh>();
		private var curMesh:Object3D = new Object3D(); 
		private var lastX:Number;
		private var lastY:Number;
//		private var aabb:AABB = new AABB();
		private var frame:WireFrame;
		private var swich:Boolean = false;
		private var context3D:Context3D;
		private var vertexbuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		private var texture:Texture;
		private var program:Program3D;
		
		private var meshNames:Array = new Array("dimian1", "dimian2", "dimian3", "waiqiang", "door", "window", "neiqiang4", "neiqiang1", "neiqiang3",
			  				 					"neiqiang2", "beijingqiang", "dijiaoxian", "diaoding1", "diaoding2", "tongdeng");
		
		private var quadTree:QuadTree;
		private var collisionDetection2D:CollisionDetectionIn2D = new CollisionDetectionIn2D();
		
		public function Demo()
		{
			
			//全局设置
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//设置摄像机
			camera = new Camera3D(0.1,10000);
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			addChild(camera.view);
			addChild(camera.diagram);
			
			camera.rotationX = -120*Math.PI/180;
			camera.y = -500;
			camera.z = 500;
			camera.x = 0;
			scene.addChild(camera);
			
			//设置控制器
			//controller = new SimpleObjectController(stage, camera,500,2);
			
			//请求创建3D环境
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D();
			
			newstage3D = stage.stage3Ds[1];
			newstage3D.addEventListener(Event.CONTEXT3D_CREATE, newinit);
			newstage3D.requestContext3D();
		}
		
		//创建成功3D环境
		private function init(e:Event):void
		{
			loadModel("models/all.DAE");
			
			for each (var resource:Resource in scene.getResources(true)) {
				resource.upload(stage3D.context3D);
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
			
		}
		
		private function newinit(e:Event):void
		{

		}
		
		private function onEnterFrame(e:Event):void {
			// Width and height of view
			// Установка ширины и высоты вьюпорта

			//ctxt.clear();
			// Render
			// Отрисовка
			camera.render(stage3D);
			
			/*context3D = stage.stage3Ds[0].context3D;			
			
			context3D.configureBackBuffer(800, 600, 1, true);
			
			var vertices:Vector.<Number> = Vector.<Number>([
				-0.5,-0.5,0, 0, 0, // x, y, z, u, v
				-0.5, 0.5, 0, 0, 1,
				0.5, 0.5, 0, 1, 1,
				0.5, -0.5, 0, 1, 0]);
			
			// 4 vertices, of 5 Numbers each
			vertexbuffer = context3D.createVertexBuffer(4, 5);
			// offset 0, 4 vertices
			vertexbuffer.uploadFromVector(vertices, 0, 4);
			
			// total of 6 indices. 2 triangles by 3 vertices each
			indexBuffer = context3D.createIndexBuffer(6);			
			
			// offset 0, count 6
			indexBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
			
			var bitmap:Bitmap = new TextureBitmap();
			texture = context3D.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height, Context3DTextureFormat.BGRA, false);
			texture.uploadFromBitmapData(bitmap.bitmapData);
			
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + // pos to clipspace
				"mov v0, va1" // copy uv
			);
			var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v0, fs0 <2d,linear,nomip>\n" +
				"mov oc, ft1"
			);
			
			program = context3D.createProgram();
			program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			
			if ( !context3D ) 
				return;
			
			context3D.clear ( 1, 1, 1, 1 );
			
			// vertex position to attribute register 0
			context3D.setVertexBufferAt (0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			// uv coordinates to attribute register 1
			context3D.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			// assign texture to texture sampler 0
			context3D.setTextureAt(0, texture);			
			context3D.setProgram(program);
			var m:Matrix3D = new Matrix3D();
			m.appendRotation( getTimer()/50, Vector3D.Z_AXIS);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			context3D.drawTriangles(indexBuffer);
			context3D.present();*/

			//controller.update();
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			var deviation:Number = 0.8;
			var rotStep:Number = 0.05;
			var movStep:Number = 5;
			var v:Vector3D;
			if(e.keyCode == 65)//A
			{
				v = screenToCamera(-movStep, 0);
				camera.x += v.x;
				camera.y += v.y;	
			}
			if(e.keyCode == 68)//D
			{
				v = screenToCamera(movStep, 0);
				camera.x += v.x;
				camera.y += v.y;	
			}
			if(e.keyCode == 87)//W
			{
				v = screenToCamera(0, -movStep);
				camera.x += v.x;
				camera.y += v.y;	
			}
			if(e.keyCode == 83)//S
			{
				v = screenToCamera(0, movStep);
				camera.x += v.x;
				camera.y += v.y;	
			}
			if(e.keyCode == 37)//left
			{
				camera.rotationZ += rotStep;
			}
			if(e.keyCode == 38)//up
			{
				camera.rotationX += rotStep;
			}
			if(e.keyCode == 39)//right
			{
				camera.rotationZ -= rotStep;
			}
			if(e.keyCode == 40)//down
			{
				camera.rotationX -= rotStep;
			}
			if(e.keyCode == 90)//z
			{
				camera.z -= movStep;
				//camera.render(stage3D);
			}
			if(e.keyCode == 88)//x
			{
				camera.z += movStep;
			}
			if(e.keyCode == 82)//R
			{
				var theta:Number = 0.05;
				var beta:Number = curMesh.rotationZ;
				//trace(beta);
				//if(beta >= 2 * Math.PI)
				//{
				//	curMesh.rotationZ = 0;
				//	beta = curMesh.rotationZ;
				//}
				var centerX:Number = ( curMesh.boundBox.maxX + curMesh.boundBox.minX ) / 2;
				var centerY:Number = ( curMesh.boundBox.maxY + curMesh.boundBox.minY ) / 2;
				//trace(centerX);
				//trace(centerY);
				curMesh.rotationZ += theta;	
				var halfTheta:Number = theta / 2;
				var reviseX:Number = 2 * Math.sin(halfTheta) * ( Math.sin(halfTheta + beta) * centerX + Math.cos(halfTheta + beta) * centerY );
				var reviseY:Number = -2 * Math.sin(halfTheta) * ( Math.cos(halfTheta + beta) * centerX - Math.sin(halfTheta + beta) * centerY );
				curMesh.x += reviseX;
				curMesh.y += reviseY;
				var curBVHMesh:BVHMesh;
				for(var i:int = 0; i < meshes.length; i++)
				{
					if(meshes[i].getMesh() == curMesh)
					{
						curBVHMesh = meshes[i];
					}
				}
//				var aabbtree:AABBTree = curBVHMesh.getTree();
//				if(aabbtree != null)
//				{
////					aabbtree.rotateAABBTree(curMesh.rotationZ, reviseX, reviseY);
//				}
//				
//				//调试用边框
//				aabbtree.createWireFrame();
//				var frames:Vector.<WireFrame> = aabbtree.getFrames();
//				for(var i:int = 0; i < frames.length; i++)
//				{
//				    scene.addChild(frames[i]);
//				    uploadResources(frames[i].getResources());
//				}
//				frame = getBoundBoxFrame(curBVHMesh);
//				scene.addChild(frame);
//				uploadResources(frame.getResources());
			}
			if(e.keyCode == 89)//y
			{
	/*			var ctxt:Context3D = stage3D.context3D;
				var minA:Texture = ctxt.createTexture(8,1,"bgra",false);
				var maxA:Texture = ctxt.createTexture(8,1,"bgra",false);
				var minB:Texture = ctxt.createTexture(8,1,"bgra",false);
				var maxB:Texture = ctxt.createTexture(8,1,"bgra",false);
				var result:Texture = ctxt.createTexture(8,8,"bgra",true);
				
				var data:ByteArray = new ByteArray();
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				//minA.uploadFromByteArray(data,0);
				var bt:BitmapData = new BitmapData(100,100,false,0xffffffff);
				
				minA.uploadFromBitmapData(bt);
				minB.uploadFromByteArray(data,0);
				
				ctxt.setTextureAt(0,minA);
				ctxt.setTextureAt(1,minB);
				
				var vertices:Vector.<Number> = Vector.<Number>([
					0,0, 0, 0, 
					0, 100, 0, 1,
					100, 0, 1, 0,
					100, 100, 1, 1]);
				
				var vertexBuffer:VertexBuffer3D = ctxt.createVertexBuffer(4,4);
				vertexBuffer.uploadFromVector(vertices,0,4);
				ctxt.setVertexBufferAt(0,vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_2);
				ctxt.setVertexBufferAt(1,vertexBuffer,2,Context3DVertexBufferFormat.FLOAT_2);
				
				var indexBuffer:IndexBuffer3D = ctxt.createIndexBuffer(6);
				indexBuffer.uploadFromVector(Vector.<uint>([0,1,2,2,3,1]),0,6);
				
				var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
					"mov op, va0 \n" +
					"mov v0, va1" 
				);
				
				var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
					"tex ft1, v0, fs0<2d,linear, nomip>\n" +
					"mov oc, ft1"
				);
				
				var program:Program3D = ctxt.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				
				ctxt.setProgram( program );
					
				//minA.
				
				//ctxt.setRenderToBackBuffer();
				ctxt.clear(0.5,0.5,0.5,0.5);
				//ctxt.drawTriangles(indexBuffer,0,2);
				ctxt.present();
				
				//stage3D.
				var bm:BitmapData = new BitmapData(500,500,false,0xff00ff);
				//stage3D.context3D.drawToBitmapData(bm);	
				var rgb:int = bm.getPixel(0,0);
				trace(rgb);*/
				//ctxt.clear();
				
				var ctxt:Context3D = stage3D.context3D;
				ctxt.configureBackBuffer(800, 600, 1, true);
				
				var bitmap:Bitmap = new TextureBitmap();
				//var minA:Texture = ctxt.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height, Context3DTextureFormat.BGRA,false);
				//minA.uploadFromBitmapData(bitmap.bitmapData);
				var bt:BitmapData = new BitmapData(128,128,false,0x000000ff);
				var minA:Texture = ctxt.createTexture(128, 128, Context3DTextureFormat.BGRA,false);
				minA.uploadFromBitmapData(bt);
				var maxA:Texture = ctxt.createTexture(8,1,"bgra",false);
				var minB:Texture = ctxt.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height, Context3DTextureFormat.BGRA,false);
				minB.uploadFromBitmapData(bitmap.bitmapData);
				var maxB:Texture = ctxt.createTexture(8,1,"bgra",false);
				var result:Texture = ctxt.createTexture(8,8,"bgra",true);
				
				var data:ByteArray = new ByteArray();
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				data.writeDouble(50);
				//minA.uploadFromByteArray(data,0);
				
				//minB.uploadFromByteArray(data,0);
				
				ctxt.setTextureAt(0,minA);
				//ctxt.setTextureAt(1,minB);
				
				var vertices:Vector.<Number> = Vector.<Number>([
					-1,-1,0, 0, 0, 
					-1, 1, 0, 0, 1,
					1, 1, 0, 1, 1,
					1, -1, 0, 1, 0]);
				
				var vertexBuffer:VertexBuffer3D = ctxt.createVertexBuffer(4,5);
				vertexBuffer.uploadFromVector(vertices,0,4);
				
				ctxt.setVertexBufferAt(0,vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);
				ctxt.setVertexBufferAt(1,vertexBuffer,3,Context3DVertexBufferFormat.FLOAT_2);
				
				var indexBuffer:IndexBuffer3D = ctxt.createIndexBuffer(6);
				indexBuffer.uploadFromVector(Vector.<uint>([0,1,2,2,3,0]),0,6);
				
				
				var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
					"mov op, va0 \n" +
					"mov v0, va1" 
				);
				
				var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
					"tex ft1, v0, fs0<2d,linear, nomip>\n" +
					"mov oc, ft1"
				);
				
				var program:Program3D = ctxt.createProgram();
				program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
				
				
				//minA.
				
				//ctxt.setRenderToBackBuffer();
				ctxt.clear(1,1,1,1);
				
				
				ctxt.setProgram( program );
				
				//ctxt.setRenderToTexture(
				//var tex:Texture 
				//tex.
				//ctxt.drawTriangles(indexBuffer);
				//ctxt.present();
				ctxt.clear(1,1,1,1);
				var bm:BitmapData = new BitmapData(800,600,false,0xffffffff);
				ctxt.drawTriangles(indexBuffer);
				ctxt.drawToBitmapData(bm);
				var rgb:int = bm.getPixel(1,1);
				trace(rgb);
				ctxt.setTextureAt(0,null);
				ctxt.clear(1,0,1,1);
				ctxt.drawTriangles(indexBuffer);
				ctxt.drawToBitmapData(bm);	
				rgb = bm.getPixel(0,0);
				trace(rgb);
				
			}

		}
		
		private function onMouseDown(e:MouseEvent3D):void {
			curMesh = e.target as Object3D; 
			trace(curMesh.name);
			dragging = true;	
		}
		
//		private function onMouseMove(e:MouseEvent):void {
//
//			if(dragging == true)
//			{
//				//从鼠标速度算出物体移动速度
//				var v:Vector3D = screenToCamera(e.stageX - lastX, e.stageY - lastY);
//				var vx:Number = v.x;
//				var vy:Number = v.y;
//				//
//				var time:CollTime = new CollTime();//碰撞时间
//				time.tfirst = 0;
//				time.tlast = 1;
//				trace(curMesh.x,curMesh.y);
//				var newPos:Vector3D = new Vector3D(curMesh.x, curMesh.y, curMesh.z);//拖动后新坐标
//				var curBVHMesh:BVHMesh;//当前物体
//				var untouchedCnt:int = 0;//不碰撞次数
//				
//				for(var i:int = 0; i < meshes.length; i++)
//				{
//					if(meshes[i].getMesh() == curMesh)
//					{
//						curBVHMesh = meshes[i];
//					}
//				}
//				
//				for(var i:int = 0; i < meshes.length; i++)
//				{
//					if(curMesh.name == meshes[i].getMesh().name)
//					{
//						continue;
//					}
//					else
//					{
//						if(aabb.getMovingCollisionForObj(meshes[i].getMesh(), curMesh, new Vector3D(0,0,0), new Vector3D(vx,vy,0),time))
//						{
//							//重置碰撞时间，为进一步碰撞检测做准备
//							time.tfirst = 0;
//							time.tlast = 1;
//							//如果需要碰撞的两个物体没有建八叉树，那么建树
//							if(curBVHMesh.getTree() == null)
//							{
//								//curBVHMesh.initTree();
//							}
//							if(meshes[i].getTree() == null)
//							{
//								//meshes[i].initTree();
//							}
//							//精确碰撞检测
//							if(curBVHMesh.getTree().collideWithAABBTree(meshes[i].getTree(), new Vector3D(vx,vy,0), new Vector3D(0, 0, 0),time))
//							{
//								//同时与多个物体碰撞，取最小位移。
//								if(vx >= 0)
//								{
//									newPos.x = Math.min(curMesh.x + vx * time.tfirst, newPos.x);
//								}
//								else
//								{
//									newPos.x = Math.max(curMesh.x + vx * time.tfirst, newPos.x);
//								}
//								if(vy >= 0)
//								{
//									newPos.y = Math.min(curMesh.y + vy * time.tfirst, newPos.y);
//								}
//								else
//								{
//									newPos.y = Math.max(curMesh.y + vy * time.tfirst, newPos.y);
//								}
//								
//								newPos.z = 0;
//
//							}
//							else
//							{
//								//不碰撞次数
//								untouchedCnt++;
//								//newPos.z = 0
//							}
//						}
//						else
//						{
//							untouchedCnt++;
//						}
//					}
//				}
//				//如果都不碰撞，正常更新坐标
//				if(untouchedCnt == meshes.length - 1)
//				{
//					newPos.x = curMesh.x + vx;
//					newPos.y = curMesh.y + vy;
//					newPos.z = 0;
//					
//				}
//				moveObject(curMesh, newPos.x, newPos.y, newPos.z);
//
//			}
//				
//			lastX = e.stageX;
//			lastY = e.stageY;
//		}
		
		private function onMouseUp(e:MouseEvent):void {
			dragging = false;
		}
		
		
		//把屏幕上的坐标转换到摄像机坐标系中
	    private function screenToCamera(x:Number, y:Number):Vector3D
		{
			var v:Vector3D = new Vector3D();
			var theta:Number = camera.rotationZ;
			v.x = x * Math.cos(theta) + y * Math.sin(theta);
			v.y = x * Math.sin(theta) - y * Math.cos(theta);
			v.z = 0;
			return v;
		}
		
		private function moveObject(o:Object3D, x:Number, y:Number, z:Number):void{
			o.x = x;
			o.y = y;
			o.z = z;
			
		}
		
//		private function loadModel( modelURL:String, diffuseMapURL:String = null):void
//		{
//
//			var loader:URLLoader;
//			var parser:ParserCollada = new ParserCollada();  
//			loader = new URLLoader(); 
//			loader.load(new URLRequest(modelURL));
//			loader.addEventListener(Event.COMPLETE, onModelLoads);
//			function onModelLoads(e:Event):void {
//				var parser:ParserCollada = new ParserCollada();
//				parser.parse(XML((e.target as URLLoader).data), "models/all.DAE");
//				var date:Date = new Date();
//				trace([date.minutes,date.seconds,date.milliseconds]);
//				for (var i:int = 0; i < parser.objects.length; i++)
//				{
//					if (parser.objects[i] is Mesh)
//					{
//						var tempMesh:Mesh = parser.objects[i] as Mesh;
//						//aabb.generateBoundBox(tempMesh);
//						mesh = new BVHMesh(tempMesh);
//						if(mesh.getMesh().name == "dimian1" || mesh.getMesh().name == "dimian2" || mesh.getMesh().name == "dimian3" || mesh.getMesh().name == "waiqiang"
//							|| mesh.getMesh().name == "door" || mesh.getMesh().name == "window" || mesh.getMesh().name == "neiqiang4" || mesh.getMesh().name == "neiqiang1"
//						    || mesh.getMesh().name == "beijingqiang" || mesh.getMesh().name == "dijiaoxian")
//						{
//
//						}
//						else
//						{
//							meshes.push(mesh);
//							mesh.initTree();
//							//scene.addChild(mesh.getMesh());
//						}
//						
//						var m:Mesh = mesh.getMesh();
//						//var wf:WireFrame = getBoundBoxFrame(m);
//						//scene.addChild(wf);
//						//uploadResources(wf.getResources());
//						scene.addChild(m);
//						
//						for each (var resource:Resource in m.getResources()) 
//						{
//							resource.upload(stage3D.context3D);
//						}
//						
//						var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
//						for (var j:int = 0; j < m.numSurfaces; j++) 
//						{
//							var surface:Surface = m.getSurface(j);
//							var material:ParserMaterial = surface.material as ParserMaterial;
//							if (material != null) 
//							{
//								var diffuse:TextureResource = material.textures["diffuse"];
//								if (diffuse != null) 
//								{
//									textures.push(diffuse);
//									surface.material = new TextureMaterial(diffuse);
//								}
//							}
//						}
//						
//						var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
//						texturesLoader.loadResources(textures);
//						
//						m.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
//					}
//				}
//				var date:Date = new Date();
//				trace([date.minutes,date.seconds,date.milliseconds]);
//
//				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
//				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
//			}		
//		}
		
		private function uploadResources(resources:Vector.<Resource>):void {
			for each (var resource:Resource in resources) {
				resource.upload(stage3D.context3D);
			}
		}
		//为包围盒画线
//		private function getBoundBoxFrame(ob:BVHMesh):WireFrame{
//			var o:Mesh = ob.getMesh();
//			var a:BoundBox = ob.getTree().getRoot();
//			var aabb:BoundBox = new BoundBox();
//			aabb.maxX = a.maxX + o.x;
//			aabb.maxY = a.maxY + o.y;
//			aabb.maxZ = a.maxZ + o.z;
//			aabb.minX = a.minX + o.x;
//			aabb.minY = a.minY + o.y;
//			aabb.minZ = a.minZ + o.z;
//			var points:Vector.<Vector3D> = new Vector.<Vector3D>();
//			points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
//			points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
//			
//			points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
//			points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
//			
//			points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
//			points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
//			
//			points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
//			points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
//			
//			
//			points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
//			points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
//			
//			points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
//			points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
//			
//			points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
//			points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
//			
//			points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
//			points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
//			
//			
//			points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
//			points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
//			
//			points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
//			points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
//			
//			points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
//			points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
//			
//			points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
//			points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
//			
//			return WireFrame.createLinesList(points,0xff0000);
//		}
		
		private function loadModel(modelURL:String, diffuseMapURL:String = null):void{
			var loader:URLLoader;
			var parser:ParserCollada = new ParserCollada();  
			
			loader = new URLLoader(); 
			loader.load(new URLRequest(modelURL));
			loader.addEventListener(Event.COMPLETE, onModelLoads);
			
			function onModelLoads(e:Event):void {
				var parser:ParserCollada = new ParserCollada();
				parser.parse(XML((e.target as URLLoader).data), "models/all.DAE");
				var date:Date = new Date();
				trace([date.minutes,date.seconds,date.milliseconds]);
				
				quadTree = new QuadTree(0, new Rectangle(-700, -700, 1300, 1300));
				
				for (var i:int = 0; i < parser.objects.length; i++){
					if (parser.objects[i] is Mesh) {
						var tempMesh:Mesh = parser.objects[i] as Mesh;

						mesh = new BVHMesh(tempMesh);
						
						var isEqual:Boolean = false;
						for (var j:int = 0; j < meshNames.length; ++j){
							if (mesh.getMesh().name == meshNames[j]){
								isEqual = true;
								break;
							}
						}

						if (isEqual == false){
							mesh.initOBB();
							mesh.initOctree(mesh);

							meshes.push(mesh);
						}
						
						var m:Mesh = mesh.getMesh();
						scene.addChild(m);
						
						for each (var resource:Resource in m.getResources()){
							resource.upload(stage3D.context3D);
						}
						
						var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
						for (var j:int = 0; j < m.numSurfaces; j++){
							var surface:Surface = m.getSurface(j);
							var material:ParserMaterial = surface.material as ParserMaterial;
							if (material != null){
								var diffuse:TextureResource = material.textures["diffuse"];
								if (diffuse != null){
									textures.push(diffuse);
									surface.material = new TextureMaterial(diffuse);
								}
							}
						}
						
						var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
						texturesLoader.loadResources(textures);
						
						m.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
					}
				}
					
				var date:Date = new Date();
				trace([date.minutes,date.seconds,date.milliseconds]);
				
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}
					
		private function onMouseMove(e:MouseEvent):void{
			if (dragging == true){
				var v:Vector3D = screenToCamera(e.stageX - lastX, e.stageY - lastY);
				var vX:Number = v.x;
				var vY:Number = v.y;
				
				var collisionTime:CollTime = new CollTime();
				collisionTime.tfirst = 0;
				collisionTime.tlast = 1;
				
				var newPosition:Vector3D = new Vector3D(curMesh.x, curMesh.y, curMesh.z);
				var notCollideCount:int = 0;	
				var curBVHMesh:BVHMesh = new BVHMesh(mesh.getMesh());
				var curObject:Object;
				var returnObjects:Array = [];
				
				quadTree.clear();
				
				for each (var mesh:BVHMesh in meshes){
					mesh.initAABB();
					
					var object:Object = mesh.getProjection();
					
					quadTree.insert(object);
					
					if (mesh.getMesh() == curMesh){
						curBVHMesh = mesh;
						curObject = object;
						
					}
				}
				
				quadTree.retrive(returnObjects, curObject);
				
				for (var i:int = 0; i < returnObjects.length; i++){	
					if(curBVHMesh.getMesh().name != returnObjects[i].name){
						var isCollide:Boolean = collisionDetection2D.dynamicCollisionDetection(returnObjects[i], curObject, 
												new Vector3D(0, 0, 0), new Vector3D(vX, vY, 0), collisionTime);
						
						if (isCollide == true){
							for each (var mesh:BVHMesh in meshes){
								if (returnObjects[i].name == mesh.getMesh().name){
									var isAdvancedCollide:Boolean = curBVHMesh.getTree().collideDetectionWithTree(mesh.getTree());
									if(isAdvancedCollide){
										if(vX >= 0)
											newPosition.x = Math.min(curMesh.x + vX * collisionTime.tfirst, newPosition.x);
										else
											newPosition.x = Math.max(curMesh.x + vX * collisionTime.tfirst, newPosition.x);
										
										if(vY >= 0)
											newPosition.y = Math.min(curMesh.y + vY * collisionTime.tfirst, newPosition.y);
										else
											newPosition.y = Math.max(curMesh.y + vY * collisionTime.tfirst, newPosition.y);
										
										newPosition.z = 0;
									}
									else
										notCollideCount++;
								}
							}
						}
						else
							notCollideCount++;
						
					}
				}	

				if(notCollideCount == returnObjects.length - 1){
					newPosition.x = curMesh.x + vX;
					newPosition.y = curMesh.y + vY;
					newPosition.z = 0;
				}
				
				moveObject(curMesh, newPosition.x, newPosition.y, newPosition.z);	
			}
			
			lastX = e.stageX;
			lastY = e.stageY;
		}
		
		public function show(rec:Rectangle):WireFrame{
			var points:Vector.<Vector3D> = new Vector.<Vector3D>();
			var minX:Number = rec.x;
			var maxX:Number = rec.x + rec.width
			var minY:Number = rec.y;
			var maxY:Number = rec.y + rec.height;
			
			points.push(new Vector3D(minX, minY, 0));
			points.push(new Vector3D(maxX, minY, 0));
			
			points.push(new Vector3D(minX, minY, 0));
			points.push(new Vector3D(minX, maxY, 0));
			
			points.push(new Vector3D(minX, maxY, 0));		
			points.push(new Vector3D(maxX, maxY, 0));
			
			points.push(new Vector3D(maxX, maxY, 0));
			points.push(new Vector3D(maxX, minY, 0));
			
			return WireFrame.createLinesList(points,0xff0000);
		}

			private function getBoundBoxFrame(b:BoundBox):WireFrame{
				var aabb:BoundBox = new BoundBox();
				aabb.maxX = b.maxX;
				aabb.maxY = b.maxY
				aabb.maxZ = b.maxZ;
				aabb.minX = b.minX;
				aabb.minY = b.minY;
				aabb.minZ = b.minZ;
				var points:Vector.<Vector3D> = new Vector.<Vector3D>();
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
				
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
				
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
				
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
				
				return WireFrame.createLinesList(points,0xff0000);
			}
	}
}