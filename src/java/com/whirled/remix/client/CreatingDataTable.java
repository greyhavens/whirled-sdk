//
// $Id$

package com.whirled.remix.client;

import java.awt.Component;

import javax.swing.DefaultCellEditor;
import javax.swing.JButton;
import javax.swing.JPanel;

import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.TableCellEditor;
import javax.swing.table.TableCellRenderer;
import javax.swing.table.TableModel;

import com.samskivert.swing.HGroupLayout;
import com.samskivert.util.StringUtil;

import com.whirled.remix.data.EditableDataPack;

public class CreatingDataTable extends RemixingFileTable
{
    public CreatingDataTable (EditableDataPack pack)
    {
        super(pack);
    }

    @Override
    public TableCellEditor getCellEditor (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellEditor(row, column);
        }
    }

    @Override // from AbstractTable
    protected AbstractModel createModel (EditableDataPack pack)
    {
        return new CreatingDataModel(pack);
    }
}
