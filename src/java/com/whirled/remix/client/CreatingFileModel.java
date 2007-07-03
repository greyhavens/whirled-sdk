//
// $Id$

package com.whirled.remix.client;

import java.util.List;

import com.whirled.remix.data.EditableDataPack;

/**
 */
public class CreatingFileModel extends RemixingFileModel
{
    public CreatingFileModel (EditableDataPack pack, CreatingFileTable table)
    {
        super(pack, table);
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
        _pack.removeFileEntry(entryName);
    }
}
