package
{
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.objects.WireFrame;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	
	import collisionDetection.AABB.*;
	import collisionDetection.BSP.*;
	import collisionDetection.utils.CollTime;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Main extends Sprite
	{
		[Embed(source = "texture.jpg")]
		static private const Desert:Class;
		
		[Embed("character.DAE", mimeType="application/octet-stream")] static private const CharacterModel:Class;
		[Embed(source="character.jpg")] static private const CharacterTexture:Class;
		
		private var dragging:Boolean = false;
		private var stage3D:Stage3D;
		private var camera:Camera3D;
		private var box:Box;
		private var mesh:Mesh;
		private var character:Skin;
		private var frame:WireFrame;
		private var box1:Mesh;
		private var frameBox:WireFrame;
		private var scene:Object3D = new Object3D();
		private var controller:SimpleObjectController;
		private var lastX:int;
		private var lastY:int;
		private static var a:BoundBox;
		private var aabb:AABB = new AABB();
		private var aabbTree:AABBTree;
		private var aabbTree1:Vector.<AABBTree> = new Vector.<AABBTree>();
		private var aabbcnt:int = 0;
		private var b1:BoundBox;
		private var b2:BoundBox;
		

		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			
			camera = new Camera3D(0.1,10000);
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			addChild(camera.view);
			addChild(camera.diagram);
			
			camera.rotationX = -120*Math.PI/180;
			camera.y = -250;
			camera.z = 250;
			camera.x = 150;
			//controller = new SimpleObjectController(stage, camera,500,2);
			scene.addChild(camera);
			
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D();
		}
		
		private function init(e:Event):void
		{
			loadModel( "1.DAE");
			for(var i:int = 0; i < 20; i ++)
			{
				loadModel1(Math.random() * 1000 - 500, Math.random() * 1000 - 500, -20, "chuangtougui.DAE");
			}
			
			for each (var resource:Resource in scene.getResources(true)) {
				resource.upload(stage3D.context3D);
			}


			//box.geometry.upload(stage3D.context3D);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		}
		
		private function onEnterFrame(e:Event):void {
			// Width and height of view
			// Установка ширины и высоты вьюпорта
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
			
			// Render
			// Отрисовка
			camera.render(stage3D);
			//controller.update();
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			var deviation:Number = 0.8;
			if(e.keyCode == 82)
			{
				mesh.rotationZ +=0.05;
				//rotateBoundBox(mesh);
				scene.removeChild(frame);
				frame = getBoundBoxFrame(mesh);
				//moveFrame(mesh.x, mesh.y, mesh.z);
				scene.addChild(frame);
				uploadResources(frame.getResources());
				//frame = getBoundBoxFrame(mesh);
				//moveObject(box1,300,0,0);
				
			}
		}
		
		private function onMouseDown(e:MouseEvent3D):void {
			dragging = true;
			
		}
		
		private function onMouseMove(e:MouseEvent):void {

			var curMesh:Mesh = mesh;
			if(dragging == true)//正在拖动物体
			{
				var vx:Number = (e.stageX - lastX);
				var vy:Number = (lastY - e.stageY);
				
				var time:CollTime = new CollTime();//碰撞时间
				time.tfirst = 0;
				time.tlast = 1;
				

				var newPos:Vector3D = new Vector3D(curMesh.x, curMesh.y, curMesh.z);//拖动后新坐标
					
				var untouchedCnt:int = 0;
				for(var i:int = 0; i < aabbcnt; i ++)
				{
					//if(aabb.getMovingCollision(box1.boundBox, curMesh.boundBox, new Vector3D(0,0,0), new Vector3D(vx,vy,0),time))
					//碰撞检测
					if(aabbTree.collideWithAABBTree(aabbTree1[i], new Vector3D(vx,vy,0), new Vector3D(0,0,0),time))
					{
						time.tfirst -= 0.002;
						
						if(i == 0)
						{
							newPos.x = curMesh.x + vx * time.tfirst;
							newPos.y = curMesh.y + vy * time.tfirst;
						}
						//同时与多个物体碰撞，取最小位移。
						if(vx >= 0)
						{
							newPos.x = Math.min(newPos.x + vx * time.tfirst, newPos.x);
						}
						else
						{
							newPos.x = Math.max(newPos.x + vx * time.tfirst, newPos.x);
						}
						if(vy >= 0)
						{
							newPos.y = Math.min(newPos.y + vy * time.tfirst, newPos.y);
						}
						else
						{
							newPos.y = Math.max(newPos.y + vy * time.tfirst, newPos.y);
						}

						//newPos.x = curMesh.x + vx * time.tfirst;
						//newPos.y = curMesh.y + vy * time.tfirst;
						newPos.z = 0;
						
						//moveObject(curMesh, newPos.x, newPos.y, newPos.z);

					}
					else
					{
						//不碰撞次数
						untouchedCnt++;
						//newPos.z = 0
					}

				}
				//如果都不碰撞，正常更新坐标
				if(untouchedCnt == aabbcnt)
				{
					newPos.x = curMesh.x + vx;
					newPos.y = curMesh.y + vy;
					newPos.z = 0;
					
				}
				//移动物体到新坐标
				moveObject(curMesh, newPos.x, newPos.y, newPos.z);
				
				lastX = e.stageX;
				lastY = e.stageY;
			}
			lastX = e.stageX;
			lastY = e.stageY;
		}
		
		private function onMouseUp(e:MouseEvent):void {
			dragging = false;
		}
		
		
		//为包围盒画线
		private function getBoundBoxFrame(o:Object3D):WireFrame{
			var a:BoundBox = o.boundBox;
			var aabb:BoundBox = new BoundBox();
			aabb.maxX = a.maxX - o.x;
			aabb.maxY = a.maxY - o.y;
			aabb.maxZ = a.maxZ - o.z;
			aabb.minX = a.minX - o.x;
			aabb.minY = a.minY - o.y;
			aabb.minZ = a.minZ - o.z;
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
		
		private function getBVFrame(aabb:BoundBox):WireFrame{
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
		
		public function moveObject(o:Object3D, x:Number, y:Number, z:Number):void{
			o.x = x;
			o.y = y;
			o.z = z;
			
		}
		
		private function loadModel( modelURL:String, diffuseMapURL:String = null):void
		{
			var loader:URLLoader;
			var parser:ParserCollada = new ParserCollada();  
			loader = new URLLoader(); 
			loader.load(new URLRequest(modelURL));
			loader.addEventListener(Event.COMPLETE, onModelLoads);
			function onModelLoads(e:Event):void {
				var parser:ParserCollada = new ParserCollada();
				parser.parse(XML((e.target as URLLoader).data));
				
				for (var i:int = 0; i<parser.objects.length; i++)
				{
					if (parser.objects[i] is Mesh)
					{
					    mesh = parser.objects[i] as Mesh;
						scene.addChild(mesh);
						//uploadResources(mesh.getResources());
						for each (var resource:Resource in mesh.getResources()) {
							resource.upload(stage3D.context3D);
						}
						
						var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
						for (var j:int = 0; j < mesh.numSurfaces; j++) {
							var surface:Surface = mesh.getSurface(j);
							var material:ParserMaterial = surface.material as ParserMaterial;
							if (material != null) {
								var diffuse:TextureResource = material.textures["diffuse"];
								if (diffuse != null) {
									textures.push(diffuse);
									surface.material = new TextureMaterial(diffuse);
								}
							}
						}

						var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
						texturesLoader.loadResources(textures);
					}
				}
				aabbTree = new AABBTree();
				aabbTree.initAABBTree(mesh);
				//aabbTree.createWireFrame();
				//var frames:Vector.<WireFrame> = aabbTree.getFrames();
				//for(var i:int = 0; i < frames.length; i++)
				//{
					//scene.addChild(frames[i]);
					//uploadResources(frames[i].getResources());
				//}
				//a = mesh.boundBox.clone();
				//var a:XYAxialPartition = new XYAxialPartition(mesh);
				//var frame1:WireFrame = a.getDivisionFrame(mesh);
				///scene.addChild(frame1);
				//uploadResources(frame1.getResources());
				//var frame1:WireFrame = getBVFrame(aabbTree.root);
				//frame = getBVFrame(mesh.boundBox);
				//scene.addChild(frame);
				//uploadResources(frame.getResources());
				//scene.addChild(frame1);
				//uploadResources(frame1.getResources());			
				
				mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			
		}
		
		private function loadModel1(x:int, y:int, z:int, modelURL:String, diffuseMapURL:String = null):void
		{
			var loader:URLLoader;
			var parser:ParserCollada = new ParserCollada();  
			loader = new URLLoader(); 
			loader.load(new URLRequest(modelURL));
			loader.addEventListener(Event.COMPLETE, onModelLoads);
			function onModelLoads(e:Event):void {
				var parser:ParserCollada = new ParserCollada();
				parser.parse(XML((e.target as URLLoader).data));
				
				for (var i:int = 0; i<parser.objects.length; i++)
				{
					if (parser.objects[i] is Mesh)
					{
						box1 = parser.objects[i] as Mesh;
						scene.addChild(box1);
						//uploadResources(mesh.getResources());
						for each (var resource:Resource in box1.getResources()) {
							resource.upload(stage3D.context3D);
						}
						
						var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
						for (var j:int = 0; j < box1.numSurfaces; j++) {
							var surface:Surface = box1.getSurface(j);
							var material:ParserMaterial = surface.material as ParserMaterial;
							if (material != null) {
								var diffuse:TextureResource = material.textures["diffuse"];
								if (diffuse != null) {
									textures.push(diffuse);
									surface.material = new TextureMaterial(diffuse);
								}
							}
						}
						
						var texturesLoader:TexturesLoader = new TexturesLoader(stage3D.context3D);
						texturesLoader.loadResources(textures);
					}
				}
				aabbTree1[aabbcnt] = new AABBTree();
				aabbTree1[aabbcnt].initAABBTree(box1);
				//aabbTree1[aabbcnt].createWireFrame();
				//var frames:Vector.<WireFrame> = aabbTree1[aabbcnt].getFrames();
				aabbcnt++;
				//for(var i:int = 0; i < frames.length; i++)
				//{
					//scene.addChild(frames[i]);
					//uploadResources(frames[i].getResources());
				//}
				//a = box1.boundBox.clone();
				//var a:XYAxialPartition = new XYAxialPartition(mesh);
				//var frame1:WireFrame = a.getDivisionFrame(mesh);
				///scene.addChild(frame1);
				//uploadResources(frame1.getResources());
				//var frame1:WireFrame = getBVFrame(aabbTree.root);
				//frame = getBVFrame(mesh.boundBox);
				//scene.addChild(frame);
				//uploadResources(frame.getResources());
				//scene.addChild(frame1);
				//uploadResources(frame1.getResources());			
				moveObject(box1,x,y,z);
				//box1.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
				//addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				//box1.addEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
			}
			
		}
		
		//协方差方法，弃用
		private function split(mesh:Mesh):void{
			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var height:int = mesh.boundBox.maxZ - mesh.boundBox.minZ;//1
			var pPoints:Array = new Array(height);
			var lastCov:Number = 0;
			var curCov:Number = 0;
			for(var i:int = 2; i < points.length / 3; i += 3)
			{
				var ptHeight:int = points[i];
				if(pPoints[ptHeight] == undefined)
				{
					pPoints[ptHeight] = new Vector.<int>();
				}
				Vector.<int>(pPoints[ptHeight]).push(i);
			}
			for(var i:int = 0; i < height; i++)
			{
				if(pPoints[i] != undefined)
				{
					var ex:Number = 0;
					var ey:Number = 0;
					var cov:Number = 0;
					var ptNum:int = Vector.<int>(pPoints[ptHeight]).length;
					for(var j:int = 0; i < ptNum; i++)
					{
						ex += points[pPoints[ptHeight][j]];
						ey += points[pPoints[ptHeight][j] + 1];
					}
					ex /= ptNum;
					ey /= ptNum;
					for(var k:int = 0; k < ptNum; k++)
					{
						cov += (points[pPoints[ptHeight][k]] - ex) * (points[pPoints[ptHeight][k] + 1] - ey);
					}
					cov /=ptNum;
					if(curCov == 0 && lastCov == 0)
					{
						lastCov = cov;
					}	
					else
					{
						curCov = cov;
						if((curCov - lastCov) > 1 )
						{
							b1 = new BoundBox();
							b2 = new BoundBox();
							
							b1.maxX = b2.maxX = mesh.boundBox.maxX;
							b1.maxY = b2.maxY = mesh.boundBox.maxY;
							b1.maxZ = b2.maxZ = mesh.boundBox.maxZ;
							b1.minX = b2.minX = mesh.boundBox.minX;
							b1.minY = b2.minY = mesh.boundBox.minY;
							b1.minZ = b2.minZ = mesh.boundBox.minZ;
							
							b1.minZ = i;//
							b2.maxZ = i;
							return;
						}
						lastCov = cov;
					}
				}
			}
		}
		
		
		
		private function uploadResources(resources:Vector.<Resource>):void {
			for each (var resource:Resource in resources) {
				resource.upload(stage3D.context3D);
			}
		}
		
		
	}
	

}