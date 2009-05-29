// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.avrg.probe {

/**
 * Builds a list of method definitions that target a specific subcontrol instance that is retrieved
 * by id.
 */
public class TargetedSubCtrlDef
{
    /** Function that retrieves a subcontrol by id. */
    public var getSubCtrl :Function;

    /** The id parameter prepended to the parameter list for all added methods. */
    public var idParam :Parameter;

    /**
     * Creates a new set of method definitions.
     */
    public function TargetedSubCtrlDef (getSubCtrl :Function, idParam :Parameter)
    {
        this.getSubCtrl = getSubCtrl;
        this.idParam = idParam;
    }

    /**
     * Adds a new method.
     * @param name the name of the method
     * @param getMethod function that retrives the actual method, given a subcontrol instance
     * @param params optional list of parameters to the method
     */
    public function addMethod (name :String, getMethod :Function, params :Array = null) :void
    {
        var method :Method = new Method(name, getMethod);
        method.params = params == null ? new Array() : params.slice();
        method.params.unshift(idParam);
        _methods.push(method);
    }

    /**
     * Convert the list of method definitions to a FunctionSpec array.
     */
    public function toSpecs () :Array
    {
        return _methods.map(function (method :Method, ...unused) :FunctionSpec {
            return method.toSpec(getSubCtrl);
        });
    }

    protected var _methods :Array = [];
}
}

import com.whirled.contrib.avrg.probe.FunctionSpec;

class Method
{
    public var name :String;
    public var getMethod :Function;
    public var params :Array;

    public function Method (name :String, getMethod :Function)
    {
        this.name = name;
        this.getMethod = getMethod;
    }

    public function toSpec (getSubCtrl :Function) :FunctionSpec
    {
        function thunk (...args) :* {
            var subCtrl :* = getSubCtrl(args.shift());
            return getMethod(subCtrl).apply(null, args);
        }
        return new FunctionSpec(name, thunk, params);
    }
}
