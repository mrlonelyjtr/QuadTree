package collisionDetection.AABB
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.objects.Mesh;
	
	public class BVHMesh
	{
		private var mesh:Mesh;
		private var aabbTree:AABBTree;
		
		public function BVHMesh(mesh:Mesh)
		{
			this.mesh = mesh;
			//aabbTree = new AABBTree();
			//aabbTree.initAABBTree(mesh);
		}
		
		public function getMesh():Mesh
		{
			return mesh;
		}
		
		public function getBoundBox():BoundBox
		{
			return aabbTree.getBoundBox();
		}
		
		public function getTree():AABBTree
		{
			return aabbTree;
		}
		
		public function initTree():void
		{
			aabbTree = new AABBTree();
			aabbTree.initAABBTree(mesh);
		}
	}
}
