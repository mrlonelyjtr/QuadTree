package advancedCollisionDetection
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.physicsengine.math.Matrix4;
	
	import flash.geom.Vector3D;

	public class OBB
	{
		private static const epsilon:Number = 0.000000119209290;
		private var center:Vector3D ;
		private var extents:Vector3D;
		private var axisX:Vector3D;
		private var axisY:Vector3D;
		private var axisZ:Vector3D;
		private var mesh:Mesh;
		private var worldOBB:BoundBox = new BoundBox();
		
		public function OBB(mesh:Mesh){
			this.mesh = mesh;
		}
		
		public function initOBB():void{
			var obb:BoundBox = mesh.boundBox;	
			
			center = new Vector3D((obb.maxX + obb.minX) / 2, (obb.maxY + obb.minY) / 2, (obb.maxZ + obb.minZ) / 2);
			extents = new Vector3D((obb.maxX - obb.minX) / 2, (obb.maxY - obb.minY) / 2, (obb.maxZ - obb.minZ) / 2);
			axisX = new Vector3D(1, 0, 0);
			axisY = new Vector3D(0, 1, 0);
			axisZ = new Vector3D(0, 0, 1);
			
			var maxOBB:Vector3D = new Vector3D(center.x + axisX.x * extents.x, 
				center.y + axisY.y * extents.y, center.z + axisZ.z * extents.z);
			var minOBB:Vector3D = new Vector3D(center.x - axisX.x * extents.x, 
				center.y - axisY.y * extents.y, center.z - axisZ.z * extents.z);
			
			obb.maxX = maxOBB.x;
			obb.maxY = maxOBB.y;
			obb.maxZ = maxOBB.z;
			obb.minX = minOBB.x;
			obb.minY = minOBB.y;
			obb.minZ = minOBB.z;
			
//		 	obbToWorld(mesh);
			
//			var points:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
//			var transform:Matrix4 = getOBBOrientation(points);
//			
//			transform.createMatrix3D().transpose();
//			
//			var v:Vector3D = new Vector3D(points[0], points[1], points[2]);
//			
//			var vecMax:Vector3D = new Vector3D(transform.m00 * v.x + transform.m01 * v.y + transform.m02 * v.z,
//				transform.m10 * v.x + transform.m11 * v.y + transform.m12 * v.z,
//				transform.m20 * v.x + transform.m21 * v.y + transform.m22 * v.z);  
//			var vecMin:Vector3D = vecMax.clone();
//			
//			for (var i:int = 3; i < points.length / 3; i += 3){  
//				var vec:Vector3D = new Vector3D(points[i], points[i + 1], points[i + 2]);
//				var vect:Vector3D = new Vector3D(transform.m00 * vec.x + transform.m01 * vec.y + transform.m02 * vec.z,
//					transform.m10 * vec.x + transform.m11 * vec.y + transform.m12 * vec.z,
//					transform.m20 * vec.x + transform.m21 * vec.y + transform.m22 * vec.z);  
//				
//				vecMax.x = Math.max(vecMax.x, vect.x);  
//				vecMax.y = Math.max(vecMax.y, vect.y);  
//				vecMax.z = Math.max(vecMax.z, vect.z);  
//				
//				vecMin.x = Math.min(vecMin.x, vect.x);  
//				vecMin.y = Math.min(vecMin.y, vect.y); 
//				vecMin.z = Math.min(vecMin.z, vect.z);  
//			}  
//			
//			transform.createMatrix3D().transpose(); 
//			
//			axisX = new Vector3D(transform.m00, transform.m01, transform.m02);
//			axisY = new Vector3D(transform.m10, transform.m11, transform.m12);
//			axisZ = new Vector3D(transform.m20, transform.m21, transform.m22);
//			
//			center = new Vector3D((vecMax.x + vecMin.x) / 2, (vecMax.y + vecMin.y) / 2, (vecMax.z + vecMin.z) / 2); 
//			extents = new Vector3D((vecMax.x - vecMin.x) / 2, (vecMax.y - vecMin.y) / 2, (vecMax.z - vecMin.z) / 2);
//			
//			center = new Vector3D(center.x * transform.m00 + center.y * transform.m10 + center.z * transform.m20,
//				center.x * transform.m01 + center.y * transform.m11 + center.z * transform.m21,
//				center.x * transform.m02 + center.y * transform.m12 + center.z * transform.m22);
//			
//			axisX.normalize();
//			axisY.normalize();
//			axisZ.normalize();
//			
//			
//			var maxOBB:Vector3D = new Vector3D(center.x + axisX.x * extents.x, 
//				center.y + axisY.y * extents.y, center.z + axisZ.z * extents.z);
//			var minOBB:Vector3D = new Vector3D(center.x - axisX.x * extents.x, 
//				center.y - axisY.y * extents.y, center.z - axisZ.z * extents.z);
//			
//			mesh.boundBox.maxX = maxOBB.x;
//			mesh.boundBox.minX = minOBB.x;
//			mesh.boundBox.maxY = maxOBB.y;
//			mesh.boundBox.minY = minOBB.y;
//			mesh.boundBox.maxZ = maxOBB.z;
//			mesh.boundBox.minZ = minOBB.z;
		}
		
		private function obbToWorld(mesh:Mesh):void{
			var obb:BoundBox = mesh.boundBox;	

			center = new Vector3D((obb.maxX + obb.minX) / 2, (obb.maxY + obb.minY) / 2, (obb.maxZ + obb.minZ) / 2);
			extents = new Vector3D((obb.maxX - obb.minX) / 2, (obb.maxY - obb.minY) / 2, (obb.maxZ - obb.minZ) / 2);
			axisX = new Vector3D(1, 0, 0);
			axisY = new Vector3D(0, 1, 0);
			axisZ = new Vector3D(0, 0, 1);
			
			var maxOBB:Vector3D = new Vector3D(center.x + axisX.x * extents.x, 
									center.y + axisY.y * extents.y, center.z + axisZ.z * extents.z);
			var minOBB:Vector3D = new Vector3D(center.x - axisX.x * extents.x, 
									center.y - axisY.y * extents.y, center.z - axisZ.z * extents.z);
			
			worldOBB.maxX = maxOBB.x + mesh.x;         
			worldOBB.minX = minOBB.x + mesh.x;
			worldOBB.maxY = maxOBB.y + mesh.y;
			worldOBB.minY = minOBB.y + mesh.y;
			worldOBB.maxZ = maxOBB.z + mesh.z;
			worldOBB.minZ = minOBB.z + mesh.z;
		}
		
		private function getOBBOrientation(points:Vector.<Number>):Matrix4{
			var cov:Matrix4 = getConvarianceMatrix(points);
			var evecs:Matrix4 = new Matrix4();
			var evals:Vector3D = new Vector3D();
			
			evecs = getEigenVectors(evecs, evals, cov);
			
			evecs.createMatrix3D().transpose();
			
			return evecs;
		}
		
		private function getConvarianceMatrix(points:Vector.<Number>):Matrix4{
			var cov:Matrix4 = new Matrix4();
			var count:Number = points.length / 3;  
			
			var s1:Array = new Array(0.0, 0.0, 0.0);  
			var s2:Array = new Array(new Array(0.0, 0.0, 0.0), new Array(0.0, 0.0, 0.0), new Array(0.0, 0.0, 0.0)); 
			
			for (var i:int = 0; i < points.length; i += 3){
				s1[0] += points[i];  
				s1[1] += points[i + 1];  
				s1[2] += points[i + 2];  
				
				s2[0][0] += points[i] * points[i];  
				s2[1][1] += points[i + 1] * points[i + 1];  
				s2[2][2] += points[i + 2] * points[i + 2];  
				s2[0][1] += points[i] * points[i + 1];  
				s2[0][2] += points[i] * points[i + 2];  
				s2[1][2] += points[i + 1] * points[i + 2];  
			}
			
			cov.m00 = (s2[0][0] - s1[0] * s1[0] / count) / count;  
			cov.m11 = (s2[1][1] - s1[1] * s1[1] / count) / count;  
			cov.m22 = (s2[2][2] - s1[2] * s1[2] / count) / count;  
			cov.m10 = (s2[0][1] - s1[0] * s1[1] / count) / count;  
			cov.m21 = (s2[1][2] - s1[1] * s1[2] / count) / count;  
			cov.m20 = (s2[0][2] - s1[0] * s1[2] / count) / count;  
			cov.m01 = cov.m10;  
			cov.m02 = cov.m21;  
			cov.m12 = cov.m20;  
			
			return cov;
		}
		
		private function getEigenVectors(evecs:Matrix4, evals:Vector3D, cov:Matrix4):Matrix4{
			var n:int = 3; 
			var nrot:int = 0;
			var v:Matrix4 = new Matrix4();  
			var b:Vector3D = new Vector3D();
			var z:Vector3D = new Vector3D();
			var d:Vector3D = new Vector3D(); 
			
			v.createMatrix3D().identity();
			 
			for(var ip:int = 0; ip < n; ip++){ 
				setElement(b, ip, getValue(ip + 4 * ip, cov)); 
				setElement(d, ip, getValue(ip + 4 * ip, cov));
				setElement(z, ip, 0.0);				
			}
			
			for(var i:int = 0; i < 50; i++) {  
				var sm:Number = 0.0;  
				for(var ip:int = 0; ip < n; ip++){
					for(var iq:int = ip+1; iq < n; iq++) 
						sm += Math.abs(getValue(ip + 4 * iq, cov));  
				}
				
				if(Math.abs((sm)) < epsilon) {  
					v.createMatrix3D().transpose();  
					evecs = v;  
					evals = d; 
					
					return evecs;  
				}  
				
				var tresh:Number = 0.0;
				if (i < 3)  
					tresh = 0.2 * sm / (n * n);   
				
				for(var ip:int = 0; ip < n; ip++){  
					for(var iq:int = ip + 1; iq < n; iq++)  {  
						var g:Number = 100.0 * Math.abs(getValue(ip + 4 * iq, cov));  
						var dmip:Number = getElement(d, ip);  
						var dmiq:Number = getElement(d, iq);  

						if(i > 3 && (Math.abs(dmip) + g == Math.abs(dmip)) && (Math.abs(dmiq) + g == Math.abs(dmiq)))
							setValue(ip + 4 * iq, cov, 0.0);
						else if (Math.abs(getValue(ip + 4 * iq, cov)) > tresh){  
							var h:Number = dmiq - dmip;  
							var t:Number;
							
							if (Math.abs(h) + g == Math.abs(h))  
								t = getValue(ip + 4 * iq, cov) / h;  
							else{  
								var theta:Number = 0.5 * h / getValue(ip + 4 * iq, cov);  
								t = 1.0 / (Math.abs(theta) + Math.sqrt(1.0 + theta * theta));  
								
								if (theta < 0.0) 
									t = -t;  
							}  
							
							var c:Number = 1.0 / Math.abs(1 + t * t);  
							var s:Number = t * c;  
							var tau:Number = s / (1.0 + c);  
							h = t * getValue(ip + 4 * iq, cov);  
							
							setElement(z, ip, getElement(z, ip) - h);  
							setElement(z, iq, getElement(z, iq) + h);  
							setElement(d, ip, getElement(d, ip) - h);  
							setElement(d, iq, getElement(d, iq) + h);
							
							setValue(ip + 4 * iq, cov, 0.0);  
							
							for(var j:int = 0; j < ip; j++)
								rotate(cov, j, ip, j, iq, s, tau); 
							
							for(var j:int = ip + 1; j < iq; j++)
								rotate(cov, ip, j, j, iq, s, tau);
							
							for(var j:int = iq + 1; j < n; j++)
								rotate(cov, ip, j, iq, j, s, tau);
							
							for(var j:int = 0; j < n; j++)
								rotate(cov, j, ip, j, iq, s, tau);
							
							nrot++;  
						}
					}  
				}  
				
				for(ip = 0; ip < n; ip++){  
					setElement(b, ip, getElement(b, ip) + getElement(z, ip));  
					setElement(d, ip, getElement(b, ip));  
					setElement(z, ip, 0.0);  
				}  
			}  
			
			v.createMatrix3D().transpose();  
			evecs = v;  
			evals = d;

			return evecs; 
		}
		
		private function rotate(cov:Matrix4, i:Number, j:Number, k:Number, l:Number, s:Number, tau:Number):void{
			var g:Number = getValue(i + 4 * j, cov);
			var h:Number = getValue(k + 4 * l, cov); 
			setValue(i + 4 * j, cov, g - s * (h + g * tau)); 	
			setValue(k + 4 * l, cov, h + s * (g - h * tau)); 
		}
		
		private function setElement(vec:Vector3D, index:int, value:Number):Number{
			if (index == 0)
				return vec.x = value;
			else if (index == 1)
				return vec.y = value;
			else (index == 2)
				return vec.x = value;
		}
		
		private function getElement(vec:Vector3D, index:int):Number{
			if (index == 0)
				return vec.x;
			else if (index == 1)
				return vec.y;
			else (index == 2)
			return vec.x;
		}
		
		private function getValue(index:int, cov:Matrix4):Number{
			if (index == 0)
				return cov.m00;
			else if (index == 1)
				return cov.m01;
			else if (index == 2)
				return cov.m02;
			else if (index == 4)
				return cov.m10;
			else if (index == 5)
				return cov.m11;
			else if (index == 6)
				return cov.m12;
			else if (index == 8)
				return cov.m20;
			else if (index == 9)
				return cov.m21;
			else (index == 10)
				return cov.m22;
		}
		
		private function setValue(index:int, cov:Matrix4, value:Number):Number{
			if (index == 0)
				return cov.m00 = value;
			else if (index == 1)
				return cov.m01 = value;
			else if (index == 2)
				return cov.m02 = value;
			else if (index == 4)
				return cov.m10 = value;
			else if (index == 5)
				return cov.m11 = value;
			else if (index == 6)
				return cov.m12 = value;
			else if (index == 8)
				return cov.m20 = value;
			else if (index == 9)
				return cov.m21 = value;
			else (index == 10)
				return cov.m22 = value;
		}
		
	}
}