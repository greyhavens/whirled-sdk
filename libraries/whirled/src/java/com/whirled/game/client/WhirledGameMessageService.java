//
// $Id$

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * Describes the functionality available to game clients for sending messages.
 */
public interface WhirledGameMessageService
    extends InvocationService
{
    /**
     * Requests to send a message to a specific set of other clients in the game. The set is
     * determined by the scope and targetId arguments. The interpretation of the scope varies 
     * depending on the implementer of the service.
     * @param client indicates the sender of the request
     * @param msgName the name of the message
     * @param value the value contained in the message
     * @param scope the super set of clients to choose from
     * @param targetId the group within the scope to send the message to
     * @param listener dispatches the error message if the request fails
     */
    public void sendMessage (Client client, String msgName, Object value, int scope, int targetId,
        InvocationListener listener);
}
