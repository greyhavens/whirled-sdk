package com.whirled.bureau.client {

/** Represents user code loaded from an external server. Provided by an implementation of 
 *  {@link UserCodeLoader}. */
public interface UserCode
{
    /** Create a new instance of the user's main object. The instance is of the class whose name 
     *  was provided to {@link UserCodeLoader#load}. */
    function createNewInstance () :Object;

    /** Releases this code. Once released, <code>createNewInstance</code> may no longer be used and 
     *  all references to the instance should be cleared. */
    function release () :void;
}

}
