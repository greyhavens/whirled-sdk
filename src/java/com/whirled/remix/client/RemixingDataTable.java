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

public class RemixingDataTable extends AbstractTable
{
    public RemixingDataTable (EditableDataPack pack)
    {
        super(pack);
    }

    @Override
    public TableCellRenderer getCellRenderer (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellRenderer(row, column);

        case RemixingDataModel.VALUE_COL: {
                EditableDataPack.DataType type = (EditableDataPack.DataType)
                    getModel().getValueAt(convertRowIndexToModel(row), RemixingDataModel.TYPE_COL);
                switch (type) {
                default:
                    return _decodingRenderer;

                //case BOOLEAN:
                //    return getDefaultRenderer(Boolean.class);

                case POINT:
                    return _pointRenderer;

                case RECTANGLE:
                    return _rectangleRenderer;
                }
            }
        }
    }

    @Override
    public TableCellEditor getCellEditor (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellEditor(row, column);
        }
    }

    // from AbstractTable
    protected TableModel createModel (EditableDataPack pack)
    {
        return new RemixingDataModel(pack);
    }

    protected static class PointCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            if (value != null) {
                value = "[" + value + "]";
            }
            super.setValue(value);
        }
    }

    protected static class RectangleCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            if (value != null) {
                value = "[" + value + "]";
            }
            super.setValue(value);
        }
    }

    protected PointCellRenderer _pointRenderer = new PointCellRenderer();

    protected RectangleCellRenderer _rectangleRenderer = new RectangleCellRenderer();
}
