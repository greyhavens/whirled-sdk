//
// $Id$

package com.whirled.remix.client;

import javax.swing.JTable;

import com.whirled.remix.data.EditableDataPack;

public class CreatingPanel extends RemixingPanel
{
    public CreatingPanel ()
    {
        super(new EditableDataPack());
    }

    @Override
    protected JTable createDataTable (EditableDataPack pack)
    {
        return new CreatingDataTable(pack);
    }

    @Override
    protected JTable createFileTable (EditableDataPack pack)
    {
        return new CreatingFileTable(pack);
    }

    @Override
    protected void addDataControls ()
    {
        // TODO
    }

    @Override
    protected void addFileControls ()
    {
        // TODO
    }
}
