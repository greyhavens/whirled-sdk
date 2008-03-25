package com.whirled.contrib.simplegame.tasks {
    
import com.whirled.contrib.simplegame.ObjectTask;
    
public function After (duration :Number, task :ObjectTask) :ObjectTask
{
    return new SerialTask(new TimedTask(duration), task);
}
    
}