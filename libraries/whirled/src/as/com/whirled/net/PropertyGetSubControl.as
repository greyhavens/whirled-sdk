package com.whirled.net {

[Event(name="PropChanged", type="com.whirled.game.PropertyChangedEvent")]
[Event(name="ElemChanged", type="com.whirled.game.ElementChangedEvent")]
public interface PropertyGetSubControl
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
}
}
