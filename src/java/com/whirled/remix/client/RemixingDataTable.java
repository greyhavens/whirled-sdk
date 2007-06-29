//
// $Id$

package com.whirled.remix.client;

import java.awt.Component;

import java.util.EventObject;

import javax.swing.DefaultCellEditor;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JPanel;
import javax.swing.JTable;
import javax.swing.UIManager;

import javax.swing.border.Border;
import javax.swing.border.EmptyBorder;

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

        case RemixingDataModel.VALUE_COL:
            EditableDataPack.DataType type = (EditableDataPack.DataType)
                getModel().getValueAt(row, RemixingDataModel.TYPE_COL);
            switch (type) {
            default:
                return _decodingRenderer;

            case BOOLEAN:
                return _booleanEditor;

            case POINT:
                return _pointRenderer;

            case RECTANGLE:
                return _rectangleRenderer;
            }
        }
    }

    @Override
    public TableCellEditor getCellEditor (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellEditor(row, column);

        case RemixingDataModel.VALUE_COL:
            EditableDataPack.DataType type = (EditableDataPack.DataType)
                getModel().getValueAt(row, RemixingDataModel.TYPE_COL);
            switch (type) {
            default:
                return super.getCellEditor(row, column);

            case BOOLEAN:
                return _booleanEditor;
            }
        }
    }

    // from AbstractTable
    protected AbstractModel createModel (EditableDataPack pack)
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

    protected static class BooleanEditor extends DefaultCellEditor
        implements TableCellRenderer
    {
        public BooleanEditor () {
            super(new JCheckBox());
            _box = (JCheckBox) getComponent();
            _box.setHorizontalAlignment(JCheckBox.CENTER);
        }

        @Override
        public Object getCellEditorValue ()
        {
            // turn a Boolean into "true" or "false".
            return String.valueOf(super.getCellEditorValue());
        }

        public Component getTableCellRendererComponent (
            JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column)
        {
            if (isSelected) {
                _box.setForeground(table.getSelectionForeground());
                _box.setBackground(table.getSelectionBackground());
            } else {
                _box.setForeground(table.getForeground());
                _box.setBackground(table.getBackground());
            }
            if (hasFocus) {
                _box.setBorder(UIManager.getBorder("Table.focusCellHighlightBorder"));
            } else {
                _box.setBorder(_noFocusBorder);
            }

            String val = (String) value;
            _box.setText(val);
            _box.setBorderPainted(true);
            return super.getTableCellEditorComponent(
                table, Boolean.valueOf(val), isSelected, row, column);
        }

        @Override
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int column)
        {
            getTableCellRendererComponent(table, value, false, false, row, column);
            _box.setBorderPainted(false);
            return _box;
        }

// TODO: possibly make it harder to start editing. Right now a stray click toggles the value!
//        @Override
//        public boolean isCellEditable (EventObject anEvent)
//        {
//            System.err.println("an event is " + anEvent);
//            return super.isCellEditable(anEvent);
//        }

        protected JCheckBox _box;

        protected Border _noFocusBorder = new EmptyBorder(1, 1, 1, 1);
    }

    protected PointCellRenderer _pointRenderer = new PointCellRenderer();

    protected RectangleCellRenderer _rectangleRenderer = new RectangleCellRenderer();

    protected BooleanEditor _booleanEditor = new BooleanEditor();
}
