//
// $Id$
//

package com.whirled.ui {

import mx.core.UIComponent;

import com.threerings.util.Name;

public interface NameLabelCreator 
{
    function createLabel (name :Name) :NameLabel;
}
}
