//
// $Id$

package com.whirled.remix.client;

import com.whirled.remix.data.EditableDataPack;

public class CreatingDataTable extends RemixingDataTable
{
    public CreatingDataTable (EditableDataPack pack)
    {
        super(pack);
    }

    @Override // from AbstractTable
    protected AbstractModel createModel (EditableDataPack pack)
    {
        return new CreatingDataModel(pack);
    }
}
