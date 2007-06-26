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

public class AddFileDialog extends AbstractAddDialog
{
    public AddFileDialog (JComponent host, EditableDataPack pack, Action popupAction)
    {
        super(host, pack, popupAction);
        setTitle("Add new file field");
    }

    @Override
    protected void createContent (JPanel panel)
    {
        super.createContent(panel);

        for (EditableDataPack.FileType type : EditableDataPack.FileType.values()) {
            if (type != EditableDataPack.FileType.UNKNOWN_TYPE) {
                _type.addItem(type);
            }
        }
    }

    // from AbstractAddDialog
    protected void createRow ()
    {
        // TODO
        String name = _name.getText().trim();
        _pack.addFile(name, null, name, (EditableDataPack.FileType) _type.getSelectedItem(),
            _desc.getText().trim(), true);
    }

    // from AbstractAddDialog
    protected boolean areFieldsValid ()
    {
        String name = _name.getText().trim();
        boolean nameOK = !StringUtil.isBlank(name) && (null == _pack.getFileEntry(name));
        boolean descOK = !StringUtil.isBlank(_desc.getText());
        boolean typeOK = (_type.getSelectedItem() != null);

        _name.setForeground(nameOK ? Color.BLACK : Color.RED);

        return nameOK && typeOK && descOK;
    }
}
