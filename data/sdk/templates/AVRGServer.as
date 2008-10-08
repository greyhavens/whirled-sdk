//
// $Id$
//
// The server agent for @project@ - an AVR game for Whirled

package {

import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;

/**
 * The server agent for @project@. Automatically created by the 
 * whirled server whenever a new game is started. 
 */
public class Server extends ServerObject
{
    /**
     * Constructs a new server agent.
     */
    public function Server ()
    {
        _control = new AVRServerGameControl(this);
        trace("@project@ server agent reporting for duty!");
    }

    protected var _control :AVRServerGameControl;
}

}
