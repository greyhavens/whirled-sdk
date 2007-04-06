//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Control for a minigame- tiny, simple, non-networked games which are
 * used inside some larger games.
 */
public class MiniGameControl extends WhirledControl
{
    /**
     */
    public function MiniGameControl (disp :DisplayObject)
    {
        super(disp);
    }

    /**
     * Report our performance to the server. This may be called at any time.
     *
     * @param score A standardized score between 0 (total booch) and
     *              1 (perfect performance).
     * @param style (Optional) Style points, also between 0 and 1.
     */
    public function reportPerformance (score :Number, style :Number = 0) :void
    {
        callHostCode("reportPerformance_v1", score, style);
    }

    // internal bizniss
    override protected function isAbstract () :Boolean
    {
        return false;
    }
}
}
