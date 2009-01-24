// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.platformer.display {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.getTimer;

import com.whirled.contrib.platformer.util.Metrics;

public class ParticleLayer extends Layer
{
    public function addParticleEffect (cw :CacheWrapper, pt :Point) :void
    {
        var newpt :Point = globalToLocal(pt);
        if (newpt.x > -x - BUFFER && newpt.x < -x + Metrics.DISPLAY_WIDTH + BUFFER &&
                newpt.y > -y - BUFFER && newpt.y < -y + Metrics.DISPLAY_HEIGHT + BUFFER) {
            cw.disp.x = newpt.x;
            cw.disp.y = newpt.y;
            cw.resetOnComplete();
            addChild(cw.disp);
            if (cw.disp is MovieClip) {
                (cw.disp as MovieClip).gotoAndPlay(1);
            }
        } else {
            cw.reset();
        }
    }

    protected static const BUFFER :Number = Metrics.DISPLAY_HEIGHT/2;
}
}
