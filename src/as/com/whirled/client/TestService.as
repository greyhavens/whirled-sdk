//
// $Id$

package com.whirled.client {

import flash.utils.ByteArray;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.whirled.client.TestService;

/**
 * An ActionScript version of the Java TestService interface.
 */
public interface TestService extends InvocationService
{
    // from Java interface TestService
    function clientReady (arg1 :Client) :void;
}
}
