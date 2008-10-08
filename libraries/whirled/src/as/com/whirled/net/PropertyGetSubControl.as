//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.net {

import flash.events.IEventDispatcher;

/**
 * Provides the ability to read game state in the form of named properties which are
 * automatically shared between players and, potentially, the server agent.
 */
public interface PropertyGetSubControl extends IEventDispatcher
{
    /**
     * Get a property value. Calling this method results in no network traffic, it just
     * examines values that have already arrived over the network to this client.
     *
     * @param propName the name of the property to retrieve.
     * @return the property value, or null if there is no property with that name.
     */
    function get (propName :String) :Object;

    /**
     * Get the names of all currently-set properties that begin with the specified prefix.
     * Calling this method results in no network traffic.
     */
    function getPropertyNames (prefix :String = "") :Array;

    /**
     * Get the targetId on which this control operates.
     */
    function getTargetId () :int;
}
}
