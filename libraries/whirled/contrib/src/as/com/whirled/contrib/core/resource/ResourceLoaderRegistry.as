package com.whirled.contrib.core.resource {
    
import com.threerings.util.HashMap;
    
public class ResourceLoaderRegistry
{
    public static function get instance () :ResourceLoaderRegistry
    {
        return g_instance;
    }
    
    public function ResourceLoaderRegistry ()
    {
        if (null != g_instance) {
            throw new Error("ResourceLoaderRegistry singleton already instantiated");
        }
        
        g_instance = this;
    }
    
    public function registerLoaderClass (resourceType :String, loaderClass :Class) :void
    {
        _loaderClasses.put(resourceType, loaderClass);
    }
    
    public function createLoader (resourceType :String, resourceName :String, loadParams :*) :ResourceLoader
    {
        var loaderClass :Class = _loaderClasses.get(resourceType);
        if (null != loaderClass) {
            return (new loaderClass(resourceName, loadParams) as ResourceLoader);
        }

        return null;
    }
    
    protected var _loaderClasses :HashMap = new HashMap();
    protected static var g_instance :ResourceLoaderRegistry;

}

}