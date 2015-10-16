package advancedCollisionDetection
{	
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	
	import flash.geom.Vector3D;

	public class Octree
	{
		private var mesh:Mesh;
		private var root:OctreeNode;
		private const DEPTH:int = 3;
		
		private var collisionDetection3D:CollisionDetectionIn3D = new CollisionDetectionIn3D();
		
		public function Octree(mesh:Mesh){
			this.mesh = mesh;
		}
		
		public function initOctree():void{
			root = new OctreeNode();
			
			root.maxX = mesh.boundBox.maxX;
			root.minX = mesh.boundBox.minX;
			root.maxY = mesh.boundBox.maxY;
			root.minY = mesh.boundBox.minY;
			root.maxZ = mesh.boundBox.maxZ;
			root.minZ = mesh.boundBox.minZ;
			
			fastGenBVH();
		}
		
		public function fastGenBVH():void
		{
			//网格（八叉树最底层节点）的长宽高
			var gridXLen:Number = ( root.maxX - root.minX ) / (1 << DEPTH);
			var gridYLen:Number = ( root.maxY - root.minY ) / (1 << DEPTH);
			var gridZLen:Number = ( root.maxZ - root.minZ ) / (1 << DEPTH);
			var minGridLen:Number = Math.min(gridXLen, gridYLen, gridZLen);
			
			//顶点的莫顿码
			var mcode:Vector.<int> = new Vector.<int>();
			
			//模型的面数
			var faceNum:int = mesh.geometry.indices.length / 3;
			
			var p:Vector.<Vector3D> = new Vector.<Vector3D>();
			
			for(var i:int = 0; i < 7; i++)
			{
				p[i] = new Vector3D();                                                            
			}
			
			var curPoint:int = 0;
			
			//获取点索引和顶点数据
			var indices:Vector.<uint> = mesh.geometry.indices;
			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			
			for(var curFace:int = 0; curFace < faceNum; curFace++)
			{	
				//取得三个顶点的坐标
				for(var i:int = 0; i < 3; i++)
				{
					p[i].x = points[3*indices[3*curFace+i]+0];
					p[i].y = points[3*indices[3*curFace+i]+1];
					p[i].z = points[3*indices[3*curFace+i]+2];
				}
				
				//算出三角形的最大和最小坐标
				var maxX:int = ( Math.max(p[0].x, p[1].x, p[2].x) - root.minX ) / gridXLen;
				var minX:int = ( Math.min(p[0].x, p[1].x, p[2].x) - root.minX ) / gridXLen;
				var maxY:int = ( Math.max(p[0].y, p[1].y, p[2].y) - root.minY ) / gridYLen;
				var minY:int = ( Math.min(p[0].y, p[1].y, p[2].y) - root.minY ) / gridYLen;
				var maxZ:int = ( Math.max(p[0].z, p[1].z, p[2].z) - root.minZ ) / gridZLen;
				var minZ:int = ( Math.min(p[0].z, p[1].z, p[2].z) - root.minZ ) / gridZLen;
				
				maxX = (maxX == 1 << DEPTH) ? (maxX - 1) : maxX;
				minX = (minX == 1 << DEPTH) ? (minX - 1) : minX;
				maxY = (maxY == 1 << DEPTH) ? (maxY - 1) : maxY;
				minY = (minY == 1 << DEPTH) ? (minY - 1) : minY;
				maxZ = (maxZ == 1 << DEPTH) ? (maxZ - 1) : maxZ;
				minZ = (minZ == 1 << DEPTH) ? (minZ - 1) : minZ;
								
				//包围盒的八个点
				var bp:Vector.<Vector3D> = new Vector.<Vector3D>();
				
				for(var k:int = minZ; k <= maxZ; k++)
				{
					for(var j:int = minY; j <= maxY; j++)
					{
						for(var i:int = minX; i <= maxX; i++)
						{							
							var b:BoundBox = new BoundBox();
							b.maxX = root.minX + (i + 1) * gridXLen;
							b.maxY = root.minY + (j + 1) * gridYLen;
							b.maxZ = root.minZ + (k + 1) * gridZLen;
							b.minX = root.minX + i * gridXLen;
							b.minY = root.minY + j * gridYLen;
							b.minZ = root.minZ + k * gridZLen;
							
							if(testTriangleAABB(p[0],p[1],p[2],b))
							{
								mcode[curPoint] = ( part1By2(k) << 2 ) + ( part1By2(j) << 1 ) + part1By2(i);
								curPoint++;
							}							
						}
					}
				}				
			}
			
			if(mcode.length == 0)
				return;
			
			//基数排序
			radixSort2(mcode, DEPTH * 3); 
			
			//建立分割信息表
			var idxSpltTbl:Vector.<int> = new Vector.<int>();
			var dpthSpltTbl:Vector.<int> = new Vector.<int>();
			
			var prev:int = 0;
			var next:int = 0;
			var curPrevCode:int = 0;
			var curNextCode:int = 0;
			
			for(var i:int = 0; i < mcode.length - 1; i++)
			{
				prev = mcode[i];
				next = mcode[i + 1];
				
				for(var j:int = 1; j <= DEPTH; j++)
				{
					//为获得某一深度的morton码而需要的掩码
					var curDepthMask:int = 7 << ( DEPTH - j ) * 3;
					//某一深度的morton码
					curPrevCode = prev & curDepthMask;
					curNextCode = next & curDepthMask;
					if(curPrevCode != curNextCode)
					{
						for(var k:int = j; k <= DEPTH; k++)
						{
							idxSpltTbl.push(i);
							dpthSpltTbl.push(k);
						}
						break;
					}
				}
				
			}
			
			//重新对分割信息表排序
			var idxSpltTbls:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			
			for(var i:int = 0; i < DEPTH; i++)
			{
				idxSpltTbls[i] = new Vector.<int>();
			}
			
			for(var i:int = 0; i < idxSpltTbl.length; i++)
			{
				idxSpltTbls[dpthSpltTbl[i] - 1].push(idxSpltTbl[i]);
			}
			
			//根据分割表建立八叉树
			genBVHBySpltTbl(mcode,idxSpltTbls);
		}
		
		private function testTriangleAABB(v0:Vector3D, v1:Vector3D, v2:Vector3D, b:BoundBox):Boolean{
			var p0:Number = 0;
			var p1:Number = 0;
			var p2:Number = 0;
			var r:Number = 0;
			
			//计算包围盒中心和半径
			var c:Vector3D = new Vector3D( (b.minX + b.maxX) * 0.5, (b.minY + b.maxY) * 0.5, (b.minZ + b.maxZ) * 0.5 );
			var e0:Number = (b.maxX - b.minX) * 0.5;
			var e1:Number = (b.maxY - b.minY) * 0.5;
			var e2:Number = (b.maxZ - b.minZ) * 0.5;
			
			//相当于把AABB移到原点
			v0 = v0.subtract(c);
			v1 = v1.subtract(c);
			v2 = v2.subtract(c);
			
			var f0:Vector3D = v1.subtract(v0);
			var f1:Vector3D = v2.subtract(v1);
			var f2:Vector3D = v0.subtract(v2);
			
			//a00
			p0 = v0.z * v1.y - v0.y * v1.z;
			p2 = v2.z * (v1.y - v0.y) - v2.z * (v1.z - v0.z);
			r = e1 * Math.abs(f0.z) + e2 * Math.abs(f0.y);
			if(Math.max(-Math.max(p0,p2), Math.min(p0,p2)) > r)
			{
				return false;
			}
			//a01
			p1 = v1.z * v2.y - v1.y * v2.z;
			p0 = v0.z * (v2.y - v1.y) - v0.y * (v2.z - v1.z);
			r = e1 * Math.abs(f1.z) + e2 * Math.abs(f1.y);
			if(Math.max(-Math.max(p0,p1), Math.min(p0,p1)) > r)
			{
				return false;
			}
			//a02
			p0 = v0.y * v2.z - v0.z * v2.y;
			p1 = v1.z * (v0.y - v2.y) - v1.y * (v0.z - v2.z);
			r = e1 * Math.abs(f2.z) + e2 * Math.abs(f2.y);
			if(Math.max(-Math.max(p0,p1), Math.min(p0,p1)) > r)
			{
				return false;
			}
			
			//a10
			p0 = v0.x * v1.z - v0.z * v1.x;
			p2 = v2.x * (v1.z - v0.z) - v2.z * (v1.x - v0.x);
			r = e0 * Math.abs(f0.z) + e2 * Math.abs(f0.x);
			if(Math.max(-Math.max(p0,p2), Math.min(p0,p2)) > r)
			{
				return false;
			}
			//a11
			p1 = v1.x * v2.z - v1.z * v2.x;
			p0 = v0.x * (v2.z - v1.z) - v0.z * (v2.x - v1.x);
			r = e0 * Math.abs(f1.z) + e2 * Math.abs(f1.x);
			if(Math.max(-Math.max(p0,p1), Math.min(p0,p1)) > r)
			{
				return false;
			}
			//a12
			p0 = v0.z * v2.x - v0.x * v2.z;
			p1 = v1.x * (v0.z - v2.z) - v1.z * (v0.x - v2.x);
			r = e0 * Math.abs(f2.z) + e2 * Math.abs(f2.x);
			if(Math.max(-Math.max(p0,p1), Math.min(p0,p1)) > r)
			{
				return false;
			}
			
			//a20
			p0 = v0.y * v1.x - v0.x * v1.y;
			p2 = v2.y * (v1.x - v0.x) - v2.x * (v1.y - v0.y);
			r = e0 * Math.abs(f0.y) + e1 * Math.abs(f0.x);
			if(Math.max(-Math.max(p0,p2), Math.min(p0,p2)) > r)
			{
				return false;
			}
			//a21
			p1 = v1.y * v2.x - v1.x * v2.y;
			p0 = v0.y * (v2.x - v1.x) - v0.x * (v2.y - v1.y);
			r = e0 * Math.abs(f1.y) + e1 * Math.abs(f1.x);
			if(Math.max(-Math.max(p0,p1), Math.min(p0,p1)) > r)
			{
				return false;
			}
			//a22
			p0 = v0.x * v2.y - v0.y * v2.x;
			p1 = v1.y * (v0.x - v2.x) - v1.x * (v0.y - v2.y);
			r = e0 * Math.abs(f2.y) + e1 * Math.abs(f2.x);
			if(Math.max(-Math.max(p0,p1), Math.min(p0,p1)) > r)
			{
				return false;
			}
			
			if(Math.max(v0.x, v1.x, v2.x) < -e0 || Math.min(v0.x, v1.x, v2.x) > e0)
			{
				return false;
			}
			
			if(Math.max(v0.y, v1.y, v2.y) < -e1 || Math.min(v0.y, v1.y, v2.y) > e1)
			{
				return false;
			}
			
			if(Math.max(v0.z, v1.z, v2.z) < -e2 || Math.min(v0.z, v1.z, v2.z) > e2)
			{
				return false;
			}
			
			var n:Vector3D = f0.crossProduct(f1);
			v0 = v0.add(c);
			var d:Number = n.dotProduct(v0);
			
			var e:Vector3D = new Vector3D(b.maxX - c.x, b.maxY - c.y, b.maxZ - c.z);
			var r:Number = e0 * Math.abs(n.x) + e1 * Math.abs(n.y) + e2 * Math.abs(n.z);
			var s:Number = n.dotProduct(c) - d;
			
			return Math.abs(s) <= r;
		}
		
		private function part1By2(n:int):int
		{
			n = ( n ^ ( n << 16 ) ) & 0xff0000ff;
			n = ( n ^ ( n << 8 ) ) & 0x0300f00f;
			n = ( n ^ ( n << 4 ) ) & 0x030c30c3;
			n = ( n ^ ( n << 2 ) ) & 0x09249249;
			return n;
		}
		
		private function radixSort2(array:Vector.<int>, digitNum:int):void
		{
			var bucket0:Vector.<int> = new Vector.<int>();
			var bucket1:Vector.<int> = new Vector.<int>();
			
			for(var i:int = 0; i < digitNum; i++)
			{
				for(var i:int = 0; i < array.length; i++)
				{
					//取得莫顿码的第i位
					if(array[i] & ( 1 << i) )
					{
						bucket1.push(array[i]);
					}
					else
					{
						bucket0.push(array[i]);
					}
				}
				
				for(var a:int = 0; a < bucket0.length; a++)
				{
					array[a] = bucket0[a];
				}
				
				for(var b:int = 0; b < bucket1.length; b++)
				{
					array[b + bucket0.length] = bucket1[b];
				}
				
				bucket1 = new Vector.<int>();
				bucket0 = new Vector.<int>();
				
			}
		}
		
		private function genBVHBySpltTbl(mcode:Vector.<int>, idxSpltTbls:Vector.<Vector.<int>>):void
		{
			//从最小深度开始进行
			var nodenum:uint = 0;
			for(var depth:int = 1; depth <= DEPTH; depth++)
			{
				//当前深度的分割表
				var curSpltTbl:Vector.<int> = idxSpltTbls[depth - 1];
				var len:int = curSpltTbl.length;
				//获得当前morton在某深度的位置，即要生成的子节点编号
				var childIdx:int = locateMCode(depth,mcode[curSpltTbl[0]]);
				
				//要建立的子节点的父节点
				var father:OctreeNode = root;
				//迭代地找到父节点
				for(var j:int = 1; j < depth; j++)
				{
					father = father.children[locateMCode(j,mcode[curSpltTbl[0]])];			
				}
				//在父节点下建立相应的子节点
				createChild(father,childIdx);
				nodenum++;
				
				
				for(var i:int = 0; i < len; i++)
				{
					childIdx = locateMCode(depth,mcode[curSpltTbl[i] + 1]);
					//trace(mcode[curSpltTbl[i] + 1],childIdx);
					father = root;
					
					for(var j:int = 1; j < depth; j++)
					{
						father = father.children[locateMCode(j,mcode[curSpltTbl[i] + 1])];			
					}
					
					createChild(father,childIdx);
					nodenum++;
				}
			}
		}
		
		//获得morton码在某一深度的值（节点编号）
		private function locateMCode(depth:int, mcode:int):int
		{
			//为获得某一深度的morton码而需要的掩码
			var curDepthMask:int = 7  <<  (DEPTH - depth) * 3;
			//某一深度的morton码
			var childIdx:int = (mcode & curDepthMask) >> (DEPTH - depth) * 3;
			
			return childIdx;
		}
		
		//创建指定节点的第n个孩子
		private function createChild(node:OctreeNode, childIdx:int):void
		{
			if(node.children[childIdx] == null)
			{
				node.children[childIdx] = new OctreeNode();
				
				//子节点的编号按照morton码，
				// \2\3\
				// \0\1\
				if(childIdx & 1)
				{
					node.children[childIdx].maxX = node.maxX;
					node.children[childIdx].minX = ( node.maxX + node.minX ) >> 1;
				}
				else
				{
					node.children[childIdx].maxX = ( node.maxX + node.minX ) >> 1;
					node.children[childIdx].minX = node.minX;
				}
				
				if(childIdx & 2)
				{
					node.children[childIdx].maxY = node.maxY;
					node.children[childIdx].minY = ( node.maxY + node.minY ) >> 1;
				}
				else
				{
					node.children[childIdx].maxY = ( node.maxY + node.minY ) >> 1;
					node.children[childIdx].minY = node.minY;
				}
				
				if(childIdx & 4)
				{
					node.children[childIdx].maxZ = node.maxZ;
					node.children[childIdx].minZ = ( node.maxZ + node.minZ ) >> 1;
				}
				else
				{
					node.children[childIdx].maxZ = ( node.maxZ + node.minZ ) >> 1;
					node.children[childIdx].minZ = node.minZ;
				}
				
			}
		}
		
		public function boundBoxToWorld(b:BoundBox, x:Number, y:Number, z:Number):void{
			b.maxX += x;
			b.minX += x;
			b.maxY += y;
			b.minY += y;
			b.maxZ += z;
			b.minZ += z;
		}
		
		public function collideDetectionWithTree(otherTree:Octree):Boolean{
			return collideDetectionWithTreeRecur(root, otherTree);
		}
		
		private function collideDetectionWithTreeRecur(node:OctreeNode, otherTree:Octree):Boolean{
			//如果节点有东西，碰撞检测
			var bnode:BoundBox = node.clone();
			var bOtherTree:BoundBox = otherTree.mesh.boundBox.clone();
			
			boundBoxToWorld(bnode, mesh.x, mesh.y, mesh.z);
			boundBoxToWorld(bOtherTree, otherTree.mesh.x, otherTree.mesh.y, otherTree.mesh.z);
			
			if(collisionDetection3D.collideDetection(bnode, bOtherTree)){
				var notCollidedCnt:int = 0;
				var childrenNum:int = 8;
				//进行子节点的碰撞检测
				for(var i:int = 0; i < 8; i++){
					if(node.children[i] != null){
						if(!collideDetectionWithTreeRecur(node.children[i], otherTree))
							notCollidedCnt++ ;
					}
					else 
						childrenNum--;//每有一个空子节点，就少了一个需要碰撞检测的子节点。
				}
				
				if(notCollidedCnt == childrenNum && childrenNum != 0)//如果八个子节点都没碰到并且子节点不全为空
				{
					return false;//那就没碰到
				}
				else if(childrenNum == 0)
				{
					var objTemp:Object3D = mesh.clone();
					objTemp.boundBox = node;
					return otherTree.collideWithOBB(objTemp);
				}
				else
				{
					return true;//碰到了个别子节点。
				}
				
			}
			
			return false;//如果没碰到，不用递归下去，直接返回“没碰到”到上一级。
		}
		
		public function collideWithOBB(b:Object3D):Boolean{
			return collideWithOBBRecur(root, b);
		}
		
		private function collideWithOBBRecur(node:OctreeNode, b:Object3D):Boolean
		{
			//如果节点有东西，碰撞检测
			var bnode:BoundBox = node.clone();
			var b1:BoundBox = b.boundBox.clone();
			//将包围盒转换到世界坐标
			boundBoxToWorld(bnode, mesh.x, mesh.y, mesh.z);
			boundBoxToWorld(b1, b.x, b.y, b.z);

			if(collisionDetection3D.collideDetection(bnode,b1))
			{
				var count:int = 0;
				var childrenNum:int = 8;
				//进行子节点的碰撞检测
				for(var i:int = 0; i < 8; i++){
					if(node.children[i] != null){
						if(!collideWithOBBRecur(node.children[i], b))
							count++ ;
					}
					else 
						childrenNum--;
				}
				
				if(count == childrenNum && childrenNum != 0)//如果八个子节点都没碰到
				{
					return false;//那就没碰到
				}
				else
				{
					return true;//只要碰到一个就算碰到
				}
			}
			else
			{
				return false;//如果没碰到，不用递归下去，直接返回“没碰到”到上一级。
			}
		}
		
		
	}
}