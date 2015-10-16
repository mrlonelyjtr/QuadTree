package collisionDetection.AABB
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.WireFrame;
	
	import collisionDetection.AABB.AABBNode;
	import collisionDetection.utils.CollTime;
	
	import flash.geom.Vector3D;

	public class AABBTree
	{
		//根结点
		private var root:AABBNode;
		private var mesh:Mesh;
		private var frames:Vector.<WireFrame> = new Vector.<WireFrame>();
		private const DEPTH:int = 4;
		
		public function getRoot():AABBNode
		{
			return root;
		}
		
		public function AABBTree()
		{
			
		}
		public function initAABBTree(mesh:Mesh):void
		{
			root = new AABBNode();
			this.mesh = mesh;
			root.maxX = mesh.boundBox.maxX;
			root.minX = mesh.boundBox.minX;
			root.maxY = mesh.boundBox.maxY;
			root.minY = mesh.boundBox.minY;
			root.maxZ = mesh.boundBox.maxZ;
			root.minZ = mesh.boundBox.minZ;
			//generateBVH();
			fastGenBVH();
		}
		
		
		
		public function boundBoxToWorld(b:BoundBox, x:Number, y:Number, z:Number):void
		{
			b.maxX += x;
			b.minX += x;
			b.maxY += y;
			b.minY += y;
			b.maxZ += z;
			b.minZ += z;
		}
		
		public function getFrames():Vector.<WireFrame>
		{
			return frames;
		}
		
		public function getMesh():Mesh
		{
			return mesh;
		}
		
		public function getBoundBox():BoundBox
		{
			return root;
		}
		
		public function collideWithAABB(b:Object3D, va:Vector3D, vb:Vector3D, time:CollTime):Boolean
		{
			
			return collideWithAABBRecur(root, b, va, vb, time);
		}
		//private function 
		
		private function collideWithAABBRecur(node:AABBNode, b:Object3D, va:Vector3D, vb:Vector3D, time:CollTime):Boolean
		{
			//如果节点有东西，碰撞检测
			var bnode:BoundBox = node.clone();
			var b1:BoundBox = b.boundBox.clone();
			//将包围盒转换到世界坐标
			boundBoxToWorld(bnode, mesh.x, mesh.y, mesh.z);
			boundBoxToWorld(b1, b.x, b.y, b.z);
			var aabb:AABB = new AABB();
			var newtime:CollTime = new CollTime();
			if(aabb.getMovingCollision(bnode,b1,va,vb,newtime))
			{
				//只取最早碰撞时间
				if((time.tfirst > 0 && newtime.tfirst < time.tfirst) || (time.tfirst == 0 && newtime.tfirst > 0))
				{
					time = newtime;
				}
				//return true;
				//碰撞了
				var count:int = 0;
				var childrenNum:int = 8;
				//进行子节点的碰撞检测
				for(var i:int = 0; i < 8; i++)
				{
					if(node.children[i] != null)
					{
						if(!collideWithAABBRecur(node.children[i],b, va, vb, time))
						{
							count++ ;
						}
					}
					else 
					{
						childrenNum--;
					}
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
		//两颗八叉树碰撞
		public function collideWithAABBTree(otherTree:AABBTree, va:Vector3D, vb:Vector3D, time:CollTime):Boolean
		{
/*			var bnode:BoundBox = root.clone();
			var bOtherTree:BoundBox = otherTree.mesh.boundBox.clone();
			boundBoxToWorld(bnode, mesh.x, mesh.y, mesh.z);
			boundBoxToWorld(bOtherTree, otherTree.mesh.x, otherTree.mesh.y, otherTree.mesh.z);
			var aabb:AABB = new AABB();
			return aabb.getMovingCollision(bnode,bOtherTree,va,vb,time)*/
			return collideWithAABBTreeRecur(root, otherTree, va, vb, time);
		}
		//private function 
		
		private function collideWithAABBTreeRecur(node:AABBNode, otherTree:AABBTree, va:Vector3D, vb:Vector3D, time:CollTime):Boolean
		{
			//如果节点有东西，碰撞检测
			var bnode:BoundBox = node.clone();
			var bOtherTree:BoundBox = otherTree.mesh.boundBox.clone();
			boundBoxToWorld(bnode, mesh.x, mesh.y, mesh.z);
			boundBoxToWorld(bOtherTree, otherTree.mesh.x, otherTree.mesh.y, otherTree.mesh.z);
			var aabb:AABB = new AABB();
			var newtime:CollTime = new CollTime();
			if(aabb.getMovingCollision(bnode,bOtherTree,va,vb,newtime))
			{
				//只取最早碰撞时间
				if((time.tfirst > 0 && newtime.tfirst < time.tfirst) || (time.tfirst == 0 && newtime.tfirst > 0))
				{
					time.tfirst = newtime.tfirst;
					time.tlast = newtime.tlast;
				}
				//return true;
				//碰撞了
				var notCollidedCnt:int = 0;
				var childrenNum:int = 8;
				//进行子节点的碰撞检测
				for(var i:int = 0; i < 8; i++)
				{
					if(node.children[i] != null)
					{
						if(!collideWithAABBTreeRecur(node.children[i],otherTree, va, vb, time))
						{
							notCollidedCnt++ ;
						}
					}
					else 
					{
						childrenNum--;//每有一个空子节点，就少了一个需要碰撞检测的子节点。
					}
				}
				
				if(notCollidedCnt == childrenNum && childrenNum != 0)//如果八个子节点都没碰到并且子节点不全为空
				{
					return false;//那就没碰到
				}
				else if(childrenNum == 0)
				{
					var objTemp:Object3D = mesh.clone();
					objTemp.boundBox = node;
					return otherTree.collideWithAABB(objTemp,vb,va,time);
					//如果子节点全为空，碰到当前节点。因为无法进一步迭代
					//return true;
				}
				else
				{
					return true;//碰到了个别子节点。
				}
				
			}
			else
			{
				return false;//如果没碰到，不用递归下去，直接返回“没碰到”到上一级。
			}
		}
		
		public function fastGenBVH():void{
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
			trace(this.mesh.name);
			for(var curFace:int = 0; curFace < faceNum; curFace++)
			{
				
				
				//取得三个顶点的坐标
				for(var i:int = 0; i < 3; i++)
				{
					p[i].x = points[3*indices[3*curFace+i]+0];
					p[i].y = points[3*indices[3*curFace+i]+1];
					p[i].z = points[3*indices[3*curFace+i]+2];
				}
				
				//计算代表点算法（效率太低）
				/*var repPt:Vector.<Vector3D> = calcRepresentPt(minGridLen,p[0],p[1],p[2]);
				
				for(var i:int = 0; i < repPt.length; i++)
				{
					
					//取得点在网格中的整数坐标
					var tempX:int = ( repPt[i].x - root.minX ) / gridXLen;
					var tempY:int = ( repPt[i].y - root.minY ) / gridYLen;
					var tempZ:int = ( repPt[i].z - root.minZ ) / gridZLen;
					
					tempX = (tempX == 1 << DEPTH) ? tempX -1 : tempX;
					tempY = (tempY == 1 << DEPTH) ? tempY -1 : tempY;
					tempZ = (tempZ == 1 << DEPTH) ? tempZ -1 : tempZ;
					
					//根据坐标得出莫顿码
					mcode[curPoint] = ( part1By2(tempZ) << 2 ) + ( part1By2(tempY) << 1 ) + part1By2(tempX);
					curPoint++;
					
				}
				*/
				
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
				
				
				//trace(maxX,minX,maxY,minY,maxZ,minZ);
				
				//包围盒的八个点
				var bp:Vector.<Vector3D> = new Vector.<Vector3D>();
				
				for(var k:int = minZ; k <= maxZ; k++)
				{
					for(var j:int = minY; j <= maxY; j++)
					{
						for(var i:int = minX; i <= maxX; i++)
						{
							//mcode[curPoint] = ( part1By2(k) << 2 ) + ( part1By2(j) << 1 ) + part1By2(i);
							//curPoint++;
							
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

							
							//计算当前离散坐标所代表的包围盒
/*							var min:Vector3D = new Vector3D(root.minX + i * gridXLen, root.minY + j * gridYLen, root.minZ + k * gridZLen);
							var max:Vector3D = new Vector3D(root.minX + (i + 1) * gridXLen, root.minY + (j + 1) * gridYLen, root.minZ + (k + 1) * gridZLen);

							bp[0] = new Vector3D(min.x, min.y, min.z);
							bp[1] = new Vector3D(min.x, min.y, max.z);
							bp[2] = new Vector3D(min.x, max.y, min.z);
							bp[3] = new Vector3D(min.x, max.y, max.z);
							bp[4] = new Vector3D(max.x, min.y, min.z);
							bp[5] = new Vector3D(max.x, min.y, max.z);
							bp[6] = new Vector3D(max.x, max.y, min.z);
							bp[7] = new Vector3D(max.x, max.y, max.z);
							
							//直线三点式行列式中的项
							// \ x-x1  y-y1  z-z1\
							// \ A21   A22   A23 \
							// \ A31   A32   A33 \
							var A21:Number = p[1].x - p[0].x;
							var A22:Number = p[1].y - p[0].y;
							var A23:Number = p[1].z - p[0].z;
							var A31:Number = p[2].x - p[0].x;
							var A32:Number = p[2].y - p[0].y;
							var A33:Number = p[2].z - p[0].z;
							
							var S1:Number = A22 * A33 - A23 * A32;
							var S2:Number = A23 * A31 - A21 * A33;
							var S3:Number = A21 * A32 - A31 * A22;
							
							//点落在三角形正面的次数
							var positiveCnt:int = 0;
							//点落在三角形内的次数
							var inCnt:int = 0;
							
							
							for(var n:int = 0; n < 8; n++)
							{
								var delta:Number = S1 * ( bp[n].x - p[0].x ) + 
													S2 * ( bp[n].y - p[0].y ) + 
													S3 * ( bp[n].z - p[0].z );
								if(delta >= 0)
								{
									positiveCnt++;
								}
							}
							
							if(positiveCnt > 0 && positiveCnt < 8)
							{
								for(var n:int = 0; n < 8; n++)
								{
									//if(isSameSide(p[0], p[1], p[2], bp[n]) && 
									//	isSameSide(p[1], p[2], p[0], bp[n]) && 
									//	isSameSide(p[2], p[0], p[1], bp[n]))
									//{
									//	inCnt++;
									//}
									
									//瓶颈
									if(inTriangle(p[0], p[1], p[2], bp[n]))
									{
										inCnt++;
									}
								}
								if(inCnt > 0)
								{
									mcode[curPoint] = ( part1By2(k) << 2 ) + ( part1By2(j) << 1 ) + part1By2(i);
									curPoint++;
								}
							}*/
							
						}
					}
				}
				/*p[3].x = ( p[0].x + p[1].x ) >> 1;
				p[3].y = ( p[0].y + p[1].y ) >> 1;
				p[3].z = ( p[0].z + p[1].z ) >> 1;
				
				p[4].x = ( p[2].x + p[1].x ) >> 1;
				p[4].y = ( p[2].y + p[1].y ) >> 1;
				p[4].z = ( p[2].z + p[1].z ) >> 1;
				
				p[5].x = ( p[0].x + p[2].x ) >> 1;
				p[5].y = ( p[0].y + p[2].y ) >> 1;
				p[5].z = ( p[0].z + p[2].z ) >> 1;
				
				p[6].x = ( p[0].x + p[1].x + p[2].x ) / 3;
				p[6].y = ( p[0].y + p[1].y + p[2].y ) / 3;
				p[6].z = ( p[0].z + p[1].z + p[2].z ) / 3;
				
				for(var i:int = 0; i < 7; i++)
				{
					//coordOfPoints[6 * curFace + i] = new Vector3D();
					//coordOfPoints[6 * curFace + i].x = ;
					//coordOfPoints[6 * curFace + i].y = ;
					//coordOfPoints[6 * curFace + i].z = ;
					
					//取得点在网格中的整数坐标
					var tempX:int = ( p[i].x - root.minX ) / gridXLen;
					var tempY:int = ( p[i].y - root.minY ) / gridYLen;
					var tempZ:int = ( p[i].z - root.minZ ) / gridZLen;
					
			    	tempX = (tempX == 1 << DEPTH) ? tempX -1 : tempX;
					tempY = (tempY == 1 << DEPTH) ? tempY -1 : tempY;
					tempZ = (tempZ == 1 << DEPTH) ? tempZ -1 : tempZ;
					
					//根据坐标得出莫顿码
					mcode[7 * curFace + i] = ( part1By2(tempZ) << 2 ) + ( part1By2(tempY) << 1 ) + part1By2(tempX);
					
				}*/
				
			}

			if(mcode.length == 0)
			{
				return;
			}
				
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
			
			//根据未排序的莫顿码建立八叉树
			//genBVHByMorton(mcode);
		    
		}
		
		private function testTriangleAABB(v0:Vector3D, v1:Vector3D, v2:Vector3D, b:BoundBox):Boolean
		{
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
		
		//二进制基数排序
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
				//trace("depth",depth);
				//当前深度的分割表
				var curSpltTbl:Vector.<int> = idxSpltTbls[depth - 1];
				var len:int = curSpltTbl.length;
				//获得当前morton在某深度的位置，即要生成的子节点编号
				var childIdx:int = locateMCode(depth,mcode[curSpltTbl[0]]);
				//trace(mcode[curSpltTbl[0]],childIdx);
				//要建立的子节点的父节点
				var father:AABBNode = root;
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
			trace(nodenum);
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
		private function createChild(node:AABBNode, childIdx:int):void
		{
			if(node.children[childIdx] == null)
			{
				node.children[childIdx] = new AABBNode();
				
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
		
		private function genBVHByMorton(mcode:Vector.<int>):void
		{
			genBVHNodeByMorton(root,mcode,1);
		}
		
		//依靠解析未排序的morton码来建立八叉树
		private function genBVHNodeByMorton(node:AABBNode, mcode:Vector.<int>, depth:int):void
		{
			if(depth > DEPTH)
			{
				return;
			}
			
			var mcodeOfChild:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			
			for(var i:int = 0; i < 8; i++)
			{
				mcodeOfChild[i] = new Vector.<int>();
			}
			
			for(var curFace:int = 0; curFace < mcode.length; curFace++)
			{
				//为获得某一深度的morton码而需要的掩码
				var curDepthMask:int = 7  <<  (DEPTH - depth) * 3;
				//某一深度的morton码
				var childIdx:int = (mcode[curFace] & curDepthMask) >> (DEPTH - depth) * 3;
				
				if(node.children[childIdx] == null)
				{
					node.children[childIdx] = new AABBNode();
					
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
				
				mcodeOfChild[childIdx].push(mcode[curFace]);
				
			}
			
			for(var i:int = 0; i < 8; i++)
			{
				if(node.children[i] != null)
				{
					genBVHNodeByMorton(node.children[i],mcodeOfChild[i],depth + 1);
				}
			}
		}
		
		private function isSameSide(A:Vector3D, B:Vector3D, C:Vector3D, P:Vector3D):Boolean
		{
			var AB:Vector3D = B.subtract(A);
			var AC:Vector3D = C.subtract(A);
			var AP:Vector3D = P.subtract(A);
			
			var v1:Vector3D = AB.crossProduct(AC);
			var v2:Vector3D = AB.crossProduct(AP);
			
			return ( v1.dotProduct(v2) >= 0 );
		}
		
		private function inTriangle(A:Vector3D, B:Vector3D, C:Vector3D, P:Vector3D):Boolean 
		{  	
			var v0:Vector3D = C.subtract(A);  	
			var v1:Vector3D = B.subtract(A);  
			var v2:Vector3D = P.subtract(A);  

			var dot00:Number = v0.dotProduct(v0) ;  
			var dot01:Number = v0.dotProduct(v1);  
			var dot02:Number = v0.dotProduct(v2);   
			var dot11:Number = v1.dotProduct(v1);  
			var dot12:Number = v1.dotProduct(v2);  
			
		    var inverDeno:Number = 1 / (dot00 * dot11 - dot01 * dot01);  
			var u:Number = (dot11 * dot02 - dot01 * dot12) * inverDeno; 
			
			if (u < 0 || u > 1) // if u out of range, return directly  
			{  
				return false ;  		
			}  
			
			var v:Number = (dot00 * dot12 - dot01 * dot02) * inverDeno;  
			if (v < 0 || v > 1) // if v out of range, return directly  	
			{  			
				return false ;  				
			}  		      			
			return u + v <= 1 ;  

		} 

		
		//计算三角形的代表点，保证这些点所在的包围盒就是三角形的包围盒
		private function calcRepresentPt(divUnit:Number, pointA:Vector3D, pointB:Vector3D, pointC:Vector3D):Vector.<Vector3D>
		{
			//三条边长
			var ABLen:Number = Vector3D.distance(pointA,pointB);
			var ACLen:Number = Vector3D.distance(pointA,pointC);
			var BCLen:Number = Vector3D.distance(pointB,pointC);
			//线段的条数，必须让最长边的每条子线段长度大于包围盒的最小边长
			var seg:int = Math.ceil( Math.max(ABLen, ACLen, BCLen) / divUnit );
			
			//AB，AC边上分割后的端点
			var arrayAB:Vector.<Vector3D> = new Vector.<Vector3D>();
			var arrayAC:Vector.<Vector3D> = new Vector.<Vector3D>();
			//所有的代表点
			var arrayResult:Vector.<Vector3D> = new Vector.<Vector3D>();
			var cnt0:int = 0;
			var cnt1:int = 0;
			var cnt2:int = 0;
			//如果三角形三个点的x坐标相同，那么就用y坐标作为自变量
			if(pointB.x - pointA.x != 0)
			{
				//AB边分割后每段在x轴方向上的长度
				var segXAB:Number = ( pointB.x - pointA.x ) / seg;
				var k:Number = ( pointB.y - pointA.y ) / ( pointB.x - pointA.x );
				for(var i:int = 0; i < seg + 1; i++)
				{
					//计算出那些点的坐标，放入向量
					var b:Vector3D = new Vector3D();
					b.x = pointA.x + segXAB * i;
					b.y = ( b.x - pointA.x ) * k + pointA.y;
					b.z = ( b.x - pointA.x ) * k + pointA.z;
					arrayAB.push(b);
					cnt0++;
				}
			}
			else if(pointB.y - pointA.y != 0)//把y坐标作为变化量
			{
				var segYAB:Number = ( pointB.y - pointA.y ) / seg;
				var k:Number = ( pointB.x - pointA.x ) / ( pointB.y - pointA.y );
				for(var i:int = 0; i < seg + 1; i++)
				{
					var b:Vector3D = new Vector3D();
					b.y = pointA.y + segYAB * i;
					b.x = ( b.y - pointA.y ) * k + pointA.x;
					b.z = ( b.y - pointA.y ) * k + pointA.z;
					arrayAB.push(b);
					cnt0++;
				}
			}
			else//把z作为变化量
			{
				var segZAB:Number = ( pointB.z - pointA.z ) / seg;
				var k:Number = ( pointB.x - pointA.x ) / ( pointB.z - pointA.z );
				for(var i:int = 0; i < seg + 1; i++)
				{
					var b:Vector3D = new Vector3D();
					b.z = pointA.z + segZAB * i;
					b.x = ( b.z - pointA.z ) * k + pointA.x;
					b.y = ( b.z - pointA.z ) * k + pointA.y;
					arrayAB.push(b);
					cnt0++;
				}
			}
			
			
			
			if(pointC.x - pointA.x != 0)
			{
				var segXAC:Number = ( pointC.x - pointA.x ) / seg;
				var k:Number = ( pointC.y - pointA.y ) / ( pointC.x - pointA.x );
				for(var i:int = 0; i < seg + 1; i++)
				{
					var c:Vector3D = new Vector3D();
					c.x = pointA.x + segXAC * i;
					c.y = ( c.x - pointA.x ) * k + pointA.y;
					c.z = ( c.x - pointA.x ) * k + pointA.z;
					arrayAC.push(c);
					cnt1++;
				}
			}
			else if(pointC.y - pointA.y != 0)//把y坐标作为变化量
			{
				var segYAC:Number = ( pointC.y - pointA.y ) / seg;
				var k:Number = ( pointC.x - pointA.x ) / ( pointC.y - pointA.y );
				for(var i:int = 0; i < seg + 1; i++)
				{
					var c:Vector3D = new Vector3D();
					c.y = pointA.y + segYAC * i;
					c.x = ( c.y - pointA.y ) * k + pointA.x;
					c.z = ( c.y - pointA.y ) * k + pointA.z;
					arrayAC.push(c);
					cnt1++;
				}
			}
			else//把z作为变化量
			{
				var segZAC:Number = ( pointC.z - pointA.z ) / seg;
				var k:Number = ( pointC.x - pointA.x ) / ( pointC.z - pointA.z );
				for(var i:int = 0; i < seg + 1; i++)
				{
					var b:Vector3D = new Vector3D();
					b.z = pointA.z + segZAC * i;
					b.x = ( b.z - pointA.z ) * k + pointA.x;
					b.y = ( b.z - pointA.z ) * k + pointA.y;
					arrayAC.push(b);
					cnt1++;
				}
			}

			
			
			if(pointB.x - pointC.x != 0)
			{
				var segXBC:Number = ( pointB.x - pointC.x ) / seg;
				var k:Number = ( pointB.y - pointC.y ) / ( pointB.x - pointC.x );
				for(var i:int = 0; i < seg + 1; i++)
				{
					for(var j:int = 0; j < i + 1; j++)
					{
						var p:Vector3D = new Vector3D();
						p.x = arrayAC[i].x + segXBC * j;
						p.y = ( p.x - arrayAC[i].x ) * k + arrayAC[i].y;
						p.z = ( p.x - arrayAC[i].x ) * k + arrayAC[i].z;
						arrayResult.push(p);
						cnt2++;
					}
				}
			}
			else if(pointB.y - pointC.y != 0)//把y坐标作为变化量
			{
				var segYBC:Number = ( pointB.y - pointC.y ) / seg;
				var k:Number = ( pointB.x - pointC.x ) / ( pointB.y - pointC.y );
				for(var i:int = 0; i < seg + 1; i++)
				{
					for(var j:int = 0; j < i + 1; j++)
					{
						var p:Vector3D = new Vector3D();
						p.y = arrayAC[i].y + segYBC * j;
						p.x = ( p.y - arrayAC[i].y ) * k + arrayAC[i].x;
						p.z = ( p.y - arrayAC[i].y ) * k + arrayAC[i].z;
						arrayResult.push(p);
						cnt2++;
					}
				}
			
			}
			else//把z作为变化量
			{
				var segZBC:Number = ( pointB.z - pointC.z ) / seg;
				var k:Number = ( pointB.x - pointC.x ) / ( pointB.z - pointC.z );
				for(var i:int = 0; i < seg + 1; i++)
				{
					for(var j:int = 0; j < i + 1; j++)
					{
						var p:Vector3D = new Vector3D();
						p.z = arrayAC[i].z + segZBC * j;
						p.x = ( p.z - arrayAC[i].z ) * k + arrayAC[i].x;
						p.y = ( p.z - arrayAC[i].z ) * k + arrayAC[i].y;
						arrayResult.push(p);
						cnt2++;
					}
				}
			}
			trace("count");
			trace(cnt0,cnt1,cnt2);
			
			return arrayResult;
		}
		
		private function part1By2(n:int):int
		{
			n = ( n ^ ( n << 16 ) ) & 0xff0000ff;
			n = ( n ^ ( n << 8 ) ) & 0x0300f00f;
			n = ( n ^ ( n << 4 ) ) & 0x030c30c3;
			n = ( n ^ ( n << 2 ) ) & 0x09249249;
			return n;
		}
		
		private function generateBVH():void{
		
			//取面
			var indexLen:int = mesh.geometry.indices.length;
			var faceIndx:Vector.<int> = new Vector.<int>();
			for(var i:int = 0; i < indexLen / 3; i++)
			{
				faceIndx[i] = i;
			}
			generateChildBVH(root, faceIndx, indexLen / 3, 1);

		}
		//生成bv树
		private function generateChildBVH(node:AABBNode, faceIndx:Vector.<int>, faceNum:int, depth:int):Boolean{
			
			if(faceNum == 0)
			{
				return false;
			}
			else
			{
				node.origBound.maxX = node.maxX;
				node.origBound.minX = node.minX;
				node.origBound.maxY = node.maxY;
				node.origBound.minY = node.minY;
				node.origBound.maxZ = node.maxZ;
				node.origBound.minZ = node.minZ;
			}
			
			if(depth < 4)//树的最大深度
			{
				//创建并初始化八个索引数组，存放每个子节点中面的编号列表
				var faceIndxes:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
				var faceNums:Vector.<int> = new Vector.<int>();
				
				for(var i:int = 0; i < 8; i++)
				{
					faceIndxes[i] = new Vector.<int>();
					faceNums[i] = 0;
				}
				
				
				initChildrenAABB(node);//初始化子节点AABB

				
				var curPt:Vector3D = new Vector3D();
				//获取点索引和顶点数据
				var indices:Vector.<uint> = mesh.geometry.indices;
				var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
				//计算中心
				var center:Vector3D = getAABBMidpoint(node);
				
				//将面分配到八个子节点中
				//测试面的顶点以及顶点之间的中点所属区间，并在对应子节点中添加该面
				for(var i:int = 0; i < faceNum; i++)
				{
					var curFace:int = faceIndx[i];
					//一个面的三个点
					for(var k:int = 0; k < 3; k++)
					{
						var curPtIdx:int = 3*indices[3*curFace+k];
						//当前的点
						curPt.x = points[curPtIdx];
						curPt.y = points[curPtIdx+1];
						curPt.z = points[curPtIdx+2];
						
						var ChildNum:int = getChildNumOfPoint(curPt, center);

						faceIndxes[ChildNum].push(faceIndx[i]);
						faceNums[ChildNum]++;
						
					}	
					
					var pt0:Vector3D = new Vector3D(
						points[3*indices[3*curFace+0]], 
						points[3*indices[3*curFace+0]+1], 
						points[3*indices[3*curFace+0]+2]
					);
					
					var pt1:Vector3D = new Vector3D(
						points[3*indices[3*curFace+0]], 
						points[3*indices[3*curFace+0]+1], 
						points[3*indices[3*curFace+0]+2]
					);
					
					var pt2:Vector3D = new Vector3D(
						points[3*indices[3*curFace+0]], 
						points[3*indices[3*curFace+0]+1], 
						points[3*indices[3*curFace+0]+2]
					);
					
					//三个中点
					curPt.x = ( pt0.x + pt1.x ) >> 1;
					curPt.y = ( pt0.y + pt1.y ) >> 1;
					curPt.z = ( pt0.z + pt1.z ) >> 1;	
					var ChildNum:int = getChildNumOfPoint(curPt, center);
					faceIndxes[ChildNum].push(faceIndx[i]);
					faceNums[ChildNum]++;
					
					curPt.x = ( pt2.x + pt1.x ) >> 1;
					curPt.y = ( pt2.y + pt1.y ) >> 1;
					curPt.z = ( pt2.z + pt1.z ) >> 1;	
					var ChildNum:int = getChildNumOfPoint(curPt, center);
					faceIndxes[ChildNum].push(faceIndx[i]);
					faceNums[ChildNum]++;
					
					curPt.x = ( pt0.x + pt2.x ) >> 1;
					curPt.y = ( pt0.y + pt2.y ) >> 1;
					curPt.z = ( pt0.z + pt2.z ) >> 1;	
					var ChildNum:int = getChildNumOfPoint(curPt, center);
					faceIndxes[ChildNum].push(faceIndx[i]);
					faceNums[ChildNum]++;
					
				}
				
				//for(var i:int = 0; i < faceNum; i++)
				//{
				//计算当前子空间面片表中第i个面的包围盒
				//var boundbox:BoundBox = generateFaceAABB(faceIndx[i]);
				//var boundbox:BoundBox = new BoundBox();
				//boundbox.maxX = node.maxX;
				//boundbox.minX = node.minX;
				//boundbox.maxY = node.maxY;
				//boundbox.minY = node.minY;
				//boundbox.maxZ = node.maxZ;
				//boundbox.minZ = node.minZ;
				
				//for(var j:int = 0; j < 8; j++)
				//{
				//if(getCollision(boundbox,node.children[j]))
				//{
				//faceIndxes[j].push(faceIndx[i]);
				//faceNums[j]++;
				//}
				//}
				//}

				//进入下一层递归
				for(var i:int = 0; i < 8; i++)
				{
					if(!generateChildBVH(node.children[i], faceIndxes[i], faceNums[i], depth + 1))
					{
						node.children[i] = null;
					}
				}
			}
			return true;
		}

		//计算AABB的中点
		private function getAABBMidpoint(boundbox:BoundBox):Vector3D
		{
			var center:Vector3D = new Vector3D();
			center.x = ( boundbox.maxX + boundbox.minX ) / 2;
			center.y = ( boundbox.maxY + boundbox.minY ) / 2;
			center.z = ( boundbox.maxZ + boundbox.minZ ) / 2;
			return center;
		}
		
		private function initChildrenAABB(node:AABBNode):void
		{
			for(var i:int = 0; i < 8; i++)
			{
				node.children[i] = new AABBNode();
				node.children[i].maxX = node.maxX;
				node.children[i].maxY = node.maxY;
				node.children[i].maxZ = node.maxZ;
				node.children[i].minX = node.minX;
				node.children[i].minY = node.minY;
				node.children[i].minZ = node.minZ;
			}
			
			//节点空间的中点
			var center:Vector3D = new Vector3D();
			
			center.x = ( node.maxX + node.minX ) / 2;
			center.y = ( node.maxY + node.minY ) / 2;
			center.z = ( node.maxZ + node.minZ ) / 2;
			
			//-+-
			node.children[0].maxX = center.x;
			node.children[0].minY = center.y;
			node.children[0].maxZ = center.z;
			//++-
			node.children[1].minX = center.x;
			node.children[1].minY = center.y;
			node.children[1].maxZ = center.z;
			//-++
			node.children[2].maxX = center.x;
			node.children[2].minY = center.y;
			node.children[2].minZ = center.z;
			//+++
			node.children[3].minX = center.x;
			node.children[3].minY = center.y;
			node.children[3].minZ = center.z;
			//---
			node.children[4].maxX = center.x;
			node.children[4].maxY = center.y;
			node.children[4].maxZ = center.z;
			//+--
			node.children[5].minX = center.x;
			node.children[5].maxY = center.y;
			node.children[5].maxZ = center.z;
			//--+
			node.children[6].maxX = center.x;
			node.children[6].maxY = center.y;
			node.children[6].minZ = center.z;
			//+-+
			node.children[7].minX = center.x;
			node.children[7].maxY = center.y;
			node.children[7].minZ = center.z;
			
			
		}
		
		//判断点的所属区间，分配到子节点中
		private function getChildNumOfPoint(curPt:Vector3D, center:Vector3D):int
		{
			
			var result:int = 0;
			if(curPt.x >= center.x)
			{
				result += 1;
			}
			if(curPt.y < center.y)
			{
				result += 4;
			}
			if(curPt.z >= center.z)
			{
				result += 2;
			}
			
			return result;
		}
		
		private function getCollision(a:BoundBox, b:BoundBox):Boolean{
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
		
		//计算面片包围盒
		//i:三角形编号
		//indices[3*i]:第i个三角形的第一个顶点
		//points[3*indices[3 * i]]:第i个三角形的第一个顶点的x坐标
		private function generateFaceAABB(i:int):BoundBox{
			
			//取点和索引
			var indices:Vector.<uint> = mesh.geometry.indices;
			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var maxX:Number;
			var minX:Number;
			var maxY:Number;
			var minY:Number;
			var maxZ:Number;
			var minZ:Number;
			
			//first vertex
			minX = maxX = points[3*indices[3*i]];
			minY = maxY = points[3*indices[3*i] + 1];
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
			if(points[3*indices[3*i + 2]] > maxX)
			{
				maxX = points[3*indices[3*i + 2]];
			}
			else if(points[3*indices[3*i + 2]] < minX)
			{
				minX = points[3*indices[3*i + 2]];
			}
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
			
			var boundbox:BoundBox = new BoundBox();
			boundbox.maxX = maxX;
			boundbox.minX = minX;
			boundbox.maxY = maxY;
			boundbox.minY = minY;
			boundbox.maxZ = maxZ;
			boundbox.minZ = minZ;
			
			return boundbox;
		}
		
		
		public function getPos():Vector3D
		{
			var pos:Vector3D = new Vector3D();
			pos.x = mesh.x;
			pos.y = mesh.y;
			pos.z = mesh.z;
			return pos;
		}
		

		public function rotateAABBTree(theta:Number, reviseX:Number, reviseY:Number):void
		{
			root.rotateAABBNode(theta, reviseX, reviseY);
		}
		
		public function createWireFrame():void
		{
			getWireFrameRecur(root);
		}
		
		private function getWireFrameRecur(node:AABBNode):void
		{
			var count:int = 0;
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
				aabb.maxX += mesh.x;
				aabb.maxY += mesh.y;
				aabb.maxZ += mesh.z;
				aabb.minX += mesh.x;
				aabb.minY += mesh.y;
				aabb.minZ += mesh.z;
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
			}
			
		}
		
		//生成节点的包围盒
		/*		private function generateBV(node:AABBNode, pts:Vector.<int>, ptNum:int):void{
		for(var i:int = 0; i < ptNum; i++)
		{
		var offseti:int = 3 * pts[i];
	
		if(points[offseti] > node.maxX)
		{
		node.maxX = points[offseti];
		}
		if(points[offseti] < node.minX)
		{
		node.minX = points[offseti];
		}
		
		if(points[offseti + 1] > node.maxY)
		{
		node.maxY = points[offseti + 1];
		}
		if(points[offseti + 1] < node.minY)
		{
		node.minY = points[offseti + 1];
		}
		
		if(points[offseti + 2] > node.maxZ)
		{
		node.maxZ = points[offseti + 2];
		}
		if(points[offseti + 2] < node.minZ)
		{
		node.minZ = points[offseti + 2];
		}
		}
		
		}*/	
		
		
	}
}

