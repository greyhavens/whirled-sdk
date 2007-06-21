//
// $Id$

package com.whirled.remix.client;

import java.awt.Component;

import javax.swing.DefaultCellEditor;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JTable;

import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.TableCellEditor;
import javax.swing.table.TableCellRenderer;
import javax.swing.table.TableModel;

import com.samskivert.swing.HGroupLayout;
import com.samskivert.util.StringUtil;

import com.whirled.remix.data.EditableDataPack;

public abstract class AbstractTable extends JTable
{
    public AbstractTable (EditableDataPack pack)
    {
        setModel(createModel(pack));
    }

    @Override
    public TableCellRenderer getCellRenderer (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return _decodingRenderer;

        case RemixingDataModel.TYPE_COL:
            return getDefaultRenderer(String.class);

        case RemixingDataModel.ACTIONS_COL:
            return _actionRenderer;

        case RemixingDataModel.OPTIONAL_COL:
            return getDefaultRenderer(Boolean.class);
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

    /**
     * Create the table model to use.
     */
    protected abstract TableModel createModel (EditableDataPack pack);

    protected static class DecodingCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            super.setValue(StringUtil.decode((String) value));
        }
    }

    // TODO... will this work?
    protected static class ActionCellRenderer extends JPanel
        implements TableCellRenderer
    {
        public ActionCellRenderer ()
        {
            super(new HGroupLayout());
            add(new JButton("Revert"));
        }

        @Override
        public Component getTableCellRendererComponent (
            JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int col)
        {
            // TODO: dim buttons, etc.
            return this;
        }
    }

    protected DecodingCellRenderer _decodingRenderer = new DecodingCellRenderer();

    protected ActionCellRenderer _actionRenderer = new ActionCellRenderer();
}
