//
// $Id: GameContainer.as 271 2007-04-07 00:25:58Z dhoover $
//
// Vilya library - tools for developing networked games
// Copyright (C) 2002-2007 Three Rings Design, Inc., All Rights Reserved
// http://www.threerings.net/code/vilya/
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.whirled.game.client {

import flash.display.DisplayObject;

import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.core.IFlexDisplayObject;
import mx.core.IInvalidating;

import mx.containers.VBox;

import mx.managers.IFocusManagerComponent;

import mx.skins.ProgrammaticSkin;

import com.threerings.crowd.chat.client.ChatCantStealFocus;

import com.threerings.flash.MediaContainer;

public class GameContainer extends VBox
    implements ChatCantStealFocus
{
    public function GameContainer (url :String)
    {
        rawChildren.addChild(_game = new MediaContainer(url));

        tabEnabled = true; // turned off by Container
    }

    public function getMediaContainer () :MediaContainer
    {
        return _game;
    }

    protected var _game :MediaContainer;
}
}
