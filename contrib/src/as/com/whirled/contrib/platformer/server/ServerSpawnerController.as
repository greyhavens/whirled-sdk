//
// $Id$

package com.whirled.contrib.platformer.server {

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.net.SpawnerMessage;
import com.whirled.contrib.platformer.piece.Spawner;

public class ServerSpawnerController extends ServerDynamicController
{
    public function ServerSpawnerController (s :Spawner)
    {
        super(s);
        PlatformerContext.net.addEventListener(SpawnerMessage.NAME, sMsgReceived);
    }

    override public function shutdown () :void
    {
        PlatformerContext.net.removeEventListener(SpawnerMessage.NAME, sMsgReceived);
    }

    protected function sMsgReceived (sMsg :SpawnerMessage) :void
    {
        var s :Spawner = PlatformerContext.board.getDynamicInsById(sMsg.id) as Spawner;
        if (s != null && sMsg.state == SpawnerMessage.SPAWN) {
            PlatformerContext.board.addActor(s.genActor(sMsg.spawnId));
            trace("Spawner spawning " + sMsg.spawnId);
        }
    }
}
}
