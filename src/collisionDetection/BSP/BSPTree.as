package collisionDetection.BSP
{
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	
	import collisionDetection.BSP.BSPNode;
	import collisionDetection.utils.Plane;
	import collisionDetection.utils.Triangle;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class BSPTree
	{
		private const MAX_DEPTH:int = 5;
		private const MIN_LEAF_SIZE:int = 3;
	    private const COPLANAR_WITH_PLANE:int = 10;
		private const IN_FRONT_OF_PLANE:int = 11;
		private const BEHIND_PLANE:int = 12;
		private const STRADDLING_PLANE:int = 13;
		
		private const POINT_ON_PLANE:int = 14;
		private const POINT_IN_FRONT_OF_PLANE:int = 15;
		private const POINT_BEHIND_PLANE:int = 16;
		
		private var root:BSPNode;
		
		public function BSPTree(mesh:Mesh)
		{			
			var indices:Vector.<uint> = mesh.geometry.indices;
			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var indexLen:int = mesh.geometry.indices.length;
			var polygons:Vector.<Triangle> = new Vector.<Triangle>();
			
			var a:Vector3D;
			var b:Vector3D;
			var c:Vector3D;
			
			//i:三角形编号
			//indices[3*i]:第i个三角形的第一个顶点
			//points[3*indices[3*i]]:第i个三角形的第一个顶点的x坐标
			for(var i:int = 0; i < indexLen / 3; i++)
			{
				a = new Vector3D(points[3 * indices[3 * i + 0]], points[3 * indices[3 * i + 0] + 1], points[3 * indices[3 * i + 0] + 2]);
				b = new Vector3D(points[3 * indices[3 * i + 1]], points[3 * indices[3 * i + 1] + 1], points[3 * indices[3 * i + 1] + 2]);
				c = new Vector3D(points[3 * indices[3 * i + 2]], points[3 * indices[3 * i + 2] + 1], points[3 * indices[3 * i + 2] + 2]);
				polygons[i] = new Triangle(a, b, c);
			}	
			
			root = buildBSPTree(polygons, 1);
			
		}
		
		//构造BSP树
		private function buildBSPTree(polygons:Vector.<Triangle>, depth:int):BSPNode
		{
			//迭代到空节点
			if(polygons.length == 0) 
				return null;
			
			var numPolygons:int = polygons.length;
			//迭代到一定程度，不必再二分
			if(depth >= MAX_DEPTH || numPolygons <= MIN_LEAF_SIZE)
			{
				var bsp:BSPNode = new BSPNode();
				bsp.setPolygons(polygons);
				return bsp;
			}
			//取得分割面
			var splitPlane:Plane = pickSplittingPlane(polygons);
			
			//分割面前后的多边形列表
			var frontList:Vector.<Triangle> = new Vector.<Triangle>();
			var backList:Vector.<Triangle> = new Vector.<Triangle>();
			
			
			for(var i:int = 0; i < numPolygons; i++)
			{
				var poly:Triangle = polygons[i];
				//可能将跨越分割面的多边形分为前半和后半
				var frontPart:Triangle = new Triangle(null,null,null);
				var backPart:Triangle = new Triangle(null,null,null);
				//将当前多边形按其所处位置分类
				switch(classifyPolygonToPlane(poly, splitPlane))
				{
					
					case COPLANAR_WITH_PLANE://共面

					case IN_FRONT_OF_PLANE://面前
						frontList.push(poly);
						break;
					case BEHIND_PLANE://面后
						backList.push(poly);
						break;
					case STRADDLING_PLANE://跨越面
						//splitPolygon(poly, splitPlane, frontPart, backPart);
						frontPart.copy(poly);
						backPart.copy(poly);
						frontList.push(frontPart);
						backList.push(backPart);
						break;
					default:
						break;
				}
			}	
			var frontTree:BSPNode = buildBSPTree(frontList,depth + 1);
			var backTree:BSPNode = buildBSPTree(backList,depth + 1);
			var bsp:BSPNode = new BSPNode();
			bsp.setChildren(frontTree, backTree);
			bsp.setPlane(splitPlane);
			return bsp;		
		}
		
		private function pickSplittingPlane(polygons:Vector.<Triangle>):Plane
		{
			const K:Number = 0.8;
			
			var bestPlane:Plane;
			var bestScore:Number = Number.MAX_VALUE;
			
			for(var i:int = 0; i < polygons.length; i++)
			{
				var numFront:int = 0;
				var numBehind:int = 0;
				var numStraddling = 0;
				
				var plane:Plane = getPlaneFromPolygon(polygons[i]);
				
				for(var j:int = 0; j < polygons.length; j++)
				{
					if( i == j)
						continue;
					//将当前多边形按其所处位置分类
					switch(classifyPolygonToPlane(polygons[j], plane))
					{
						
						case COPLANAR_WITH_PLANE://共面
							
						case IN_FRONT_OF_PLANE://面前
							numFront++;
							break;
						case BEHIND_PLANE://面后
							numBehind++;
							break;
						case STRADDLING_PLANE://跨越面
							numStraddling++;
							break;
						default:
							break;
					}
				}
				//分割面的得分
				var score:Number = K * numStraddling + (1.0 - K) * Math.abs(numFront - numBehind);
				if(score < bestScore)
				{
					bestScore = score;
					bestPlane = plane;
				}	
			}
			return bestPlane;
		}
		
		private function classifyPolygonToPlane(poly:Triangle, plane:Plane):int
		{
			var a:Vector3D = poly.getA();
			var b:Vector3D = poly.getB();
			var c:Vector3D = poly.getC();
			var n:Vector3D = plane.getN();
			var d:Number = plane.getD();
			var numFront:Number = 0;
			var numBehind:Number = 0;
			
			var delta:Number = a.x * n.x + a.y * n.y + a.z * n.z;
			
			if(delta > d)
			{
				numFront++;
			}
			else if(delta < d)
			{
				numBehind++;
			}
			
			delta = b.x * n.x + b.y * n.y + b.z * n.z;
			if(delta > d)
			{
				numFront++;
			}
			else if(delta < d)
			{
				numBehind++;
			}
			
			delta = c.x * n.x + c.y * n.y + c.z * n.z;
			if(delta > d)
			{
				numFront++;
			}
			else if(delta < d)
			{
				numBehind++;
			}
			//如果点分别在两面，那么算是跨越面
			if(numFront > 0)
			{
				if(numBehind > 0)
				{
					return STRADDLING_PLANE;
				}
				else//只有正面有点
				{
					return IN_FRONT_OF_PLANE;
				}	
			}
			else if(numBehind > 0)//只要反面有点
			{
				return BEHIND_PLANE;
			}
			else//共面
			{
				return COPLANAR_WITH_PLANE;
			}
			
		}
		
		private function classifyPointToPlane(point:Vector3D, plane:Plane):int
		{
			var n:Vector3D = plane.getN();
			var d:Number = plane.getD();

			var delta:Number = point.x * n.x + point.y * n.y + point.z * n.z;
			
			if(delta > d)
			{
				return POINT_IN_FRONT_OF_PLANE;
			}
			else if(delta < d)
			{
				return POINT_BEHIND_PLANE;
			}
			else
			{
				return POINT_ON_PLANE;
			}
		}
		
		private function splitPolygon(poly:Triangle, splitPlane:Plane, frontPart:Triangle, backPart:Triangle):void
		{
			var a:Vector3D = poly.getA();
			var aSide:int = classifyPointToPlane(a, splitPlane);
			
			var b:Vector3D = poly.getB();
			var bSide:int = classifyPointToPlane(b, splitPlane);
			
			if(bSide == POINT_IN_FRONT_OF_PLANE)
			{
				if(aSide == POINT_BEHIND_PLANE)
				{
					
				}
			}
			else if(bSide == POINT_BEHIND_PLANE)
			{
				
			}
			
		}
		
		private function getPlaneFromPolygon(poly:Triangle):Plane
		{
			var a:Vector3D = poly.getA();
			var b:Vector3D = poly.getB();
			var c:Vector3D = poly.getC();
			var n:Vector3D = new Vector3D();
			n.x = (b.y - a.y) * (c.z - a.z) - (c.y - a.y) * (b.z - a.z);
			n.y = (c.x - a.x) * (b.z - a.z) - (b.x - a.x) * (c.z - a.z);
			n.z = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
			n.normalize();
			var d:Number = n.x + n.y + n.z; 
			return new Plane(n, d);
		}
		
		public function createWireFrame():void
		{
			getWireFrameRecur(root);
		}
		
		private function getWireFrameRecur(node:BSPNode):void
		{
/*			var count:int = 0;
			for(var i:int = 0; i < 8; i++)
			{
				if(node.children[i] == null)
				{
					count++;
				}
				else
				{
					getWireFrameRecur(node.children[i]);
				}
			}
			if(count == 8)
			{
				var aabb:BoundBox = node;
				var points:Vector.<Vector3D> = new Vector.<Vector3D>();
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
				
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
				
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
				
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.minZ));
				
				points.push(new Vector3D(aabb.minX, aabb.minY, aabb.maxZ));
				points.push(new Vector3D(aabb.maxX, aabb.minY, aabb.maxZ));
				
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.minZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.minZ));
				
				points.push(new Vector3D(aabb.minX, aabb.maxY, aabb.maxZ));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, aabb.maxZ));
				
				frames.push(WireFrame.createLinesList(points,0xff0000));
			}*/
			
		}
	}
}