package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

public class HookSubControl extends AbstractSubControl
{
    public function HookSubControl (ctrl :AbstractControl, hookPrefix :String)
    {
        super(ctrl);
        _hookPrefix = hookPrefix;
    }

    protected var _hookPrefix :String;
}
}
