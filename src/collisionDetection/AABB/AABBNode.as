package collisionDetection.AABB
{
	import alternativa.engine3d.core.BoundBox;
	
	import flash.geom.Vector3D;

	//八叉树结点
	public class AABBNode extends BoundBox
	{
		//结点的儿子们
		public var children:Vector.<AABBNode>;
		public var origBound:BoundBox = new BoundBox();

		public function AABBNode()
		{
			super();
			maxX = maxY = maxZ = minX = minY = minZ = 0;
			children = new Vector.<AABBNode>();
			for(var i:int = 0; i < 8; i++)
			{
				this.children[i] = null;
			}
		}
		
		public function rotateAABBNode(theta:Number, reviseX:Number, reviseY:Number):void
		{
				
			var a0:Vector3D = new Vector3D(origBound.minX, origBound.maxY);
			var a1:Vector3D = new Vector3D(origBound.maxX, origBound.maxY);
			var b0:Vector3D = new Vector3D(origBound.minX, origBound.minY);
			var b1:Vector3D = new Vector3D(origBound.maxX, origBound.minY);
			
			var costh:Number = Math.cos(theta);
			var sinth:Number = Math.sin(theta);
			
			var a0n:Vector3D = new Vector3D(a0.x * costh - a0.y * sinth, a0.x * sinth + a0.y * costh);
			var a1n:Vector3D = new Vector3D(a1.x * costh - a1.y * sinth, a1.x * sinth + a1.y * costh);
			var b0n:Vector3D = new Vector3D(b0.x * costh - b0.y * sinth, b0.x * sinth + b0.y * costh);
			var b1n:Vector3D = new Vector3D(b1.x * costh - b1.y * sinth, b1.x * sinth + b1.y * costh);
			
			maxX = Math.max(a0n.x, a1n.x, b0n.x, b1n.x) + reviseX;
			minX = Math.min(a0n.x, a1n.x, b0n.x, b1n.x) + reviseX;
			maxY = Math.max(a0n.y, a1n.y, b0n.y, b1n.y) + reviseY;
			minY = Math.min(a0n.y, a1n.y, b0n.y, b1n.y) + reviseY;
			
			//maxX = Math.max(a0n.x, a1n.x, b0n.x, b1n.x) + reviseX;
			//minX = Math.min(a0n.x, a1n.x, b0n.x, b1n.x) + reviseX;
			//maxY = Math.max(a0n.y, a1n.y, b0n.y, b1n.y) + reviseY;
			//minY = Math.min(a0n.y, a1n.y, b0n.y, b1n.y) + reviseY;
			
			for(var i:int = 0; i < 8; i++)
			{
				if(children[i])
				{
				    children[i].rotateAABBNode(theta, reviseX, reviseY);
				}
				
			}
			

		}
	}
}