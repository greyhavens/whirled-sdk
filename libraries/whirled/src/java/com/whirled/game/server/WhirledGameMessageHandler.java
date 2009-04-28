package com.whirled.game.server;

import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.crowd.data.BodyObject;
import com.threerings.parlor.game.data.UserIdentifier;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * Uses a DObject to implement the audience for a whirled message.
 */
public abstract class WhirledGameMessageHandler
    implements WhirledGameMessageProvider
{
    /** The magic player id constant to indicate a message is from the server. */
    public static final int SERVER = 0;

    /** The magic player id constant to indicate a message is from the server agent. */
    public static final int AGENT = Integer.MIN_VALUE;
    
    /**
     * Creates a new message handler.
     * @param messageTarget the subscribers to this object are the audience of messages
     */
    public WhirledGameMessageHandler (DObject messageTarget, UserIdentifier userIder)
    {
        _messageTarget = messageTarget;
        _userIder = userIder;
    }

    /**
     * Check to see if a client is allowed to send a message.
     * @throws InvocationException if the given caller cannot send a message
     */
    protected abstract void validateSender (ClientObject caller)
        throws InvocationException;

    /**
     * Tests if the given service caller object is an agent.
     */
    protected abstract boolean isAgent (ClientObject caller);
    
    /**
     * Retrieve the client object associated with a private audience member that correpsonds
     * to an id.
     * @throws InvocationException if no audience members exists of the given id
     */
    protected abstract ClientObject getAudienceMember (int id)
        throws InvocationException;

    // from WhirledGameMessageProvider
    public void sendMessage (
        ClientObject caller, String msgName, Object msgValue, InvocationListener listener)
        throws InvocationException
    {
        validateSender(caller);

        int senderId = getMessageSenderId(caller);
        _messageTarget.postMessage(WhirledGameObject.USER_MESSAGE, msgName, msgValue, senderId);
    }

    // from WhirledGameMessageProvider
    public void sendPrivateMessage (
        ClientObject caller, String msgName, Object msgValue, int[] members,
        InvocationListener listener)
        throws InvocationException
    {
        validateSender(caller);

        ClientObject[] targets = new ClientObject[members.length];
        for (int ii = 0; ii < members.length; ++ii) {
            targets[ii] = getAudienceMember(members[ii]);
        }
        
        int senderId = getMessageSenderId(caller);
        String systemMsgName = WhirledPlayerObject.getMessageName(_messageTarget.getOid());
        for (ClientObject target : targets) {
            if (target == null) {
                continue;
            }
            target.postMessage(systemMsgName, msgName, msgValue, senderId);
        }
    }

    /**
     * Gets the id of the client that as a message sender. Since the agent always uses a magic 
     * number as its id, this if not a simple matter of returning the oid.
     */
    protected int getMessageSenderId (ClientObject caller)
    {
        if (caller == null) {
            return SERVER;
        }
        if (isAgent(caller)) {
            return AGENT;
        }
        return _userIder.getUserId(((BodyObject)caller).getVisibleName());
    }

    protected DObject _messageTarget;
    protected UserIdentifier _userIder;
}
