package advancedCollisionDetection
{	
	import alternativa.engine3d.core.BoundBox;
	
	import flash.geom.Vector3D;
	
	public class CollisionDetectionIn3D
	{
		public function CollisionDetectionIn3D(){
		}
		
		public function collideDetection(a:BoundBox, b:BoundBox):Boolean{	
			var objectA:Object = new Object();
			objectA.min = new Vector3D(a.minX, a.minY, a.minZ);
			objectA.max = new Vector3D(a.maxX, a.maxY, a.maxZ);
			
			var objectB:Object = new Object();
			objectB.min = new Vector3D(b.minX, b.minY, b.minZ);
			objectB.max = new Vector3D(b.maxX, b.maxY, b.maxZ);
			
			var min1:Number;
			var max1:Number;
			var min2:Number;
			var max2:Number;
			
			for (var i:int = 0; i < 3; i++){
				var value1:Array = getInterval(objectA, getFaceDirection(objectA, i), min1, max1);
				min1 = value1[0];
				max1 = value1[1];
				var value2:Array = getInterval(objectB, getFaceDirection(objectA, i), min2, max2);
				min2 = value2[0];
				max2 = value2[1];
				
				if (max1 < min2 || max2 < min1)
					return false;	
			}
			
			for (var i:int = 0; i < 3; i++){
				var value1:Array = getInterval(objectA, getFaceDirection(objectB, i), min1, max1);
				min1 = value1[0];
				max1 = value1[1];
				var value2:Array = getInterval(objectB, getFaceDirection(objectB, i), min2, max2);
				min2 = value2[0];
				max2 = value2[1];
				
				if (max1 < min2 || max2 < min1)
					return false;	
			}
			
			for (var i:int = 0; i < 3; i++){
				for (var j = 0; j < 3; j++){
					var edge:Vector3D = new Vector3D();
					edge = getEdgeDirection(objectA, i).crossProduct(getEdgeDirection(objectB, j));
					var value1:Array = getInterval(objectA, edge, min1, max1);
					min1 = value1[0];
					max1 = value1[1];
					var value2:Array = getInterval(objectB, edge, min2, max2);
					min2 = value2[0];
					max2 = value2[1];
					
					if (max1 < min2 || max2 < min1)
						return false;	
				}
			}
			
			return true;
		}
		
		private function getCorners(object:Object, corners:Vector.<Vector3D>):Vector.<Vector3D>{
			corners[0] = new Vector3D(object.min.x, object.max.y, object.max.z);
			corners[1] = new Vector3D(object.min.x, object.min.y, object.max.z);
			corners[2] = new Vector3D(object.max.x, object.min.y, object.max.z);
			corners[3] = new Vector3D(object.max.x, object.max.y, object.max.z);
			
			corners[4] = new Vector3D(object.max.x, object.max.y, object.min.z);
			corners[5] = new Vector3D(object.max.x, object.min.y, object.min.z);
			corners[6] = new Vector3D(object.min.x, object.min.y, object.min.z);
			corners[7] = new Vector3D(object.min.x, object.max.y, object.min.z);
			
			return corners;
		}
		
		private function getFaceDirection(object:Object, index:int):Vector3D{
			var corners:Vector.<Vector3D> = new Vector.<Vector3D>(8);
			
			getCorners(object, corners);
			
			var faceDirection:Vector3D = new Vector3D();
			var v0:Vector3D;
			var v1:Vector3D;
			
			switch(index){
				case 0:
//					v0 = new Vector3D(corners[7].x - corners[6].x, corners[7].y - corners[6].y, corners[7].z - corners[6].z);
//					v1 = new Vector3D(corners[5].x - corners[6].x, corners[5].y - corners[6].y, corners[5].z - corners[6].z)
//					
//					faceDirection = v0.crossProduct(v1);
//					faceDirection.normalize();
					faceDirection = new Vector3D(0, 0, 1);
					break;
				
				case 1:
//					v0 = new Vector3D(corners[1].x - corners[6].x, corners[1].y - corners[6].y, corners[1].z - corners[6].z);
//					v1 = new Vector3D(corners[7].x - corners[6].x, corners[7].y - corners[6].y, corners[7].z - corners[6].z)
//					
//					faceDirection = v0.crossProduct(v1);
//					faceDirection.normalize();
					faceDirection = new Vector3D(1, 0, 0);
					break;
				
				case 2:
//					v0 = new Vector3D(corners[1].x - corners[6].x, corners[1].y - corners[6].y, corners[1].z - corners[6].z);
//					v1 = new Vector3D(corners[5].x - corners[6].x, corners[5].y - corners[6].y, corners[5].z - corners[6].z)
//					
//					faceDirection = v0.crossProduct(v1);
//					faceDirection.normalize();
					faceDirection = new Vector3D(0, 1, 0);
					break;
			}
			
			return faceDirection;
		}
		
		private function getInterval(object:Object, axis:Vector3D, min:Number, max:Number):Array{
			var corners:Vector.<Vector3D> = new Vector.<Vector3D>(8);
			var val:Array = new Array();
			
			getCorners(object, corners);
			
			min = max = projectPoint(axis, corners[0]);
			
			for (var i:int = 1; i < 8; i++){
				var value:Number = projectPoint(axis, corners[i]);
				min = Math.min(min, value);
				max = Math.max(max, value);
			}
			
			val.push(min);
			val.push(max);
			
			return val;
		}
		
		private function projectPoint(point:Vector3D, axis:Vector3D):Number{
			var dot:Number = axis.dotProduct(point);
			return dot * point.length;	
		}
		
		private function getEdgeDirection(object:Object, index:int):Vector3D{
			var corners:Vector.<Vector3D> = new Vector.<Vector3D>(8);
			
			getCorners(object, corners);
			
			var tmpLine:Vector3D;
			
			switch(index){
				case 0: 
//					tmpLine = new Vector3D(corners[5].x = corners[6].x, corners[5].y - corners[6].y, corners[5].z - corners[6].z);
//					tmpLine.normalize();
					tmpLine = new Vector3D(1, 0, 0);
					break;
				
				case 1: 
//					tmpLine = new Vector3D(corners[7].x = corners[6].x, corners[7].y - corners[6].y, corners[7].z - corners[6].z);
//					tmpLine.normalize();
					tmpLine = new Vector3D(0, 1, 0);
					break;
				
				case 2: 
//					tmpLine = new Vector3D(corners[1].x = corners[6].x, corners[1].y - corners[6].y, corners[1].z - corners[6].z);
//					tmpLine.normalize();
					tmpLine = new Vector3D(0, 0, 1);
					break;
			}
			
			return tmpLine;
		}
		
		
		
		
	}
}