//
// $Id$

package com.whirled.remix.client;

import java.util.List;

import com.whirled.remix.data.EditableDataPack;

/**
 */
public class CreatingDataModel extends RemixingDataModel
{
    public CreatingDataModel (EditableDataPack pack)
    {
        super(pack);
        _deleteRows = true;
    }

    @Override
    public boolean isCellEditable (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case AbstractModel.INFO_COL:
        case AbstractModel.REQUIRED_COL:
            return true;

        default:
            return super.isCellEditable(rowIndex, columnIndex);
        }
    }

    @Override
    protected void deleteRow (int rowIndex, String entryName)
    {
        _pack.removeDataEntry(entryName);
    }
}
