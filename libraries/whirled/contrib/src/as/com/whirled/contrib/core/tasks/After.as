package com.whirled.contrib.core.tasks {
    
import com.whirled.contrib.core.ObjectTask;
    
public function After (duration :Number, task :ObjectTask) :ObjectTask
{
    return new SerialTask(new TimedTask(duration), task);
}
    
}