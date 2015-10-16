package
{
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
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
	
	import collisionDetection.utils.CollTime;
	import collisionDetection.AABB.*;
	import collisionDetection.BSP.*;
	
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
	
	public class BSPTest extends Sprite
	{	
		
		private var stage3D:Stage3D;
		private var camera:Camera3D;
		private var box:Box;
		private var mesh:Mesh;
		private var scene:Object3D = new Object3D();
		private var controller:SimpleObjectController;
		private var lastX:int;
		private var lastY:int;
		private static var a:BoundBox;
		private var aabb:AABB = new AABB();
		private var bspTree:BSPTree;
		//private var aabbcnt:int = 0;
		
		
		public function BSPTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//摄影机初始化
			camera = new Camera3D(0.1,10000);
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			addChild(camera.view);
			addChild(camera.diagram);
			
			camera.rotationX = -120*Math.PI/180;
			camera.y = -250;
			camera.z = 250;
			camera.x = 100;
			controller = new SimpleObjectController(stage, camera,500,2);
			scene.addChild(camera);
			
			
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
			stage3D.requestContext3D();
		}
		
		private function init(e:Event):void
		{
			var radius:int = 500;
			var vBound:int = 5;

			loadModel1(0, 0, 0, "chuangtougui.DAE");

			
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
			controller.update();
			
			
			
			
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			var deviation:Number = 0.8;
			if(e.keyCode == 82)
			{
				mesh.rotationZ +=0.05;
				//rotateBoundBox(mesh);
				//moveFrame(mesh.x, mesh.y, mesh.z);
				
			}
		}
		
		public function moveObject(o:Object3D, vx:Number, vy:Number, vz:Number):void{
			
			o.x += vx;
			o.y += vy;
			o.z += vz;
			
		}
		
		private function getIntersectedDist(a:AABBTree, b:AABBTree):Vector3D{
			var ba:BoundBox = a.getBoundBox();
			var bb:BoundBox = b.getBoundBox();
			var aPos:Vector3D = a.getPos();
			var bPos:Vector3D = b.getPos();
			var abDist:Vector3D = new Vector3D();
			abDist.x = Math.abs(ba.maxX - aPos.x) + Math.abs(bb.maxX - bPos.x) - Math.abs(bPos.x - aPos.x) / 2;
			abDist.y = Math.abs(ba.maxY - aPos.y) + Math.abs(bb.maxY - bPos.y) - Math.abs(bPos.y - aPos.y) / 2;
			abDist.z = Math.abs(ba.maxZ - aPos.z) + Math.abs(bb.maxZ - bPos.z) - Math.abs(bPos.z - aPos.z) / 2;
			if(bPos.x - aPos.x < 0)
			{
				abDist.x = -abDist.x;
			}
			if(bPos.y - aPos.y < 0)
			{
				abDist.y = -abDist.y;
			}
			if(bPos.z - aPos.z < 0)
			{
				abDist.z = -abDist.z;
			}
			
			return abDist;
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
						
						trace(mesh.boundBox.minX);
						trace(mesh.boundBox.maxX);
					}
				}
				bspTree = new BSPTree(mesh);	
				//aabbcnt++;
				
				moveObject(mesh,x,y,z);
				
			}
			
		}
		
		private function uploadResources(resources:Vector.<Resource>):void {
			for each (var resource:Resource in resources) {
				resource.upload(stage3D.context3D);
			}
		}
		
		
	}
	
	
}// ActionScript file