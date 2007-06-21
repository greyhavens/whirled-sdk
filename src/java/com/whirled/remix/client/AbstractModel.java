//
// $Id$

package com.whirled.remix.client;

import java.util.List;

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
    public static final int OPTIONAL_COL = 4;
    public static final int ACTIONS_COL = 5; // actions will have buttons to revert
    public static final int COLUMN_COUNT = 6;

    public AbstractModel (EditableDataPack pack)
    {
        _pack = pack;
        _fields = initFields(pack);
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

        case OPTIONAL_COL:
            return entry.optional;

        case ACTIONS_COL:
            return 0; // TODO: some bitmask or other attrs describing the actions that can be taken

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

        case OPTIONAL_COL:
            return "optional?";

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

        case OPTIONAL_COL:
            return Boolean.class;
        }
    }

    @Override
    public boolean isCellEditable (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case VALUE_COL: // standardly, the only editable field is the value
        case ACTIONS_COL: // this is editable so we can push the buttons...
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
            entry.value = (String) newValue;
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
}
