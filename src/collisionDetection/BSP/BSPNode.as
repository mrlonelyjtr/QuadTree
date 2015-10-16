package collisionDetection.BSP
{
	import collisionDetection.utils.Plane;
	import collisionDetection.utils.Triangle;

	public class BSPNode
	{
		private var polygons:Vector.<Triangle>;
		private var frontTree:BSPNode;
		private var backTree:BSPNode;
		private var plane:Plane;
		public function BSPNode()
		{
			this.polygons = null;
			this.frontTree = null;
			this.backTree = null;
		}
		
		public function setPolygons(polygons:Vector.<Triangle>):void
		{
			this.polygons = polygons;
		}
		
		public function setChildren(frontTree:BSPNode, backTree:BSPNode):void
		{
			
			this.frontTree = frontTree;
			this.backTree = backTree;
		}
		
		public function setPlane(plane:Plane):void
		{
			this.plane = plane;
		}
	}
}