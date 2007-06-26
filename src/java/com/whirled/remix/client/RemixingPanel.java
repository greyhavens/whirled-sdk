//
// $Id$

package com.whirled.remix.client;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTable;
import javax.swing.table.TableModel;

import com.samskivert.swing.GroupLayout;
import com.samskivert.swing.VGroupLayout;

import com.whirled.remix.data.EditableDataPack;

public class RemixingPanel extends JPanel
{
    public RemixingPanel (EditableDataPack pack)
    {
        super(new VGroupLayout(
            VGroupLayout.STRETCH, VGroupLayout.STRETCH, 5, //VGroupLayout.DEFAULT_GAP,
            VGroupLayout.CENTER));

        _pack = pack;

        add(new JLabel("Data"), VGroupLayout.FIXED);
        _dataTable = createDataTable(pack);
        add(new JScrollPane(_dataTable));
        addDataControls();

        add(new JSeparator(), VGroupLayout.FIXED);

        add(new JLabel("Files"), VGroupLayout.FIXED);
        _fileTable = createFileTable(pack);
        add(new JScrollPane(_fileTable));
        addFileControls();

        JPanel buttonPan = GroupLayout.makeButtonBox(GroupLayout.CENTER);
        JButton ok = new JButton("OK");
        buttonPan.add(ok);

        add(buttonPan, VGroupLayout.FIXED);
    }

    /**
     * Create the table model to use for the data elements.
     */
    protected JTable createDataTable (EditableDataPack pack)
    {
        return new RemixingDataTable(pack);
    }

    /**
     * Create the table model to use for the file elements.
     */
    protected JTable createFileTable (EditableDataPack pack)
    {
        return new RemixingFileTable(pack);
    }

    /**
     * Add any controls related to the data fields.
     */
    protected void addDataControls ()
    {
        // nada
    }

    /**
     * Add any controls related to the file fields.
     */
    protected void addFileControls ()
    {
        // nada
    }

    /** The DataPack we're editing. */
    protected EditableDataPack _pack;

    /** The table editing the data fields. */
    protected JTable _dataTable;

    /** The table editing the file fields. */
    protected JTable _fileTable;
}
