package collisionDetection.utils
{
	import flash.geom.Vector3D;

	public class Plane
	{
		private var n:Vector3D;
		private var d:Number;
		
		public function Plane(n:Vector3D, d:Number)
		{
			this.n = n;
			this.d = d;
		}
		
		public function getN():Vector3D
		{
			return n;
		}
		
		public function getD():Number
		{
			return d;
		}
	}
}