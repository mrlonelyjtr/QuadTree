package advancedCollisionDetection
{
	import collisionDetection.utils.CollTime;
	
	import flash.geom.Vector3D;

	public class CollisionDetectionIn2D
	{	
		public function CollisionDetectionIn2D(){
		}
		
		public function dynamicCollisionDetection(objectA:Object, objectB:Object, vA:Vector3D, vB:Vector3D, collisionTime:CollTime):Boolean{
			if (staticCollisionDetection(objectA, objectB)){
				collisionTime.tfirst = 0;
				collisionTime.tlast = 0;
				return true;
			}
			
			var v:Vector3D = vB.subtract(vA);
			var deviation:Number = 0.001;
			collisionTime.tfirst = 0;
			collisionTime.tlast = 1;
			
			var minXForObjectA:Number = objectA.x;
			var maxXForObjectA:Number = objectA.x + objectA.width;
			var minYForObjectA:Number = objectA.y;
			var maxYForObjectA:Number = objectA.y + objectA.height;
			
			var minXForObjectB:Number = objectB.x;
			var maxXForObjectB:Number = objectB.x + objectB.width;
			var minYForObjectB:Number = objectB.y;
			var maxYForObjectB:Number = objectB.y + objectB.height;
			
			if (v.x == 0){
				if (minXForObjectB > maxXForObjectA) 
					return false;
				
				if (maxXForObjectB < minXForObjectA)
					return false;
			}
			
			if (v.x > 0){
				if (minXForObjectB > maxXForObjectA) 
					return false;
				
				if (maxXForObjectB < minXForObjectA)
					collisionTime.tfirst = Math.max((minXForObjectA - maxXForObjectB) / v.x, collisionTime.tfirst) - deviation;
				
				if (maxXForObjectA >= minXForObjectB)
					collisionTime.tlast = Math.min((maxXForObjectA - minXForObjectB) / v.x, collisionTime.tlast);
			}
			
			if (v.x < 0){
				if (maxXForObjectB < minXForObjectA)
					return false;
				
				if (maxXForObjectA < minXForObjectB)
					collisionTime.tfirst = Math.max((maxXForObjectA - minXForObjectB) / v.x, collisionTime.tfirst) - deviation;
				
				if (maxXForObjectB >= minXForObjectA)
					collisionTime.tlast = Math.min((minXForObjectA - maxXForObjectB) / v.x, collisionTime.tlast);
			}
			
			if(collisionTime.tfirst > collisionTime.tlast)
				return false;
			
			if (v.y == 0){
				if (minYForObjectB > maxYForObjectA) 
					return false;
				
				if (maxYForObjectB < minYForObjectA)
					return false;
			}
			
			if (v.y > 0){
				if (minYForObjectB > maxYForObjectA) 
					return false;
				
				if (maxXForObjectB < minXForObjectA)
					collisionTime.tfirst = Math.max((minXForObjectA - maxXForObjectB) / v.y, collisionTime.tfirst) - deviation;
				
				if (maxYForObjectA >= minYForObjectB)
					collisionTime.tlast = Math.min((maxYForObjectA - minYForObjectB) / v.y, collisionTime.tlast);
			}
		
			if (v.y < 0){
				if (maxYForObjectB < minYForObjectA) 
					return false;
				
				if (maxYForObjectA < minYForObjectB)
					collisionTime.tfirst = Math.max((maxYForObjectA - minYForObjectB) / v.y, collisionTime.tfirst) - deviation;
				
				if (maxYForObjectB >= minYForObjectA)
					collisionTime.tlast = Math.min((minYForObjectA - maxYForObjectB) / v.y, collisionTime.tlast);
			}
			
			if(collisionTime.tfirst > collisionTime.tlast)
				return false;
			
			return true;
		}
		
		public function staticCollisionDetection(objectA:Object, objectB:Object):Boolean{
			var minXForObjectA:Number = objectA.x;
			var maxXForObjectA:Number = objectA.x + objectA.width;
			var minYForObjectA:Number = objectA.y;
			var maxYForObjectA:Number = objectA.y + objectA.height;
			
			var minXForObjectB:Number = objectB.x;
			var maxXForObjectB:Number = objectB.x + objectB.width;
			var minYForObjectB:Number = objectB.y;
			var maxYForObjectB:Number = objectB.y + objectB.height;
			
			if (maxXForObjectA < minXForObjectB || maxXForObjectB < minXForObjectA){
				return false;
			}
			
			if (maxYForObjectA < minYForObjectB || maxYForObjectB < minYForObjectA){
				return false;
			}
			
			return true;
		}
	}
}