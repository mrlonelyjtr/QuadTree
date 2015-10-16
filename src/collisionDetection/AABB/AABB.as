// ActionScript file
package collisionDetection.AABB
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	
	import collisionDetection.utils.CollTime;
	
	import flash.geom.Vector3D;

	public class AABB
	{
		public function AABB()
		{
			
		}
		
		
		//生成包围盒
		public function generateBoundBox(mesh:Mesh):void{
			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var maxX:Number = points[0];
			var maxY:Number = points[1];
			var maxZ:Number = points[2];
			var minX:Number = points[0];
			var minY:Number = points[1];
			var minZ:Number = points[2];
			//根据点的坐标算出每个轴上最大和最小的值
			for(var ix:int = 3; ix < points.length - 2; ix += 3)
			{
				if(points[ix] > maxX)
				{
					maxX = points[ix];
				}
				if(points[ix] < minX)
				{
					minX = points[ix];
				}
			}
			
			for(var iy:int = 4; iy < points.length - 1; iy += 3)
			{
				if(points[iy] > maxY)
				{
					maxY = points[iy];
				}
				if(points[iy] < minY)
				{
					minY = points[iy];
				}
			}
			
			for(var iz:int = 5; iz < points.length; iz += 3)
			{
				if(points[iz] > maxZ)
				{
					maxZ = points[iz];
				}
				if(points[iz] < minZ)
				{
					minZ = points[iz];
				}
			}
			
			mesh.boundBox.maxX = maxX;
			mesh.boundBox.maxY = maxY;
			mesh.boundBox.maxZ = maxZ;
			mesh.boundBox.minX = minX;
			mesh.boundBox.minY = minY;
			mesh.boundBox.minZ = minZ;
		}
		
		//两个包围盒之间的静态碰撞检测
		public function getCollision(a:BoundBox, b:BoundBox):Boolean{
			if(a.maxX < b.minX || b.maxX < a.minX)
			{
				return false;
			}
			if(a.maxY < b.minY || b.maxY < a.minY)
			{
				return false;
			}
			if(a.maxZ < b.minZ || b.maxZ < a.minZ)
			{
				return false;
			}
			return true;
		}
		
		public function getWorldBoundBox(Obj:Object3D):BoundBox
		{
			var newB:BoundBox = new BoundBox();
			var oldB:BoundBox = Obj.boundBox;
			newB.maxX = oldB.maxX + Obj.x;
			newB.minX = oldB.minX + Obj.x;
			newB.maxY = oldB.maxY + Obj.y;
			newB.minY = oldB.minY + Obj.y;
			newB.maxZ = oldB.maxZ + Obj.z;
			newB.minZ = oldB.minZ + Obj.z;
			return newB;
		}
		
		public function getMovingCollisionForObj(ObjA:Object3D, ObjB:Object3D, va:Vector3D, vb:Vector3D, time:CollTime):Boolean
		{
			var a:BoundBox = getWorldBoundBox(ObjA);
			var b:BoundBox = getWorldBoundBox(ObjB);
			return getMovingCollision(a, b, va, vb, time);

		}
		
		//动态碰撞检测测试，tfirst是碰撞时间，tlast是分离时间
		public function getMovingCollision(a:BoundBox, b:BoundBox, va:Vector3D, vb:Vector3D, time:CollTime):Boolean{
			
			if(getCollision(a, b))
			{
				time.tfirst = 0;
				time.tlast = 0;
				return true;
			}
			
			var v:Vector3D = vb.subtract(va);
			var deviation:Number = 0.001;
			time.tfirst = 0;
			time.tlast = 1;
			//方向为负
			if(v.x < 0)
			{
				if(b.maxX < a.minX) //b在a左边，分离，不会碰撞
					return false;
				if(a.maxX < b.minX) //b在a右边，靠近，碰撞事件为碰撞边距离除以速度。
					time.tfirst = Math.max((a.maxX - b.minX) / v.x, time.tfirst) - deviation;
				if(b.maxX >= a.minX)
					time.tlast = Math.min((a.minX - b.maxX) / v.x, time.tlast);
			}
			
			if(v.x > 0)
			{
				if(b.minX > a.maxX) 
					return false;
				if(b.maxX < a.minX)
					time.tfirst = Math.max((a.minX - b.maxX) / v.x, time.tfirst) - deviation;
				if(a.maxX >= b.minX)
					time.tlast = Math.min((a.maxX - b.minX) / v.x, time.tlast);
			}
			
			if(v.x == 0)
			{
				if(b.minX > a.maxX) 
					return false;
				if(b.maxX < a.minX)
					return false;
			}
			
			
			if(time.tfirst > time.tlast)
				return false;
			
			if(v.y < 0)
			{
				if(b.maxY < a.minY) 
					return false;
				if(a.maxY < b.minY)
					time.tfirst = Math.max((a.maxY - b.minY) / v.y, time.tfirst) - deviation;
				if(b.maxY >= a.minY)
					time.tlast = Math.min((a.minY - b.maxY) / v.y, time.tlast);
			}
			
			if(v.y > 0)
			{
				if(b.minY > a.maxY) 
					return false;
				if(b.maxY < a.minY)
					time.tfirst = Math.max((a.minY - b.maxY) / v.y, time.tfirst) - deviation;
				if(a.maxY >= b.minY)
					time.tlast = Math.min((a.maxY - b.minY) / v.y, time.tlast);
			}
			
			if(v.y == 0)
			{
				if(b.minY > a.maxY) 
					return false;
				if(b.maxY < a.minY)
					return false;
			}
			
			if(time.tfirst > time.tlast)
				return false;
			
			if(v.z < 0)
			{
				if(b.maxZ < a.minZ) 
					return false;
				if(a.maxZ < b.minZ)
					time.tfirst = Math.max((a.maxZ - b.minZ) / v.z, time.tfirst) - deviation;
				if(b.maxZ >= a.minZ)
					time.tlast = Math.min((a.minZ - b.maxZ) / v.z, time.tlast);
			}
			
			if(v.z > 0)
			{
				if(b.minZ > a.maxZ) 
					return false;
				if(b.maxZ < a.minZ)
					time.tfirst = Math.max((a.minZ - b.maxZ) / v.z, time.tfirst) - deviation;
				if(a.maxZ >= b.minZ)
					time.tlast = Math.min((a.maxZ - b.minZ) / v.z, time.tlast);
			}
			
			if(v.z == 0)
			{
				if(b.minZ > a.maxZ) 
					return false;
				if(b.maxZ < a.minZ)
					return false;
			}
			
			if(time.tfirst > time.tlast)
				return false;
			
			return true;
			
		}
		

		
/*		public function moveFrame(x:int, y:int, z:int):void{
			frame.x = x;
			frame.y = y;
			frame.z = z;
		}*/
		
		public function rotateBoundBox(o:Object3D ):void{
			
/*			var m:Vector.<Number> = o.matrix.rawData;
			var a:BoundBox = o.boundBox.clone();
			var center:Vector3D = new Vector3D( ( a.maxX + a.minX ) / 2, ( a.maxY + a.minY ) / 2, ( a.maxZ + a.minZ ) / 2);
			a.maxX -= center.x;
			a.minX -= center.x;
			a.maxY -= center.y;
			a.minY -= center.y;
			a.maxZ -= center.z;
			a.minZ -= center.z;
			trace(center.x,center.y,center.z);
			var b:BoundBox = o.boundBox;
			
			b.maxX = Math.max(m[0] * a.minX, m[0] * a.maxX) 
				+ Math.max(m[1] * a.minY, m[1] * a.maxY) 
				+ Math.max(m[2] * a.minZ, m[2] * a.maxZ) + center.x;
			b.maxY = Math.max(m[4] * a.minX, m[4] * a.maxX) 
				+ Math.max(m[5] * a.minY, m[5] * a.maxY) 
				+ Math.max(m[6] * a.minZ, m[6] * a.maxZ) + center.y;
			b.maxZ = Math.max(m[8] * a.minX, m[8] * a.maxX) 
				+ Math.max(m[9] * a.minY, m[9] * a.maxY) 
				+ Math.max(m[10] * a.minZ, m[10] * a.maxZ) + center.z;
			
			b.minX = Math.min(m[0] * a.minX, m[0] * a.maxX) 
				+ Math.min(m[1] * a.minY, m[1] * a.maxY) 
				+ Math.min(m[2] * a.minZ, m[2] * a.maxZ) + center.x;
			b.minY = Math.min(m[4] * a.minX, m[4] * a.maxX) 
				+ Math.min(m[5] * a.minY, m[5] * a.maxY) 
				+ Math.min(m[6] * a.minZ, m[6] * a.maxZ) + center.y;
			b.minZ = Math.min(m[8] * a.minX, m[8] * a.maxX) 
				+ Math.min(m[9] * a.minY, m[9] * a.maxY) 
				+ Math.min(m[10] * a.minZ, m[10] * a.maxZ) + center.z;
			trace(b.maxX,b.minX,b.maxY,b.minY);
			trace((b.maxX + b.minX)/2, (b.maxY + b.minY)/2,(b.maxZ + b.minZ)/2);*/
			
			var a0:Vector3D = new Vector3D();
			var a1:Vector3D = new Vector3D();
			
			
		}

	}

}	


	
	