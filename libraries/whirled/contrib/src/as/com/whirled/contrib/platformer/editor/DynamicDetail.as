//
// $Id$

package com.whirled.contrib.platformer.editor {

import mx.controls.TextInput;
import mx.core.UIComponent;

import com.whirled.contrib.platformer.piece.Dynamic;

public class DynamicDetail extends Detail
{

    public function DynamicDetail (varxml :XML, d:Dynamic)
    {
        super();
        name = varxml.@id;
        _input = new TextInput();
        _input.text = (d as Object)[name];
    }

    public function updateDynamic (d :Dynamic) :void
    {
        (d as Object)[name] = _input.text;
    }

    protected override function input () :UIComponent
    {
        return _input;
    }

    protected var _input :TextInput;
}
}
