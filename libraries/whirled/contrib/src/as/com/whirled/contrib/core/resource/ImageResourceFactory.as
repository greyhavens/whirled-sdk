package com.whirled.contrib.core.resource {
    
import com.threerings.util.Assert;

import flash.display.BitmapData;
    
public class ImageResourceFactory
    implements ResourceFactory
{
    public function ImageResourceFactory ()
    {
    }
    
    public function createResourceLoader (resourceName :String, loadParams :*) :ResourceLoader
    {
        return new ImageResourceLoader(resourceName, loadParams);
    }
}

}
