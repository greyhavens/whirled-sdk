//
// $Id$

package com.whirled.remix.client;

import java.awt.Component;

import javax.swing.AbstractCellEditor;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JTable;

import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.TableCellEditor;
import javax.swing.table.TableCellRenderer;
import javax.swing.table.TableModel;

import com.samskivert.swing.GroupLayout;
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

        case AbstractModel.TYPE_COL:
            return getDefaultRenderer(String.class);

        case AbstractModel.ACTIONS_COL:
            return _actionRenderer;

        case AbstractModel.OPTIONAL_COL:
            return getDefaultRenderer(Boolean.class);
        }
    }

    @Override
    public TableCellEditor getCellEditor (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        case AbstractModel.ACTIONS_COL:
            return _actionRenderer;

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
    protected static class ActionCellRenderer extends AbstractCellEditor
        implements TableCellRenderer, TableCellEditor
    {
        public ActionCellRenderer ()
        {
            _comp = GroupLayout.makeButtonBox(GroupLayout.CENTER);
            _comp.add(new JButton("Revert"));
        }

        // from CellEditor
        public Object getCellEditorValue ()
        {
            return null;
        }

        // from TableCellEditor
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int col)
        {
            return _comp;
        }

        // from TableCellRenderer
        public Component getTableCellRendererComponent (
            JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int col)
        {
            return _comp;
        }

        protected JPanel _comp;
    }

    protected DecodingCellRenderer _decodingRenderer = new DecodingCellRenderer();

    protected ActionCellRenderer _actionRenderer = new ActionCellRenderer();
}
