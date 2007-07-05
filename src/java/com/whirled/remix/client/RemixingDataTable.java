//
// $Id$

package com.whirled.remix.client;

import java.awt.Component;

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import java.util.EventObject;

import javax.swing.DefaultCellEditor;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JPanel;
import javax.swing.JTable;
import javax.swing.JTextField;
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
        case RemixingDataModel.DEFAULT_COL:
            EditableDataPack.DataType type = (EditableDataPack.DataType)
                getModel().getValueAt(row, RemixingDataModel.TYPE_COL);
            switch (type) {
            default:
                return super.getCellRenderer(row, column);

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
        case RemixingDataModel.DEFAULT_COL:
            EditableDataPack.DataType type = (EditableDataPack.DataType)
                getModel().getValueAt(row, RemixingDataModel.TYPE_COL);
            switch (type) {
            default:
                return super.getCellEditor(row, column);

            case BOOLEAN:
                return _booleanEditor;

            case POINT:
                return _pointEditor;

            case RECTANGLE:
                return _rectangleEditor;
            }
        }
    }

    // from AbstractTable
    protected AbstractModel createModel (EditableDataPack pack)
    {
        return new RemixingDataModel(pack);
    }

    protected static class DataCellEditor extends DefaultCellEditor
    {
        public DataCellEditor ()
        {
            super(new JTextField());
        }

        @Override
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int col)
        {
            _origValue = value;
            if (value != null) {
                value = formatValue(value);
            }
            return super.getTableCellEditorComponent(table, value, isSelected, row, col);
        }

        @Override
        public Object getCellEditorValue ()
        {
            try {
                return parseValue((String) super.getCellEditorValue());
            } catch (Exception e) {
                return _origValue;
            }
        }

        /**
         * Format the objecty value into a String.
         */
        protected String formatValue (Object value)
        {
            return String.valueOf(value);
        }

        /**
         * Parse the stringy value.
         */
        protected Object parseValue (String value)
            throws Exception
        {
            return value;
        }

        /** The original value. */
        protected Object _origValue;
    }

    protected static class PointCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            super.setValue(PointCellEditor.format(value));
        }
    }

    protected static class PointCellEditor extends DataCellEditor
    {
        public static String format (Object value)
        {
            if (value == null) {
                return null;
            }

            Point2D.Double p = (Point2D.Double) value;
            return p.getX() + ", " + p.getY();
        }

        protected String formatValue (Object value)
        {
            return format(value);
        }

        protected Object parseValue (String value)
            throws Exception
        {
            String[] arr = value.split(",");
            if (arr.length != 2) {
                throw new Exception();
            }
            return new Point2D.Double(Double.parseDouble(arr[0].trim()),
                Double.parseDouble(arr[1].trim()));
        }
    }

    protected static class RectangleCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            super.setValue(RectangleCellEditor.format(value));
        }
    }

    protected static class RectangleCellEditor extends DataCellEditor
    {
        public static String format (Object value)
        {
            if (value == null) {
                return null;
            }

            Rectangle2D.Double r = (Rectangle2D.Double) value;
            return r.getX() + ", " + r.getY() + ", " + r.getWidth() + ", " + r.getHeight();
        }

        protected String formatValue (Object value)
        {
            return format(value);
        }

        protected Object parseValue (String value)
            throws Exception
        {
            String[] arr = value.split(",");
            if (arr.length != 4) {
                throw new Exception();
            }
            return new Rectangle2D.Double(Double.parseDouble(arr[0].trim()),
                Double.parseDouble(arr[1].trim()),
                Double.parseDouble(arr[2].trim()),
                Double.parseDouble(arr[3].trim()));
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

            _box.setText(String.valueOf(value));
            _box.setBorderPainted(true);
            return super.getTableCellEditorComponent(table, value, isSelected, row, column);
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
    protected PointCellEditor _pointEditor = new PointCellEditor();

    protected RectangleCellRenderer _rectangleRenderer = new RectangleCellRenderer();
    protected RectangleCellEditor _rectangleEditor = new RectangleCellEditor();

    protected BooleanEditor _booleanEditor = new BooleanEditor();
}
