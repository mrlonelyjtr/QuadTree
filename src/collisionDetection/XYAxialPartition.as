package collisionDetection
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.WireFrame;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class XYAxialPartition
	{
		private var XAxialPartitions:Vector.<Vector.<Boolean>>;
		private var YAxialPartitions:Vector.<Vector.<Boolean>>;
		private var axesOfX:Vector.<Number>;
		private var axesOfY:Vector.<Number>;
		private var axesOfZ:Vector.<Number>;
		
		public function XYAxialPartition(mesh:Mesh)
		{
			//变量初始化
			XAxialPartitions = new Vector.<Vector.<Boolean>>();
			YAxialPartitions = new Vector.<Vector.<Boolean>>();
			
			axesOfX = new Vector.<Number>();
			axesOfY = new Vector.<Number>();
			axesOfZ = new Vector.<Number>();
			//取点
			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			//投影到平面上的点二维坐标
			var pointsInXZ:Vector.<Point> = new Vector.<Point>();
			var pointsInYZ:Vector.<Point> = new Vector.<Point>();
			for(var i:int = 0; i < points.length; i += 3)
			{
				pointsInXZ.push(new Point(points[i], points[i + 2]));
				pointsInYZ.push(new Point(points[i + 1], points[i + 2]));
			}
			//在xz面计算横向划分线
			pointsSort(pointsInXZ, false);
			
			divide(pointsInXZ, mesh.boundBox.maxX - mesh.boundBox.minX, mesh.boundBox.maxZ - mesh.boundBox.minZ, false, axesOfZ);
			//在yz面计算横向划分线
			//pointsSort(pointsInYZ, false);
			
			//divide(pointsInYZ, mesh.boundBox.maxY - mesh.boundBox.minY, mesh.boundBox.maxZ - mesh.boundBox.minZ, false, axesOfZ);
			//在xz面计算纵向划分线
			pointsSort(pointsInXZ, true);
			
			divide(pointsInXZ,mesh.boundBox.maxX - mesh.boundBox.minX, mesh.boundBox.maxZ - mesh.boundBox.minZ, true, axesOfX);
			//在yz面计算纵向划分线
			pointsSort(pointsInYZ, true);
			
			divide(pointsInYZ,mesh.boundBox.maxY - mesh.boundBox.minY, mesh.boundBox.maxZ - mesh.boundBox.minZ, true, axesOfY);
			
			for(var i:int = 0; i < axesOfX.length - 1; i ++)
			{
				XAxialPartitions[i] = new Vector.<Boolean>();
				for(var j:int = 0; j < axesOfZ.length - 1; j ++)
				{
					XAxialPartitions[i][j] = false;
				}
			}
			
			for(var i:int = 0; i < axesOfY.length - 1; i ++)
			{
				YAxialPartitions[i] = new Vector.<Boolean>();
				for(var j:int = 0; j < axesOfZ.length - 1; j ++)
				{
					YAxialPartitions[i][j] = false;
				}
			}
			
			var indices:Vector.<uint> = mesh.geometry.indices;
			
			fill(points,indices);
		}
		
		private function pointsSort(points:Vector.<Point>, xisIndex:Boolean):void
		{
			if(xisIndex)
			{
				for(var i:int = 1; i < points.length; i ++)
				{
					var key:Point = points[i];
					for(var j:int = i; j > 0 && key.x < points[j - 1].x; j --)
					{
						points[j] = points[j - 1];
					}
					points[j] = key;
				}
			}
			else
			{
				for(var i:int = 1; i < points.length; i ++)
				{
					var key:Point = points[i];
					for(var j:int = i; j > 0 && key.y < points[j - 1].y; j --)
					{
						points[j] = points[j - 1];
					}
					points[j] = key;
				}
			}
		}
		
/*		private function numberSort(vec:Vector.<Number>):void
		{
			for(var i:int = 1; i < vec.length; i ++)
			{
				var key:Number = vec[i];
				for(var j:int = i; j > 0; j --)
				{
					if(key.y < vec[j - 1])
					{
						vec[j] = vec[j - 1];
					}
					else if(key.y < vec[j - 1])
					{
						
					}
					vec.re
				}
				vec[j] = key;
			}
		}*/
		
		private function divide(points:Vector.<Point>, lenX:Number, lenY:Number, xIsAxis:Boolean, axisContainer:Vector.<Number>):void
		{
			var curCount:int;
			var lastCount:int;
			var diffOfCount:int;

			var unit:Number = (lenX + lenY) / 50;
			
			var cur:Number;//当前轴
			var last:Number;
			var lastMax:Number = 0;
			var lastMin:Number = 0;
			var curMax:Number = 0;
			var curMin:Number = 0;
			var axialcor:Number;//轴向坐标
			var nonaxialcor:Number;//非轴向坐标
			//第一条轴是最左点的非轴向坐标
			//
			if(xIsAxis)
			{
				cur = points[0].x;
				curMax = curMin = points[0].y;
			}
			else
			{
				cur = points[0].y;
				curMax = curMin = points[0].x;
			}
			lastCount = curCount = 1;
			last = cur;
			for(var i:int = 1; i < points.length; i ++)
			{
				if(xIsAxis)
				{
					axialcor = points[i].x;
					nonaxialcor = points[i].y;
				}
				else
				{
					axialcor = points[i].y;
					nonaxialcor = points[i].x;
				}
				if((axialcor - cur) > unit)
				{
					//如果突变，增加一条线
					if(curCount >= lastCount)
					{
						diffOfCount = curCount - lastCount;
					}
					else
					{
						diffOfCount = lastCount - curCount;
					}
					
					if((Number)((lastCount + curCount) / diffOfCount) < 15)
					{
						axisContainer.push(cur);	
					}
					else if((curMax - lastMax) > 4*unit || (curMin - lastMin) > 4*unit)
					{
						axisContainer.push(last);
					}
					last = cur;
					cur = axialcor;
					lastMax = curMax;
					lastMin = curMin;
					lastCount = curCount;
					curCount = 1;
					curMax = curMin = nonaxialcor;
				}
				else
				{
					curCount++;
					if(nonaxialcor > curMax)
						curMax = nonaxialcor;
					if(nonaxialcor < curMin)
						curMin = nonaxialcor;
					
				}
			}	
			if((curMax - lastMax) > 4*unit || (curMin - lastMin) > 4*unit || curCount != lastCount)
			{
				if(axisContainer[axisContainer.length - 1] != last)
				{
					axisContainer.push(last);
				}	
				axisContainer.push(cur);
			}
		}
		
		private function fill(points:Vector.<Number>, indices:Vector.<uint>):void
		{
			var maxX:Number;
			var minX:Number;
			var maxZ:Number;
			var minZ:Number;
			var minXAxis:int;
			var maxXAxis:int;
			var minZAxis:int;
			var maxZAxis:int;
			//i:三角形编号
			//indices[3*i]:第i个三角形的第一个顶点
			//points[3*indices[i]]:第i个三角形的第一个顶点的x坐标
			for(var i:int = 0; i < indices.length / 3; i += 3)
			{
				//first vertex
				minX = maxX = points[3*indices[3*i]];
				minZ = maxZ = points[3*indices[3*i] + 2];
				
				//second vertex
				if(points[3*indices[3*i + 1]] > maxX)
				{
					maxX = points[3*indices[3*i + 1]];
				}
				else if(points[3*indices[3*i + 1]] < minX)
				{
					minX = points[3*indices[3*i + 1]];
				}
				if(points[3*indices[3*i + 1] + 2] > maxZ)
				{
					maxZ = points[3*indices[3*i + 1] + 2];
				}
				else if(points[3*indices[3*i + 1] + 2] < minZ)
				{
					minZ = points[3*indices[3*i + 1] + 2];
				}
				
				//third vertex
				if(points[3*indices[3*i + 2]] > maxX)
				{
					maxX = points[3*indices[3*i + 2]];
				}
				else if(points[3*indices[3*i + 2]] < minX)
				{
					minX = points[3*indices[3*i + 2]];
				}
				if(points[3*indices[3*i + 2] + 2] > maxZ)
				{
					maxZ = points[3*indices[3*i + 2] + 2];
				}
				else if(points[3*indices[3*i + 2] + 2] < minZ)
				{
					minZ = points[3*indices[3*i + 2] + 2];
				}	
				
				var j:int;
				
				for( j = 0; j < axesOfX.length - 1; j++)
				{
					if(minX >= axesOfX[j])
					{
					    minXAxis = j;
					}
				}
				for(j = minXAxis; j < axesOfX.length; j++)
				{
					if(maxX <= axesOfX[j])
					{
						maxXAxis = j;
						break;
					}
				}
				
				for( j = 0; j < axesOfZ.length - 1; j++)
				{
					if(minZ >= axesOfZ[j])
					{
						minZAxis = j;
					}
				}
				for(j = minZAxis; j < axesOfZ.length; j++)
				{
					if(maxZ <= axesOfZ[j])
					{
						maxZAxis = j;
						break;
					}
				}
				
				//fill
				for(j = minXAxis; j < maxXAxis; j++)
				{
					for(var k:int = minZAxis; k < maxZAxis; k++)
					{
						XAxialPartitions[j][k] = true;
					}
				}
				
			}
			
			var maxY:Number;
			var minY:Number;
			var maxZ:Number;
			var minZ:Number;
			var minYAxis:int;
			var maxYAxis:int;
			var minZAxis:int;
			var maxZAxis:int;
			//i:三角形编号
			//indices[3*i]:第i个三角形的第一个顶点
			//points[3*indices[i]]:第i个三角形的第一个顶点的x坐标
			for(var i:int = 0; i < indices.length / 3; i += 3)
			{
				//first vertex
				minY = maxY = points[3*indices[3*i] + 1];
				minZ = maxZ = points[3*indices[3*i] + 2];
				
				//second vertex
				if(points[3*indices[3*i + 1] + 1] > maxY)
				{
					maxY = points[3*indices[3*i + 1] + 1];
				}
				else if(points[3*indices[3*i + 1] + 1] < minY)
				{
					minY = points[3*indices[3*i + 1] + 1];
				}
				if(points[3*indices[3*i + 1] + 2] > maxZ)
				{
					maxZ = points[3*indices[3*i + 1] + 2];
				}
				else if(points[3*indices[3*i + 1] + 2] < minZ)
				{
					minZ = points[3*indices[3*i + 1] + 2];
				}
				
				//third vertex
				if(points[3*indices[3*i + 2] + 1] > maxY)
				{
					maxY = points[3*indices[3*i + 2] + 1];
				}
				else if(points[3*indices[3*i + 2] + 1] < minY)
				{
					minY = points[3*indices[3*i + 2] + 1];
				}
				if(points[3*indices[3*i + 2] + 2] > maxZ)
				{
					maxZ = points[3*indices[3*i + 2] + 2];
				}
				else if(points[3*indices[3*i + 2] + 2] < minZ)
				{
					minZ = points[3*indices[3*i + 2] + 2];
				}	
				
				var j:int;
				
				for( j = 0; j < axesOfY.length - 1; j++)
				{
					if(minY >= axesOfY[j])
					{
						minYAxis = j;
					}
				}
				for(j = minYAxis; j < axesOfY.length; j++)
				{
					if(maxY <= axesOfY[j])
					{
						maxYAxis = j;
						break;
					}
				}
				
				for( j = 0; j < axesOfZ.length - 1; j++)
				{
					if(minZ >= axesOfZ[j])
					{
						minZAxis = j;
					}
				}
				for(j = minZAxis; j < axesOfZ.length; j++)
				{
					if(maxZ <= axesOfZ[j])
					{
						maxZAxis = j;
						break;
					}
				}
				
				//fill
				for(j = minYAxis; j < maxYAxis; j++)
				{
					for(var k:int = minZAxis; k < maxZAxis; k++)
					{
						YAxialPartitions[j][k] = true;
					}
				}
				
			}
		}
		
		public function getDivisionFrame(o:Object3D):WireFrame{
			var a:BoundBox = o.boundBox;
			var aabb:BoundBox = new BoundBox();
			aabb.maxX = a.maxX - o.x;
			aabb.maxY = a.maxY - o.y;
			aabb.maxZ = a.maxZ - o.z;
			aabb.minX = a.minX - o.x;
			aabb.minY = a.minY - o.y;
			aabb.minZ = a.minZ - o.z;
			var points:Vector.<Vector3D> = new Vector.<Vector3D>();
			for(var i:int = 0; i < axesOfZ.length; i ++)
			{
				points.push(new Vector3D(aabb.minX, aabb.minY, axesOfZ[i]));
				points.push(new Vector3D(aabb.minX, aabb.maxY, axesOfZ[i]));
				
				points.push(new Vector3D(aabb.maxX, aabb.minY, axesOfZ[i]));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, axesOfZ[i]));
				
				points.push(new Vector3D(aabb.minX, aabb.minY, axesOfZ[i]));
				points.push(new Vector3D(aabb.maxX, aabb.minY, axesOfZ[i]));
				
				points.push(new Vector3D(aabb.minX, aabb.maxY, axesOfZ[i]));
				points.push(new Vector3D(aabb.maxX, aabb.maxY, axesOfZ[i]));
			}
			for(var i:int = 0; i < axesOfX.length; i ++)
			{
			points.push(new Vector3D(axesOfX[i], aabb.minY, aabb.minZ));
			points.push(new Vector3D(axesOfX[i], aabb.minY, aabb.maxZ));

			}
			for(var i:int = 0; i < axesOfY.length; i ++)
			{
				points.push(new Vector3D(aabb.maxX, axesOfY[i], aabb.minZ));
				points.push(new Vector3D(aabb.maxX, axesOfY[i], aabb.maxZ));
				
			}
			return WireFrame.createLinesList(points,0xff0000);
		}
		
	}
}