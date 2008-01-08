package com.whirled.contrib.core.tasks {

import com.whirled.contrib.core.ObjectTask;

public class SerialTask extends TaskContainer
{
    public function SerialTask (task1 :ObjectTask = null, task2 :ObjectTask = null)
    {
        super(TaskContainer.TYPE_SERIAL, task1, task2);
    }
}

}
