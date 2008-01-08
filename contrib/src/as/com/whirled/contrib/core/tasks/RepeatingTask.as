package com.whirled.contrib.core.tasks {

import com.whirled.contrib.core.ObjectTask;

public class RepeatingTask extends TaskContainer
{
    public function RepeatingTask (task1 :ObjectTask = null, task2 :ObjectTask = null)
    {
        super(TaskContainer.TYPE_REPEATING, task1, task2);
    }
}

}
