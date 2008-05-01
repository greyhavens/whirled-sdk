package com.whirled.contrib.card.graphics {

/** Wrapper for caurina.transitions.Tweener
 *  TODO: setup build system to incorporate tweener.swc in contrib */
public class LocalTweener
{
    public static var addTweenFn :Function = defaultAddTween;
    public static var removeTweensFn :Function = defaultRemoveTweens;
    public static var isTweeningFn :Function = defaultIsTweening;

    public static function addTween (
        p_arg1 :Object = null, 
        p_arg2:Object = null) :Boolean
    {
        return addTweenFn(p_arg1, p_arg2);
    }

    public static function removeTweens (
        p_scope :Object, ...args):Boolean
    {
        switch (args.length) {
        case 0:
            return removeTweensFn(p_scope);
        case 1:
            return removeTweensFn(p_scope, args[0]);
        case 2:
            return removeTweensFn(p_scope, args[0], args[1]);
        case 3:
            return removeTweensFn(p_scope, args[0], args[1], args[2]);
        case 4:
            return removeTweensFn(p_scope, args[0], args[1], args[2], args[3]);
        case 5:
            return removeTweensFn(p_scope, args[0], args[1], args[2], args[3],
                args[4]);
        case 6:
            return removeTweensFn(p_scope, args[0], args[1], args[2], args[3],
                args[4], args[5]);
        default:
            throw new Error("Need more argument cases");
        }
    }

    public static function isTweening (p_scope :Object) :Boolean
    {
        return isTweeningFn(p_scope);
    }

    protected static function defaultAddTween (
        p_arg1 :Object, p_arg2 :Object) :Boolean
    {
        return false;
    }

    protected static function defaultRemoveTweens (
        p_scope :Object, ...args):Boolean
    {
        return false;
    }

    protected static function defaultIsTweening (
        p_scope :Object):Boolean
    {
        return false;
    }
}

}

