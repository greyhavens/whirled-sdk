//
// $Id$

package com.whirled.remix.client;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.TableModel;

import com.samskivert.swing.GroupLayout;
import com.samskivert.swing.VGroupLayout;

import com.whirled.remix.data.EditableDataPack;

public class RemixingPanel extends JPanel
{
    public RemixingPanel (EditableDataPack pack)
    {
        super(new VGroupLayout(VGroupLayout.STRETCH));

        add(new JLabel("Data"), VGroupLayout.FIXED);
        _dataTable = createDataTable(pack);
        add(new JScrollPane(_dataTable));


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

    /** The table editing the data fields. */
    protected JTable _dataTable;
}
