//
// $Id$

package com.whirled.game {

import flash.errors.IllegalOperationError;

/**
 * Abstract base class. Do not instantiate.
 * @private
 */
public class AbstractSubControl extends AbstractControl
{
    /**
     * @private
     */
    public function AbstractSubControl (parent :AbstractControl)
    {
        super();
        if (parent == null || Object(this).constructor == AbstractSubControl) {
            throw new IllegalOperationError("Abstract");
        }

        _parent = parent;
    }

    /**
     * @inheritDoc
     */
    override public function isConnected () :Boolean
    {
        return _parent.isConnected();
    }

    /**
     * @inheritDoc
     */
    override public function doBatch (fn :Function) :void
    {
        return _parent.doBatch(fn);
    }

    /**
     * @private
     */
    override protected function callHostCode (name :String, ... args) :*
    {
        return _parent.callHostCodeFriend(name, args);
    }

    /**
     * @private
     */
    internal function populatePropertiesFriend (o :Object) :void
    {
        populateProperties(o);
    }

    /**
     * @private
     */
    internal function setHostPropsFriend (o :Object) :void
    {
        setHostProps(o);
    }

    /** @private */
    protected var _parent :AbstractControl;
}
}
