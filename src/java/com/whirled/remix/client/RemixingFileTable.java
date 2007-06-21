//
// $Id$

package com.whirled.remix.client;

import javax.swing.table.TableModel;

import com.whirled.remix.data.EditableDataPack;

public class RemixingFileTable extends AbstractTable
{
    public RemixingFileTable (EditableDataPack pack)
    {
        super(pack);
    }

    // from AbstractTable
    protected TableModel createModel (EditableDataPack pack)
    {
        return new RemixingFileModel(pack);
    }
}
