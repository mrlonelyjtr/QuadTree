package advancedCollisionDetection
{
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	
	public class QuadTree
	{
		private var MAX_OBJECTS:int = 5;
		private var MAX_LEVELS:int = 4;
		
		private var level:int;
		private var objects:Array;
		private var bounds:Rectangle;
		private var nodes:Vector.<QuadTree>;
		
		public function QuadTree(level:int, bounds:Rectangle){
			this.level = level;
			this.bounds = bounds;
			objects = [];
			nodes = new Vector.<QuadTree>(4);
		}
		
		public function split():void{
			var subWidth:int = bounds.width/2;
			var subHeight:int = bounds.height/2;
			var x:int = bounds.x;
			var y:int = bounds.y;
			
			nodes[0] = new QuadTree(level + 1, new Rectangle(x, y + subHeight, subWidth, subHeight));
			nodes[1] = new QuadTree(level + 1, new Rectangle(x + subWidth, y + subHeight, subWidth, subHeight));
			nodes[2] = new QuadTree(level + 1, new Rectangle(x, y, subWidth, subHeight));
			nodes[3] = new QuadTree(level + 1, new Rectangle(x + subWidth, y, subWidth, subHeight));
		}
		
		private function getIndex(object:Object):Array{
			var index:Array = [];

			var rectangle:Rectangle = new Rectangle(object.x, object.y, object.width, object.height);
			
			var midX:Number = bounds.x + bounds.width/2;
			var midY:Number = bounds.y + bounds.height/2;
			
			var isBottom:Boolean = rectangle.y + rectangle.height <= midY;
			var isTop:Boolean = rectangle.y >= midY;
			var isLeft:Boolean = rectangle.x + rectangle.width <= midX;
			var isRight:Boolean = rectangle.x >= midX;
			
			if (isTop){
				if (isLeft)
					index = new Array(1, 0, 0, 0);
				
				else if (isRight)
					index = new Array(0, 1, 0, 0);
				
				else if (!isLeft && !isRight)
					index = new Array(1, 1, 0, 0);
			}
			else if (isBottom){
				if (isLeft)
					index = new Array(0, 0, 1, 0);
				
				else if (isRight)
					index = new Array(0, 0, 0, 1);
				
				else if (!isLeft && !isRight)
					index = new Array(0, 0, 1, 1);
			}
			else if (!isTop && !isBottom){
				if (isLeft)
					index = new Array(1, 0, 1, 0);
				
				else if (isRight)
					index = new Array(0, 1, 0, 1);
				
				else if (!isLeft && !isRight)
					index = index = new Array(1, 1, 1, 1);
			}
			
			return index;
		}
		
		
		
		public function insert(object:Object):void{		
			if (nodes[0] != null){
				var index:Array = getIndex(object);
				
				for (var i:int = 0; i < index.length; i++){
					if (index[i] != 0)
						nodes[i].insert(object);
				}	
				
				return;
			}
			
			objects.push(object);
			
			if (objects.length > MAX_OBJECTS && level < MAX_LEVELS){
				if (nodes[0] == null){
					split();	
				
					var i:int=0;
					while(i < objects.length){
						index = getIndex(objects[i]);
						
						for (var j:int = 0; j < index.length; j++){
							if (index[j] != 0)
								nodes[j].insert(objects.splice(i, 1)[0]);
						}	
						
						i++;
					}
				}
			}
		}
		
		public function retrive(returnObjects:Array, object:Object):void{
			var index:Array = getIndex(object);

			if (nodes[0] != null){
				for (var j:int = 0; j < index.length; j++){
					if (index[j] != 0)
						nodes[j].retrive(returnObjects, object);
				}	
			}
			
			for (var i:int = 0; i < objects.length; i++)
				returnObjects.push(objects[i]);
		}
		
		public function clear():void{
			objects = [];
			
			for (var i:int = 0; i < nodes.length; i++){
				if (nodes[i] != null) {
					nodes[i].clear();
					nodes[i] = null;
				}
			}
		}
		
	}
}