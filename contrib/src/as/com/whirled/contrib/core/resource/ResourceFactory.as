package com.whirled.contrib.core.resource {
    
import flash.utils.ByteArray;
    
public interface ResourceFactory
{
    function createResourceLoader (resourceName :String, loadParams :*) :ResourceLoader
}

}