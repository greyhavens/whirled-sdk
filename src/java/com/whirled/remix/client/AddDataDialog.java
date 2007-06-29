//
// $Id$

package com.whirled.remix.client;

import java.awt.Color;

import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;

import javax.swing.Action;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import com.samskivert.util.StringUtil;

import com.whirled.remix.data.EditableDataPack;

public class AddDataDialog extends AbstractAddDialog
{
    public AddDataDialog (JComponent host, EditableDataPack pack, Action popupAction)
    {
        super(host, pack, popupAction);
        setTitle("Add new data field");
    }

    @Override
    protected void createContent (JPanel panel)
    {
        super.createContent(panel);

        for (EditableDataPack.DataType type : EditableDataPack.DataType.values()) {
            if (type != EditableDataPack.DataType.UNKNOWN_TYPE) {
                _type.addItem(type);
            }
        }
    }

    // from AbstractAddDialog
    protected void createRow ()
    {
        _pack.addData(_name.getText().trim(), (EditableDataPack.DataType) _type.getSelectedItem(),
            null, _desc.getText().trim(), true);
    }

    // from AbstractAddDialog
    protected boolean areFieldsValid ()
    {
        String name = _name.getText().trim();
        boolean nameOK = !StringUtil.isBlank(name) && (null == _pack.getDataEntry(name));
        boolean descOK = !StringUtil.isBlank(_desc.getText());
        boolean typeOK = null != _type.getSelectedItem();

        _name.setForeground(nameOK ? Color.BLACK : Color.RED);

        return nameOK && typeOK && descOK;
    }
}
