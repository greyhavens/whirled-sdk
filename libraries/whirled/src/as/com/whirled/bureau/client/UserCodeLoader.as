package com.whirled.bureau.client {

/** Interface to allow agents to load and unload the code that they're running. */
public interface UserCodeLoader
{
    /** 
     * Load the code media (abc file) from the given url, find the given class name inside it and 
     * invoke the callback when the code is ready. The callback must take a single argument of type 
     * <code>Class</code>:
     * 
     * <p><code>
     * function callback (clazz :Class) :void
     * </code></p>
     *
     * <p>If the class could not be loaded, the callback will be invoked with null.</p>
     * 
     * <p>Successful calls to <code>load</code> must be paired with a corresponding 
     * <code>unload</code> call.</p>
     */
    function load (url :String, name :String, callback :Function) :void;

    /**
     * Unload the given class. The instance must have been provided by the <code>load</code> 
     * function. Once the unmber of loaded instances goes to zero, the domain is fair game
     * to be destroyed.
     */
    function unload (clazz :Class) :void;
}

}
