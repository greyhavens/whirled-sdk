//
// $Id$

package com.whirled.contrib.platformer.editor {

import mx.collections.HierarchicalData;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Canvas;
import mx.controls.AdvancedDataGrid;
import mx.events.ListEvent;

import flash.events.Event;

public class BaseSelector extends Canvas
{
    public function BaseSelector ()
    {
        _adg = new AdvancedDataGrid();
        _adg.width = 400;
        _adg.height = 200;
        _adg.showHeaders = false;
        _adg.columns = getColumns();
        _adg.doubleClickEnabled = true;
        callLater(sort);
        addChild(_adg);
        _adg.addEventListener(ListEvent.CHANGE, handleChange);
    }

    public function getSelectedItem () :String
    {
        return _selected;
    }

    public function sort () :void
    {
        var field:SortField = new SortField("@label");
        _adg.hierarchicalCollectionView.sort = new Sort();
        _adg.hierarchicalCollectionView.sort.compareFunction = compareNodes;
        _adg.hierarchicalCollectionView.sort.fields = [ field ];
        _adg.hierarchicalCollectionView.refresh();
    }

    protected function getColumns () :Array
    {
        return null;
    }

    protected function compareNodes (data1 :Object, data2 :Object, fields :Array = null) :int
    {
        var parent1 :Boolean = data1.children().length() > 0;
        var parent2 :Boolean = data2.children().length() > 0;

        if (parent1 && !parent2) {
            return -1;
        } else if (parent2 && !parent1) {
            return 1;
        }

        var ret :int = data1.@label.toString().localeCompare(data2.@label.toString());
        if (ret > 0) {
            return 1;
        } else if (ret < 0) {
            return -1;
        }
        return 0;
    }

    protected function handleChange (event :ListEvent) :void
    {
        _selected = getType(_adg.selectedItem as XML);
        dispatchEvent(new Event(Event.CHANGE));
    }

    protected function getType (item :XML) :String
    {
        return (item != null && item.parent() != null && item.children().length() == 0) ?
                item.@label : null;
    }

    protected var _adg :AdvancedDataGrid;
    protected var _selected :String;
}
}
