package com.whirled.contrib.core.resource {
    
import com.threerings.util.Assert;

import flash.display.BitmapData;
    
public class SwfResourceFactory
    implements ResourceFactory
{
    public function SwfResourceFactory ()
    {
    }
    
    public function createResourceLoader (resourceName :String, loadParams :*) :ResourceLoader
    {
        return new SwfResourceLoader(resourceName, loadParams);
    }
}

}
