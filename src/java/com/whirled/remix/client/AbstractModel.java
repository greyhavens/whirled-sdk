//
// $Id$

package com.whirled.remix.client;

import java.util.List;
import java.util.HashMap;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import javax.swing.table.AbstractTableModel;

import com.whirled.remix.data.EditableDataPack;

/**
 */
public abstract class AbstractModel extends AbstractTableModel
{
    public static final int NAME_COL = 0;
    public static final int INFO_COL = 1;
    public static final int TYPE_COL = 2;
    public static final int VALUE_COL = 3;
    public static final int REQUIRED_COL = 4;
    public static final int ACTIONS_COL = 5; // actions will have buttons to revert
    public static final int COLUMN_COUNT = 6;

    /** Flags set in the action field. */
    public static final int ACTION_REVERT = 1 << 0;
    public static final int ACTION_SHOW_DELETE = 1 << 1;
    public static final int ACTION_DELETE = 1 << 2;

    public AbstractModel (EditableDataPack pack)
    {
        _pack = pack;
        _fields = initFields(pack);

        pack.addChangeListener(new ChangeListener() {
            public void stateChanged (ChangeEvent event) {
                _fields = initFields(_pack);

                // drop now-unneeded revert values
                _revertValues.keySet().retainAll(_fields);

                fireTableDataChanged();
            }
        });
    }

    /**
     * Return the desired preferred column width for the specified column.
     */
    public int getPreferredColumnWidth (int column)
    {
        switch (column) {
        case INFO_COL:
        case VALUE_COL:
            return 250;

        default:
            return 100;
        }
    }

    // from TableModel
    public int getRowCount ()
    {
        return _fields.size();
    }

    // from TableModel
    public int getColumnCount ()
    {
        return COLUMN_COUNT;
    }

    // from TableModel
    public Object getValueAt (int rowIndex, int columnIndex)
    {
        EditableDataPack.AbstractEntry entry = getEntry(rowIndex);
        switch (columnIndex) {
        case NAME_COL:
            return entry.name;

        case INFO_COL:
            return entry.info;

        case TYPE_COL:
            return entry.getType();

        case VALUE_COL:
            return entry.value;

        case REQUIRED_COL:
            return !entry.optional;

        case ACTIONS_COL:
            int flags = 0;
            if (_revertValues.containsKey(entry.name)) {
                flags |= ACTION_REVERT;
            }
            return Integer.valueOf(flags);

        default:
            return null;
        }
    }

    @Override
    public String getColumnName (int column)
    {
        switch (column) {
        case NAME_COL:
            return "Name";

        case INFO_COL:
            return "Description";

        case TYPE_COL:
            return "Type";

        case VALUE_COL:
            return "Value";

        case REQUIRED_COL:
            return "Required";

        case ACTIONS_COL:
            return "Actions";

        default:
            return "UNKNOWN";
        }
    }

    @Override
    public Class<?> getColumnClass (int column)
    {
        switch (column) {
        default:
            return String.class;

        case REQUIRED_COL:
            return Boolean.class;

        case ACTIONS_COL:
            return Integer.class;
        }
    }

    @Override
    public boolean isCellEditable (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case VALUE_COL: // standardly, the only editable field is the value
        case ACTIONS_COL: // this is editable so we can push the buttons...
        case INFO_COL:
            return true;

        default:
            return false;
        }
    }

    @Override
    public void setValueAt (Object newValue, int rowIndex, int columnIndex)
    {
        EditableDataPack.AbstractEntry entry = getEntry(rowIndex);
        switch (columnIndex) {
        case VALUE_COL:
            // I'm going to assume that the cell editor returns a properly formatted value.
            // Always a String, never a Stringsmaid.
            if (!_revertValues.containsKey(entry.name)) {
                _revertValues.put(entry.name, entry.value);
                fireTableCellUpdated(rowIndex, ACTIONS_COL);
            }
            entry.value = (String) newValue;
            break;

        case ACTIONS_COL:
            // the new value will be an action indicating what has happened
            int action = ((Integer) newValue).intValue();
            switch (action) {
            case ACTION_REVERT:
                entry.value = _revertValues.remove(entry.name);
                fireTableCellUpdated(rowIndex, VALUE_COL);
                break;
            }
            break;

        case INFO_COL:
            // implemented here for ease, but only specific subclasses allow setting this field
            entry.info = (String) newValue;
            break;

        case REQUIRED_COL:
            // implemented here for ease, but only specific subclasses allow setting this field
            entry.optional = !((Boolean) newValue).booleanValue();
            break;
        }
    }

    /**
     * Extract the String names of the entries in this model.
     */
    protected abstract List<String> initFields (EditableDataPack pack);

    /**
     * Get the entry for the specified row.
     */
    protected abstract EditableDataPack.AbstractEntry getEntry (int rowIndex);

    /** The pack we're editing. */
    protected EditableDataPack _pack;

    /** A List of the names to be used in the rows. */
    protected List<String> _fields;

    /** A mapping of datum name to the original value, only if the value was changed. */
    protected HashMap<String,String> _revertValues = new HashMap<String,String>();
}
