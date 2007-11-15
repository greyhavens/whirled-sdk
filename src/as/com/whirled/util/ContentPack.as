//
// $Id$

package com.whirled.util {
    
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.errors.IllegalOperationError;

/**
 * Wrapper class that wraps a content pack's Loader instance with some useful accessors.
 *
 * <p><b>Note:</b> in order to access any of the data stored in the content pack, the SWF file
 * will need to explicitly grant access to its data. This is commonly done by calling
 * the function: <pre>flash.system.Security.allowDomain()</pre>
 *
 * <p>For example, you can include the following class in your SWF file, attached to some symbol:
 * <pre>
 * package {
 * import flash.system.Security;
 * 
 * public class GrantAccess extends MovieClip {
 *   public function GrantAccess () {
 *     Security.allowDomain("*");
 *     super();
 *   }
 *   private static var singleton :GrantAccess = new GrantAccess();
 * }
 * }
 * </pre>
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
