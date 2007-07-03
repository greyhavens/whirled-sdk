//
// $Id$

package com.whirled.remix.client;

import java.util.List;

import com.whirled.remix.data.EditableDataPack;

/**
 */
public class RemixingDataModel extends AbstractModel
{
    public RemixingDataModel (EditableDataPack pack)
    {
        super(pack);
    }

    @Override
    public Object getValueAt (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case DEFAULT_COL:
            EditableDataPack.DataEntry entry = (EditableDataPack.DataEntry) getEntry(rowIndex);
            return entry.defaultValue;

        default:
            return super.getValueAt(rowIndex, columnIndex);
        }
    }

    // from AbstractModel
    protected List<String> initFields (EditableDataPack pack)
    {
        return pack.getDataFields();
    }

    // from AbstractModel
    protected EditableDataPack.AbstractEntry getEntry (int rowIndex)
    {
        return _pack.getDataEntry(_fields.get(rowIndex));
    }
}
