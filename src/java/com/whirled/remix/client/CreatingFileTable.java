//
// $Id$

package com.whirled.remix.client;

import javax.swing.table.TableModel;

import com.whirled.remix.data.EditableDataPack;

public class CreatingFileTable extends RemixingFileTable
{
    public CreatingFileTable (EditableDataPack pack)
    {
        super(pack);
    }

    @Override // from AbstractTable
    protected AbstractModel createModel (EditableDataPack pack)
    {
        return new CreatingFileModel(pack);
    }
}
