//
// $Id$

package com.whirled.contrib.platformer.editor {

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;

import com.whirled.contrib.platformer.display.Metrics;

public class EditorSprite extends Sprite
{
    public function EditorSprite (sprite :Sprite, es :BoardEditSprite)
    {
        _sprite = sprite;
        _es = es;
        addChild(_sprite);

        addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }

    public function setOnScreen (isOn :Boolean) :void
    {
        if (isOn && _sprite.parent == null) {
            addChild(_sprite);
        } else if (!isOn && _sprite.parent != null) {
            removeChild(_sprite);
        }
    }

    public function update () :void
    {
        if (_sprite != null) {
            (_sprite as Object).update();
        }
    }

    public function mouseMove (newX :int, newY :int) :void
    {
        if (!isNaN(_startX)) {
            update();
        }
    }

    public function clearDrag () :void
    {
        _startX = NaN;
    }

    public function setSelected (selected :Boolean) :void
    {
        if (_selected == selected) {
            return;
        }
        _selected = selected;
        if (_selectedH == null) {
            _selectedH = createHighlight(0x006600);
        }
        if (_selected) {
            _sprite.addChild(_selectedH);
        } else {
            _sprite.removeChild(_selectedH);
        }
    }

    public function getTileX () :Number
    {
        return x;
    }

    public function getTileY () :Number
    {
        return y;
    }

    public function getTileWidth () :Number
    {
        return _sprite.width;
    }

    public function getTileHeight () :Number
    {
        return _sprite.height;
    }

    protected function mouseOverHandler (event :MouseEvent) :void
    {
        if (_hoverH == null) {
            _hoverH = createHighlight(0x000066);
        }
        _sprite.addChild(_hoverH);
    }

    protected function mouseOutHandler (event :MouseEvent) :void
    {
        if (_hoverH != null) {
            _sprite.removeChild(_hoverH);
        }
    }

    protected function mouseDownHandler (event :MouseEvent) :void
    {
        _es.setSelected(this);
        _startX = _es.getMouseX() - getTileX();
        _startY = _es.getMouseY() - getTileY();
    }

    protected function sign (num :Number) :Number
    {
        return (num == 0) ? 1 : num / Math.abs(num);
    }

    protected function createHighlight (color :uint) :Shape
    {
        var highlight :Shape = new Shape();
        highlight.graphics.beginFill(color, 0.3);
        highlight.graphics.drawRect(0, -getTileHeight() * Metrics.TILE_SIZE,
                getTileWidth() * Metrics.TILE_SIZE, getTileHeight() * Metrics.TILE_SIZE);
        highlight.graphics.endFill();
        return highlight;
    }

    protected var _sprite :Sprite;
    protected var _es :BoardEditSprite;
    protected var _hoverH :Shape;
    protected var _selectedH :Shape;

    protected var _startX :Number = NaN;
    protected var _startY :Number = NaN;
    protected var _selected :Boolean;

}
}
