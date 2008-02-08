package com.whirled.contrib.core.resource {
    
import com.threerings.util.Assert;
import com.threerings.util.HashMap;
    
public class ResourceFactoryRegistry
{
    public static function get instance () :ResourceFactoryRegistry
    {
        if (null == g_instance) {
            new ResourceManager();
        }
        
        return g_instance;
    }
    
    public function ResourceFactoryRegistry ()
    {
        if (null != g_instance) {
            throw new Error("ResourceFactoryMap singleton already instantiated");
        }
        
        g_instance = this;
    }
    
    public function registerFactory (resourceType :String, factory :ResourceFactory) :void
    {
        _resourceFactories.put(resourceType, factory);
    }
    
    public function getFactory (resourceType :String) :ResourceFactory
    {
        return _resourceFactories.get(resourceType);
    }
    
    protected var _resourceFactories :HashMap = new HashMap();
    protected static var g_instance :ResourceFactoryRegistry;

}

}