//
// $Id$

package com.whirled.remix.client;

import java.util.List;

import com.whirled.remix.data.EditableDataPack;

/**
 */
public class CreatingFileModel extends RemixingFileModel
{
    public CreatingFileModel (EditableDataPack pack)
    {
        super(pack);
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
}
