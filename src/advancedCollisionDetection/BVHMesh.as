package advancedCollisionDetection
{	
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.objects.Mesh;
	
	import flash.geom.Vector3D;
	
	public class BVHMesh extends Mesh
	{
		private var mesh:Mesh;
		private var aabb:AABB;
		private var obb:OBB;
		private var octree:Octree;
		
		public function BVHMesh(mesh:Mesh){
			this.mesh = mesh;
		}
		
		public function getMesh():Mesh{
			return mesh;
		}
		
		public function initAABB():void{
			aabb = new AABB(mesh);
			aabb.initAABB();
		}
		
		public function getProjection():Object{
			return aabb.getProjection();
		}
		
		public function initOBB():void{
			obb = new OBB(mesh);
			obb.initOBB();
		}
		
		public function initOctree(m:Mesh):void{
			octree = new Octree(mesh);
			octree.initOctree();
		}
		
		public function getTree():Octree{
			return octree;
		}
		
	}
}