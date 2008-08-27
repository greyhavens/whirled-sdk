//
// $Id$

package com.whirled.contrib.platformer.editor {

import com.whirled.contrib.platformer.display.DynamicSprite;
import com.whirled.contrib.platformer.piece.Dynamic;

public class EditorDynamicSprite extends EditorSprite
{
    public function EditorDynamicSprite (ds :DynamicSprite, es :BoardEditSprite)
    {
        super(ds, es);

        _dynamic = ds.getDynamic();
        name = _dynamic.id.toString();
        ds.setStatic(true);
    }

    public override function update () :void
    {
        (_sprite as DynamicSprite).update(0);
    }

    public override function getTileX () :Number
    {
        return _dynamic.x;
    }

    public override function getTileY () :Number
    {
        return _dynamic.y;
    }

    public override function getTileWidth () :Number
    {
        if (_dynamic.hasOwnProperty("width")) {
            return (_dynamic as Object).width;
        } else {
            return 1;
        }
    }

    public override function getTileHeight () :Number
    {
        if (_dynamic.hasOwnProperty("height")) {
            return (_dynamic as Object).height;
        } else {
            return 1;
        }
    }

    public override function mouseMove (newX :int, newY :int) :void
    {
        if (!isNaN(_startX)) {
            _dynamic.x = Math.max(0, newX - _startX);
            _dynamic.y = Math.max(0, newY - _startY);
            update();
        }
    }

    protected var _dynamic :Dynamic;
}
}
