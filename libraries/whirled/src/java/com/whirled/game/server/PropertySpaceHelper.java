//
// $Id$

package com.whirled.game.server;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import com.samskivert.util.ObjectUtil;
import com.samskivert.util.StringUtil;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DObjectManager;

import com.whirled.game.data.GameMap;
import com.whirled.game.data.PropertySetEvent;
import com.whirled.game.data.PropertySpaceObject;
import com.whirled.game.data.PropertySpaceObject.PropertySetException;
import com.whirled.game.util.ObjectMarshaller;

import static com.whirled.Log.log;

public abstract class PropertySpaceHelper
{
    /** Properties that begin with this string are persistently stored and restored. */
    public static final String PERSISTENT_PREFIX = "@";

    /**
     * Tests to see if the given property should be persisted.
     */
    public static boolean isPersistent (String propName)
    {
        return propName.startsWith(PERSISTENT_PREFIX);
    }

    /**
     * Called by PropertySetEvent to effect the property update.
     *
     * @return the old value.
     *
     * @throws PropertySetException if there's an error using setIn or setAt
     */
    public static Object applyPropertySet (
        PropertySpaceObject psObj, String propName, Object data, Integer key, boolean isArray)
        throws PropertySetException
    {
        Map<String, Object> props = psObj.getUserProps();

        if (isPersistent(propName)) {
            // TODO: test that this property space handles persistence
            // TODO: test quotas
            psObj.getDirtyProps().add(propName);
        }

        Object oldValue;
        if (key != null) {
            Object curValue = props.get(propName);
            if (isArray) {
                if (!(curValue instanceof Object[])) {
                    throw new PropertySetException("Current value is not an Array.", propName, key);
                }
                // this is actually a byte[][] on the server..
                Object[] arr = (Object[]) curValue;
                int index = key.intValue();
                if (index < 0 || index >= arr.length) {
                    throw new PropertySetException("Array index out of range.", propName, key);
                }
                oldValue = arr[index];
                arr[index] = data;

            } else {
                GameMap map;
                if (curValue instanceof GameMap) {
                    map = (GameMap) curValue;
                } else {
                    if (curValue != null) {
                        throw new PropertySetException("Cannot implicitly create a Dictionary " +
                            "with setIn() over a non-null non-Dictionary property", propName, key);
                    }
                    map = new GameMap(); // force anything else to be a map
                    props.put(propName, map);
                }
                if (data == null) {
                    oldValue = map.remove(key);
                } else {
                    oldValue = map.put(key, (byte[]) data);
                }
            }

        } else if (data != null) {
            // normal property set
            oldValue = props.put(propName, data);

        } else {
            // remove a property
            oldValue = props.remove(propName);
        }

        return oldValue;
    }

    /**
     * Test the specified property against the specified value. This is
     * called on the server to validate testAndSet events.
     *
     * @return true if the property contains the value specified.
     */
    public static boolean testProperty (
        PropertySpaceObject psObj, String propName, Object testValue)
    {
        Map<String, Object> props = psObj.getUserProps();

        Object curValue = props.get(propName);

        // let's test the values!
        if ((testValue instanceof Object[]) && (curValue instanceof Object[])) {
            // testing an array against another array
            return Arrays.deepEquals((Object[]) testValue, (Object[]) curValue);

        } else if ((testValue instanceof byte[]) && (curValue instanceof byte[])) {
            // testing a property against another property (may have
            // been from inside an array)
            return Arrays.equals((byte[]) testValue, (byte[]) curValue);

        // TODO: other array types must be tested if we're on the client
        // ??
        } else {
            // will catch null == null...
            return ObjectUtil.equals(testValue, curValue);
        }
    }

    /**
     * Determine whether we're running on the server (and not on a client).
     */
    public static boolean isOnServer (PropertySpaceObject psObj)
    {
        DObjectManager mgr = ((DObject) psObj).getManager();
        return mgr != null && mgr.isManager((DObject) psObj);
    }

