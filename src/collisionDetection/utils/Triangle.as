package collisionDetection.utils
{
	import flash.geom.Vector3D;

	public class Triangle
	{
		private var A:Vector3D;
		private var B:Vector3D;
		private var C:Vector3D;
		public function Triangle(a:Vector3D, b:Vector3D, c:Vector3D)
		{
			A = a;
			B = b;
			C = c;
		}
		
		public function getA():Vector3D
		{
			return A;
		}
		
		public function getB():Vector3D
		{
			return B;
		}
		
		public function getC():Vector3D
		{
			return C;
		}
		
		public function copy(tri:Triangle):void
		{
			A = tri.A;
			B = tri.B;
			C = tri.C;
		}
		public function getArea():Number
		{
			return 0;
		}
	}
}