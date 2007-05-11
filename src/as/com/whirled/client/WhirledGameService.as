//
// $Id$

package com.whirled.client {

import flash.utils.ByteArray;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.whirled.client.WhirledGameService;

/**
 * An ActionScript version of the Java WhirledGameService interface.
 */
public interface WhirledGameService extends InvocationService
{
    // from Java interface WhirledGameService
    function awardFlow (arg1 :Client, arg2 :int, arg3 :InvocationService_InvocationListener) :void;
}
}