    /**
     * Initializes the given {@link PropertySpaceObject} with data from persistent store.
     * The incoming property values are byte arrays that were created with
     * {@link #encodeForStore(Object)} and they will be passed through
     * {@link #decodeFromStore(byte[])} to recreate the original property value.
     */
    public static void initWithStateFromStore (
        PropertySpaceObject psObj, Map<String, byte[]> fromStore)
    {
        Map<String, Object> state = new HashMap<String, Object>();
        for (Map.Entry<String, byte[]> entry : fromStore.entrySet()) {
            try {
                state.put(entry.getKey(), decodeFromStore(entry.getValue()));

            } catch (Exception e) {
                log.warning("Failed to decode property", "psObj", psObj, "key", entry.getKey(), 
                    "value", StringUtil.toString(entry.getValue()), e);
            }
        }

        // clear the data structures
        psObj.getUserProps().clear();
        psObj.getDirtyProps().clear();

        // copy the initial properties over
        psObj.getUserProps().putAll(state);

        // then catch all our listeners up on the initial state
        DObject plObj = (DObject) psObj;
        plObj.startTransaction();
        for (Map.Entry<String, Object> entry : state.entrySet()) {
            plObj.postEvent(new PropertySetEvent(
                plObj.getOid(), entry.getKey(), entry.getValue(), null, false, null));
        }
        plObj.commitTransaction();
    }

    /**
     * Takes a snapshot of the state of the given {@link PropertySpaceObject}, isolates the
     * portions that have been written to since startup, and passes them through
     * {@link #encodeForStore(Object)} for persistent storage.
     */
    public static Map<String, byte[]> encodeDirtyStateForStore (PropertySpaceObject obj)
    {
        Map<String, Object> allState = obj.getUserProps();
        Map<String, byte[]> dirtyState = new HashMap<String, byte[]>();

        for (String propName : obj.getDirtyProps()) {
            try {
                dirtyState.put(propName, encodeForStore(allState.get(propName)));

            } catch (Exception e) {
                log.warning("Failed to encode property", "psObj", obj, "key", propName, 
                    "value", StringUtil.toString(allState.get(propName)), e);
            }
        }
        return dirtyState;
    }

    /**
     * Writes the state of the given {@link PropertySpaceObject} onto the given stream. This
     * should be called from the custom serialization method writeObject(ObjectOutputStream).
     */
    public static void writeProperties (
        PropertySpaceObject obj, com.threerings.io.ObjectOutputStream out)
        throws IOException
    {
        Map<String, Object> props = obj.getUserProps();

        if (isOnServer(obj)) {
            // write the number of properties, followed by each one
            out.writeInt(props.size());
            for (Map.Entry<String, Object> entry : props.entrySet()) {
                out.writeUTF(entry.getKey());
                out.writeObject(entry.getValue());
            }
        } else {
            throw new IllegalStateException();
        }
    }

    /**
     * Restores the state of the given {@link PropertySpaceObject} from the given stream. This
     * should be called from the custom serialization readObject(ObjectInputStream).
     */
    public static void readProperties (
        PropertySpaceObject obj, com.threerings.io.ObjectInputStream ins)
        throws IOException, ClassNotFoundException
    {
        Map<String, Object> props = obj.getUserProps();
        props.clear();
        int count = ins.readInt();
        boolean onClient = !isOnServer(obj);
        while (count-- > 0) {
            String key = ins.readUTF();
            Object o = ins.readObject();
            if (onClient) {
                o = ObjectMarshaller.decode(o);
            }
            props.put(key, o);
        }
    }

    // use Narya streaming to encode our values
    protected static byte[] encodeForStore (Object obj)
        throws IOException
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(baos);
        // GameMap is a very common class, let's not waste ~20 bytes per property in the DB for it
        oos.addTranslation(GameMap.class.getCanonicalName(), "!");
        oos.writeObject(obj);
        oos.flush();
        return baos.toByteArray();
    }

    // use Narya streaming to encode our values
    protected static Object decodeFromStore (byte[] data)
        throws IOException, ClassNotFoundException
    {
        ObjectInputStream ois = new ObjectInputStream(new ByteArrayInputStream(data));
        ois.addTranslation("!", GameMap.class.getCanonicalName());
        return ois.readObject();
    }
}
