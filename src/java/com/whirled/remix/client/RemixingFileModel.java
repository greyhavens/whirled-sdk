//
// $Id$

package com.whirled.remix.client;

import java.util.List;

import com.whirled.remix.data.EditableDataPack;

/**
 */
public class RemixingFileModel extends AbstractModel
{
    public RemixingFileModel (EditableDataPack pack)
    {
        super(pack);
    }

    @Override
    public String getColumnName (int column)
    {
        switch (column) {
        case VALUE_COL:
            return "Path";

        default:
            return super.getColumnName(column);
        }
    }

    // from AbstractModel
    protected List<String> initFields (EditableDataPack pack)
    {
        return pack.getFileFields();
    }

    // from AbstractModel
    protected EditableDataPack.AbstractEntry getEntry (int rowIndex)
    {
        return _pack.getFileEntry(_fields.get(rowIndex));
    }
}
