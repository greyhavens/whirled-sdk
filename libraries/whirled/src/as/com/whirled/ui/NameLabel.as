// 
// $Id$

package com.whirled.ui {

import mx.core.IUIComponent;

/**
 * An interface to enforce that the rendering class of PlayerList members allows some status 
 * indication.  Implicit in the extension of IUIComponent is that the concrete implementation 
 * extends DisplayObject and can be added to the display list (also, clearly, as a Flex component).
 */
public interface NameLabel extends IUIComponent
{
    /**
     * Status to indicate in the rendering of this NameLabel.  Base status constants are indicated
     * in {@link PlayerList}.
     */
    function setStatus (status :String) :void
}
}
