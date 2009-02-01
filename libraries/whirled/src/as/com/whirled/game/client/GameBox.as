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

public class GameBox extends VBox
    implements ChatCantStealFocus
{
    /**
     * Creates a new game container to load the given url but does not actually start loading it.
     */
    public function GameBox (url :String, container :MediaContainer)
    {
        tabEnabled = true; // turned off by Container

        _url = url;
        _container = container;
    }

    /**
     * Starts loading the content of this container.
     */
    public function initiateLoading () :void
    {
        // TODO: instantiate the byte array after completion
        // Note from Ray: This is not as easy as you think, because loading bytes places the
        // content in your own security domain. I think we might be able to load the media stub
        // and ask it to instantiate the bytes, and that might work.

        _container.setMedia(_url);
        rawChildren.addChild(_container);
    }

    protected var _url :String;
    protected var _container :MediaContainer;
}
}
