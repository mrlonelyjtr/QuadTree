package advancedCollisionDetection
{
	import alternativa.engine3d.core.BoundBox;

	public class OctreeNode extends BoundBox
	{
		public var children:Vector.<OctreeNode>;
		
		public function OctreeNode(){
			super();
			maxX = maxY = maxZ = minX = minY = minZ = 0;
			children = new Vector.<OctreeNode>();
			for(var i:int = 0; i < 8; i++)
				this.children[i] = null;
		}
	}
}