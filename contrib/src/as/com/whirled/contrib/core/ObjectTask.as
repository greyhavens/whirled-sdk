package com.whirled.contrib.core {

public interface ObjectTask
{
    /**
     * Updates the ObjectTask.
     * Returns true if the task has completed, otherwise false.
     */
    function update (dt :Number, obj :SimObject) :Boolean;

    /** Returns a copy of the ObjectTask */
    function clone () :ObjectTask;

    /**
     * Called when the task's parent object receives a message.
     * Returns true if the task has completed, otherwise false.
     */
    function receiveMessage (msg :ObjectMessage) :Boolean;
}

}
