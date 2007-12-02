package com.whirled.contrib {

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;

import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.utils.setTimeout;

import com.threerings.flash.SimpleTextButton;
import com.threerings.util.Log;

import com.whirled.EntityControl;

/**
 * Entites that need initial configuration, e.g. after purchase from the catalog, may
 * find this class useful. It looks up a configuration entry by key in the entity's
 * memory, and if it does not find the entry, waits for a mouse click on the entity's
 * sprite.
 *
 * The click pops up a configuration pane which asks for the value, which is then set
 * in entity memory so nobody ever sees the popup again.
 */
public class Configurator
{
    /**
     * Gets the requested configuration entry from entity memory or failing that, from
     * the user; whenever the value (which is a String) is safely in hand, the callback
     * is executed with it, and the entity may continue setting itself up.
     */
    public static function requestEntry (control :EntityControl, sprite :DisplayObject,
                                         key :String, configured :Function) :void
    {
        new Configurator(control, sprite, key, configured);
    }

    public function Configurator (control :EntityControl, sprite :DisplayObject,
                                  key :String, configured :Function)
    {
        // most of the time the value will have been configured
        var value :Object = control.lookupMemory(key);
        if (value != null) {
            setTimeout(configured, 0, value);

        }
        // otherwise remember all the bits
        _control = control;
        _key = key;
        _configured = configured;

        sprite.addEventListener(MouseEvent.CLICK, handleClick);
    }

    protected function handleClick (evt :MouseEvent) :void
    {
        var popup :Sprite = new Sprite();

        var y :int = PADDING;

        var format :TextFormat = new TextFormat();
        format.font = "Arial";
        format.size = 14;
        format.color = 0xFFFFFF;

        var text :TextField = new TextField();
        text.x = PADDING;
        text.y = y;
        text.defaultTextFormat = format;
        text.width = WIDTH - PADDING;
        text.autoSize = TextFieldAutoSize.LEFT;
        text.wordWrap = true;
        text.htmlText =
            "Please enter a value for this object's <i>" + _key + "</i> configuration entry:";
        popup.addChild(text);

        y += text.height + PADDING;

        var input :TextField = new TextField();
        input.x = 2 * PADDING;
        input.y = y;
        input.defaultTextFormat = format;
        input.width = WIDTH - 4 * PADDING;
        input.height = 18;
        input.maxChars = 16; // arbitrary
        input.type = TextFieldType.INPUT;

        var inputBox :Shape = new Shape();
        inputBox.x = input.x - 2;
        inputBox.y = input.y - 2;
        with (inputBox.graphics) {
            beginFill(0x6699CC);
            drawRoundRect(0, 0, input.width + 4, input.height + 4, 10);
            endFill();
        }
        popup.addChild(inputBox);
        popup.addChild(input);

        y += input.height + PADDING;

        var ok :SimpleButton = new SimpleTextButton("OK");
        ok.x = WIDTH - PADDING - ok.width;
        ok.y = y;
        ok.addEventListener(MouseEvent.CLICK, function (evt :MouseEvent) :void {
            if (input.text && _control.updateMemory(_key, input.text)) {
                _configured(input.text);
                evt.currentTarget.removeEventListener(MouseEvent.CLICK, handleClick);
                _control.clearPopup();
            }
        });
        popup.addChild(ok);

        y += ok.height + PADDING;

        with (popup.graphics) {
            beginFill(0x003366);
            drawRoundRect(0, 0, WIDTH, y, PADDING);
            endFill();
        }

        _control.showPopup("", popup, popup.width, popup.height, 0x6699CC);
    }

    protected var _control :EntityControl;
    protected var _key :String;
    protected var _configured :Function;

    protected static const WIDTH :int = 200;
    protected static const PADDING :int = 10;
}
}
