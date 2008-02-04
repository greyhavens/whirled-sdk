package com.whirled.contrib.core {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.whirled.contrib.core.components.SceneComponent;

import flash.display.DisplayObjectContainer;

public class ObjectDB
{
    public function ObjectDB ()
    {
    }

    /**
     * Adds an AppObject to the database. The AppObject must not be owned by another database.
     * If displayParent is not null, obj's attached DisplayObject will be added as a child
     * of displayParent.
     */
    public function addObject (obj :AppObject, displayParent :DisplayObjectContainer = null) :uint
    {
        if (null == obj || null != obj._parentDB || AppObject.STATE_NEW != obj._objState) {
            throw new ArgumentError("obj must be non-null, and must never have belonged to another ObjectDB");
        }

        // if there's no free slot in our objects array,
        // make a new one
        if (_freeIndexes.length == 0) {
            _freeIndexes.push(uint(_objects.length));
            _objects.push(null);
        }

        Assert.isTrue(_freeIndexes.length > 0);
        var index :uint = _freeIndexes.pop();
        Assert.isTrue(index >= 0 && index < _objects.length);
        Assert.isTrue(_objects[index] == null);

        _objects[index] = obj;

        obj._objectId = createObjectId(index);
        obj._parentDB = this;
        obj._objState = AppObject.STATE_LIVE;

        // does the object have a name?
        if (null != obj.objectName) {
            if (_namedObjects.get(obj.objectName) != null) {
                throw new Error("can't add two objects with the same name to the same ObjectDB");
            }
            
            _namedObjects.put(obj.objectName, obj);
        }

        // is the object in any groups?
        var groupNames :Array = obj.objectGroups;
        if (null != groupNames) {
            for each (var groupName :* in groupNames) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                if (null == groupArray) {
                    groupArray = new Array();
                    _groupedObjects.put(groupName, groupArray);
                }

                groupArray.push(obj.id);
            }
        }

        // should the object be attached to a display parent?
        // (this is purely a convenience - the client is free to
        // do the attaching themselves)
        if (null != displayParent) {
            var sc :SceneComponent = (obj as SceneComponent);
            if (null == sc || null == sc.displayObject) {
                throw new Error("only objects implementing SceneComponent can be attached to a display parent");
            }
            
            displayParent.addChild(sc.displayObject);
        }

        obj.addedToDBInternal();

        ++_objectCount;

        return obj.id;
    }
    
    /** Removes an AppObject from the mode. */
    public function destroyObjectNamed (name :String) :void
    {
        var obj :AppObject = this.getObjectNamed(name);
        if (null != obj) {
            this.destroyObject(obj.id);
        }
    }
    
    /** Removes an AppObject from the mode. */
    public function destroyObject (id :uint) :void
    {
        var obj :AppObject = this.getObject(id);
        
        if (null == obj) {
            return;
        }
        
        obj._objState = AppObject.STATE_PENDING_DESTROY;
        
        // if the object is attached to a DisplayObject, and if that
        // DisplayObject is in a display list, remove it from the display list
        // so that it will no longer be drawn to the screen
        var sc :SceneComponent = (obj as SceneComponent);
        if (null != sc && null != sc.displayObject && null != sc.displayObject.parent) {
            sc.displayObject.parent.removeChild(sc.displayObject);
        }

        // does the object have a name?
        if (null != obj.objectName) {
            Assert.isTrue(_namedObjects.get(obj.objectName) == obj);
            _namedObjects.put(obj.objectName, null);
        }

        obj.destroyedInternal();
        
        if (null == _objectsPendingDestroy) {
            _objectsPendingDestroy = new Array();
        }
        
        // don't remove the object
        _objectsPendingDestroy.push(obj);

        --_objectCount;
    }

    protected function finalizeObjectDestruction (obj :AppObject) :void
    {
        Assert.isTrue(AppObject.STATE_PENDING_DESTROY == obj._objState);

        var index :uint = idToIndex(obj.id);
        Assert.isTrue(obj == _objects[index]);
        _objects[index] = null;
        _freeIndexes.unshift(index); // we have a new free index

        // is the object in any groups?
        // (we remove the object from its groups here, rather than in
        // destroyObject(), because client code might be iterating an
        // object group Array when destroyObject is called)
        var groupNames :Array = obj.objectGroups;
        if (null != groupNames) {
            for each (var groupName :* in groupNames) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                Assert.isTrue(null != groupArray);
                var wasInArray :Boolean = ArrayUtil.removeFirst(groupArray, obj.id);
                Assert.isTrue(wasInArray);
            }
        }
        
        obj._objState = AppObject.STATE_DESTROYED;
        obj._parentDB = null;
        obj._objectId = 0;
    }

    public function getObject (id :uint) :AppObject
    {
        var index :uint = idToIndex(id);

        if (index < _objects.length) {

            var obj :AppObject = _objects[index];

            if (null != obj && AppObject.STATE_LIVE == obj._objState && idToSerialNumber(id) == idToSerialNumber(obj.id)) {
                return obj;
            }
        }

        return null;
    }

    /** Returns the object in this mode with the given name, or null if no such object exists. */
    public function getObjectNamed (name :String) :AppObject
    {
        return (_namedObjects.get(name) as AppObject);
    }

    /** 
     * Returns an Array containing the object IDs of all the objects in the given group. 
     * This Array must not be modified by client code.
     * 
     * Note: because of the method that object destruction is implemented with,
     * the returned Array may contain invalid object IDs.
     */
    public function getObjectIdsInGroup (groupName :String) :Array
    {
        var ids :Array = (_groupedObjects.get(groupName) as Array);

        return (null != ids ? ids : new Array());
    }
    
    /**
     * Returns an Array containing the AppObjects in the given group.
     * The returned Array is instantiated by the function, and so can be
     * safely modified by client code.
     * 
     * This function is not as performant as getObjectIdsInGroup().
     */
    public function getObjectsInGroup (groupName :String) :Array
    {
        var ids :Array = this.getObjectIdsInGroup(groupName);
        
        // Array.map would be appropriate here, except that the resultant
        // Array might contain fewer entries than the source.
        
        var objs :Array = new Array();
        for each (var id :uint in ids) {
            var obj :AppObject = this.getObject(id);
            if (null != obj) {
                objs.push(obj);
            }
        }
        
        return objs;
    }

    /** Called once per update tick. Updates all objects in the mode. */
    public function update (dt :Number) :void
    {
        var obj :AppObject;
        
        // update all objects in this mode
        for each (obj in _objects) {
            if (null != obj && AppObject.STATE_LIVE == obj._objState) {
                obj.updateInternal(dt);
            }
        }
        
        // clean out all objects that were destroyed during the update loop
        if (null != _objectsPendingDestroy) {
            for each (obj in _objectsPendingDestroy) {
                this.finalizeObjectDestruction(obj);
            }
            
            _objectsPendingDestroy = null;
        }
    }

    /** Sends a message to every object in the database. */
    public function broadcastMessage (msg :ObjectMessage) :void
    {
        for each (var obj :AppObject in _objects) {
            if (null != obj) {
                obj.receiveMessageInternal(msg);
            }
        }
    }

    /** Sends a message to a specific object. */
    public function sendMessageTo (msg :ObjectMessage, targetId :uint) :void
    {
        var target :AppObject = this.getObject(targetId);
        if (null != target) {
            target.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to the object with the given name. */
    public function sendMessageToNamedObject (msg :ObjectMessage, objectName :String) :void
    {
        var target :AppObject = this.getObjectNamed(objectName);
        if (null != target) {
            target.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to each object in the given group. */
    public function sendMessageToGroup (msg :ObjectMessage, groupName :String) :void
    {
        var ids :Array = this.getObjectIdsInGroup(groupName);
        for each (var id :uint in ids) {
            this.sendMessageTo(msg, id);
        }
    }

    internal function createObjectId (index :uint) :uint
    {
        Assert.isTrue(index <= 0x0000FFFF);

        var sn :uint = _serialNumberCounter++;

        if (_serialNumberCounter > 0x0000FFFF) {
            _serialNumberCounter = 1; // never generate a sn of 0. objectId==0 is the "null" object.
        }

        return ((sn << 16) | (index & 0x0000FFFF));
    }

    internal function idToIndex (id :uint) :uint
    {
        return (id & 0x0000FFFF);
    }

    internal function idToSerialNumber (id :uint) :uint
    {
        return (id >> 16);
    }

    public function get objectCount () :uint
    {
        return _objectCount;
    }

    protected var _objectCount :uint;
    protected var _objects :Array = new Array();
    protected var _freeIndexes :Array = new Array();
    protected var _serialNumberCounter :uint = 1;
    
    protected var _objectsPendingDestroy :Array;

    /** stores a mapping from String to Object */
    protected var _namedObjects :HashMap = new HashMap();

    /** stores a mapping from String to Array */
    protected var _groupedObjects :HashMap = new HashMap();
}

}
