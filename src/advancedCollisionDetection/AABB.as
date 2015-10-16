package advancedCollisionDetection
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
		
	public class AABB
	{
		private var aabbProjection:Object = new Object();
		private var mesh:Mesh;
		
		public function AABB(mesh:Mesh){
			this.mesh = mesh;
		}
		
		public function initAABB():void{	
			aabbToWorld(mesh);
			
//			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
//			var maxX:Number = points[0];
//			var maxY:Number = points[1];
//			var maxZ:Number = points[2];
//			var minX:Number = points[0];
//			var minY:Number = points[1];
//			var minZ:Number = points[2];
//			
//			for(var i:int = 3; i < points.length - 2; i += 3){
//				if(points[i] > maxX)
//					maxX = points[i];
//				
//				if(points[i] < minX)
//					minX = points[i];
//			}
//			
//			for(var j:int = 4; j < points.length - 1; j += 3){
//				if(points[j] > maxY)
//					maxY = points[j];
//				
//				if(points[j] < minY)
//					minY = points[j];
//			}
//			
//			for(var k:int = 5; k < points.length; k += 3){
//				if(points[k] > maxZ)
//					maxZ = points[k];
//				
//				if(points[k] < minZ)
//					minZ = points[k];
//			}
//			
//			mesh.boundBox.maxX = maxX;
//			mesh.boundBox.maxY = maxY;
//			mesh.boundBox.maxZ = maxZ;
//			mesh.boundBox.minX = minX;
//			mesh.boundBox.minY = minY;
//			mesh.boundBox.minZ = minZ;
		}
		
		private function aabbToWorld(mesh:Mesh):void{
			var aabb:BoundBox = mesh.boundBox;	
			var worldAABB:BoundBox = new BoundBox();
			
			worldAABB.maxX = aabb.maxX + mesh.x;
			worldAABB.minX = aabb.minX + mesh.x;
			worldAABB.maxY = aabb.maxY + mesh.y;
			worldAABB.minY = aabb.minY + mesh.y;
			worldAABB.maxZ = aabb.maxZ + mesh.z;
			worldAABB.minZ = aabb.minZ + mesh.z;
			
			aabbProjection.name = mesh.name;
			aabbProjection.x = worldAABB.minX;
			aabbProjection.y = worldAABB.minY;
			aabbProjection.width = worldAABB.maxX - worldAABB.minX;
			aabbProjection.height = worldAABB.maxY - worldAABB.minY;	
		}
		
		public function getProjection():Object{
			return aabbProjection;
		}
		
	}
}