package com.whirled.contrib.core.tasks {

import com.threerings.util.Assert;
import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.ObjectMessage;
import com.whirled.contrib.core.ObjectTask;

public class TaskContainer
    implements ObjectTask
{
    public static const TYPE_PARALLEL :uint = 0;
    public static const TYPE_SERIAL :uint = 1;
    public static const TYPE_REPEATING :uint = 2;
    
    public static const TYPE__LIMIT :uint = 3;

    public function TaskContainer (type :uint, task1 :ObjectTask = null, task2 :ObjectTask = null)
    {
        if (type >= TYPE__LIMIT) {
            throw new ArgumentError("invalid 'type' parameter");
        }
        
        _type = type;

        if (null != task1) {
            addTask(task1);
        }
        if (null != task2) {
            addTask(task2);
        }
    }

    /** Adds a child task to the TaskContainer. */
    public function addTask (task :ObjectTask) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }
        
        _tasks.push(task);
        _completedTasks.push(null);
        _activeTaskCount += 1;
    }

    /** Removes all tasks from the TaskContainer. */
    public function removeAllTasks () :void
    {
        _tasks = new Array();
        _completedTasks = new Array();
        _activeTaskCount = 0;
    }

    /** Returns true if the TaskContainer has any child tasks. */
    public function hasTasks () :Boolean
    {
        return (_activeTaskCount > 0);
    }

    public function update (dt :Number, obj :AppObject) :Boolean
    {
        return this.applyFunction(
            function (task :ObjectTask) :Boolean {
                return task.update(dt, obj);
            }
        );
    }

    protected function cloneSubtasks () :Array
    {
        Assert.isTrue(_tasks.length == _completedTasks.length);

        var out :Array = new Array(_tasks.length);

        // clone each child task and put it in the cloned container
        for (var i:int = 0; i < _tasks.length; ++i) {
            var task :ObjectTask = (null != _tasks[i] ? _tasks[i] as ObjectTask : _completedTasks[i] as ObjectTask);
            Assert.isNotNull(task);
            out[i] = task.clone();
        }

        return out;
    }

    /** Returns a clone of the TaskContainer. */
    public function clone () :ObjectTask
    {
        var theClone :TaskContainer = new TaskContainer(_type);
        theClone._tasks = this.cloneSubtasks();

        return theClone;
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return this.applyFunction(
            function (task :ObjectTask) :Boolean {
                return task.receiveMessage(msg);
            }
        );
    }

    /**
     * Helper function that applies the function f to each object in the container
     * (for parallel tasks) or the first object in the container (for serial and repeating tasks)
     * and returns true if there are no more active tasks in the container.
     * f must be of the form:
     * function f (task :ObjectTask) :Boolean
     * it must return true if the task is complete after f is applied.
     */
    protected function applyFunction (f :Function) :Boolean
    {
        var i :int;

        for (i = 0; i < _tasks.length; ++i) {
            var task :ObjectTask = (_tasks[i] as ObjectTask);

            // we can have holes in the array
            if (null == task) {
                continue;
            }

            var complete :Boolean = f(task);

            if (!complete && TYPE_PARALLEL != _type) {
                // Serial and Repeating tasks proceed one task at a time
                break;

            } else if (complete) {
                // the task is complete - move it the completed tasks array
                _completedTasks[i] = _tasks[i];
                _tasks[i] = null;
                _activeTaskCount -= 1;
            }
        }

        // if this is a repeating task and all its tasks have been completed, start over again
        if (_type == TYPE_REPEATING && 0 == _activeTaskCount && _completedTasks.length > 0) {
            var completedTasks :Array = _completedTasks;

            _tasks = new Array();
            _completedTasks = new Array();

            for each (var completedTask :ObjectTask in completedTasks) {
                this.addTask(completedTask.clone());
            }
        }

        // once we have no more active tasks, we're complete
        return (0 == _activeTaskCount);
    }

    protected var _type :int;
    protected var _tasks :Array = new Array();
    protected var _completedTasks :Array = new Array();
    protected var _activeTaskCount :uint;
}

}
