//
// $Id$

package com.whirled.util {
    
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.errors.IllegalOperationError;

/**
 * <b>Note</b>: This class is deprecated. It will be removed or replaced soon.<br></br>
 *
 * Wrapper class that wraps a content pack's Loader instance with some useful accessors.
 *
 * <p><b>Note:</b> in order to access the data while running on the test server, you'll need to
 * add pack information to your config.xml - for each content pack's mediaURL entry, use
 * "http://127.0.0.1:8080/" as the server, followed by the path to your content pack.
 * See the Wiki for more info.</p>
 */
public class ContentPack
{
    /**
     * The constructor takes a Loader object to wrap; it can be accessed by calling getLoader().
     */
    public function ContentPack (loader :Loader)
    {
        _loader = loader;
    }

    /**
     * Get the wrapped Loader object.
     */
    public function getLoader () :Loader
    {
        return _loader;
    }

    /**
     * Get the top-level display object defined in the content pack SWF.
     */
    public function getContent () :DisplayObject
    {
        return _loader.content;
    }

    /**
     * Retrieves a class definition from the loaded SWF.
     *
     * @throws IllegalOperationError if the class does not exist.
     */
    public function getClass (className :String) :Class
    {
        return getSymbol(className) as Class;
    }

    /**
     * Retrieves a function definition from the loaded SWF.
     *
     * @throws IllegalOperationError if the function does not exist.
     */
    public function getFunction (functionName :String) :Function
    {
        return getSymbol(functionName) as Function;
    }

    /**
     * Retrieves a symbol definition from the loaded swf.
     *
     * @throws IllegalOperationError if the symbol definition does not exist.
     */
    public function getSymbol (symbolName :String) :Object
    {
        try {
            return _loader.contentLoaderInfo.applicationDomain.getDefinition(symbolName);
        } catch (e: Error) {
            throw new IllegalOperationError(symbolName + " definition not found");
        }
        return null;
    }

    /** Wrapped pack loader. */
    protected var _loader :Loader;
}
}
