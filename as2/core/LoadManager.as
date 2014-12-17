import mx.utils.Delegate;
class as2.core.LoadManager{
	static private var queue_list:Array = new Array();
	function LoadManager(){
		
	}
	public static function load(object:Object){
		if(!object.target) return;
		if(!object.file) return;
		if(is_unique(object.target) && !object.queued){
			object.loader = setLoader(object);
			queue_list.unshift(object);
		}
		if(!object.isLoading)object.loader.loadClip(object.file, object.target);
		object.isLoading = true;
		return object.loader;
	}
	public static function unload(target){
		var i = queue_list.length;
		while(i-- > 0){
			if(queue_list[i].target == target){
				queue_list[i].loader.unloadClip(queue_list[i].target);
				queue_list.splice(i, 1);
			}
		}
		clean();
		load_next();
	}
	public static function queue(object:Object){
		clean();
		if(!object.target) return;
		if(!object.file) return;
		object.queued = true;
		object.loader = setLoader(object);
		queue_list.push(object);
		load_next();
		return object.loader;
	}
	public static function set unqueue(target:MovieClip){
		unload(target);
	}
	public static function set priority(target:MovieClip){
		clean();
		if(queue_list[0].target == target){
			load_next();
			return;
		}
		for(var i = 0; i < queue_list.length; i++){
			if(queue_list[i].target == target){
				queue_list.unshift(queue_list.splice(i,1)[0]);
				load_next();
				return;
			}else if(queue_list[i].queued){
				//queue_list[i].loader.unloadClip(queue_list[i].target);
			}
		}
	}

	private static function setLoader(object){
		object.$onComplete = function(){
			this.onComplete.apply(this.target, arguments);
			LoadManager.remove(this.target);
		}
		object.$onError = function(){
			this.onError.apply(this.target, arguments);
			LoadManager.remove(this.target);
		}
		var mcLoader:MovieClipLoader = new MovieClipLoader();
		var load_listener:Object = new Object();
		load_listener.onLoadComplete = Delegate.create(object, object.$onComplete);
		load_listener.onLoadError = Delegate.create(object, object.$onError);
		load_listener.onLoadInit = Delegate.create(object.target, object.onInit);
		load_listener.onLoadProgress = Delegate.create(object.target, object.onProgress);
		load_listener.onLoadStart = Delegate.create(object.target, object.onStart);
		mcLoader.addListener(load_listener);
		return mcLoader;
	}
	private static function load_next(){
		clean();
		for(var i = 0; i < queue_list.length; i++){
			if(queue_list[i].queued){
				load(queue_list[i]);
				return;
			}
		}
	}
	private static function is_unique(target:MovieClip):Boolean{
		for(var i = 0; i < queue_list.length; i++){
			if(queue_list[i].target == target) return false;
		}
		return true;
	}
	private static function remove(target:MovieClip){
		var i = queue_list.length;
		while(i-- > 0){
			if(queue_list[i].target == target){
				queue_list.splice(i, 1);
			}
		}
		load_next();
	}
	private static function clean(){
		var i = queue_list.length;
		while(i-- > 0){
			if(isNaN(queue_list[i].target.getDepth())){
				queue_list.splice(i, 1);
			}
		}
	}
}