package com.whirled.bureau.client {

/** Represents user code loaded from an external server. Provided by an implementation of 
 *  {@link UserCodeLoader}. */
public interface UserCode
{
    /** Connects to the user code, assigning it the given host props and returning the user 
     *  props. */
    function connect (connectListener :Function, traceListener :Function) :void;

    /** Releases this code. Once released, <code>createNewInstance</code> may no longer be used and 
     *  all references to the instance should be cleared. */
    function release () :void;
}

}
