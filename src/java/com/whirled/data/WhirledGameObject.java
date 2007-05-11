//
// $Id$

package com.whirled.data;

/**
 * Games that wish to make use of Whirled game services should implement this interface.
 */
public interface WhirledGameObject
{
    /**
     * Informs this game object of its flow per minute award cap.
     */
    public void setFlowPerMinute (int flowPerMinute);

    /**
     * Configures the {@link WhirledGameService} for this game.
     */
    public void setWhirledGameService (WhirledGameMarshaller whirledGameService);
}
