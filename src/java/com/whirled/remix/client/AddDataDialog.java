//
// $Id$

package com.whirled.remix.client;

import java.awt.Color;

import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.Action;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import com.samskivert.swing.Spacer;

import com.samskivert.swing.event.DocumentAdapter;

import com.samskivert.util.StringUtil;

import com.whirled.remix.data.EditableDataPack;

public class AddDataDialog extends AbstractAddDialog
{
    public AddDataDialog (JComponent host, EditableDataPack pack, Action popupAction)
    {
        super(host, pack, popupAction);
        setTitle("Add new data field");
    }

    // from AbstractAddDialog
    protected void createContent (JPanel panel)
    {
        // configure layout constraints..
        JPanel grid = new JPanel(new GridBagLayout());
        GridBagConstraints c1 = new GridBagConstraints();
        c1.gridx = 0;
        c1.anchor = GridBagConstraints.NORTHWEST;
        GridBagConstraints c2 = new GridBagConstraints();
        c2.gridx = 1;
        c2.gridwidth = GridBagConstraints.REMAINDER;
        c2.anchor = GridBagConstraints.NORTHWEST;
        panel.add(grid);

        // add the widgets
        grid.add(new JLabel("name:"), c1);
        grid.add(_name = new JTextField(12), c2);

        grid.add(new JLabel("type:"), c1);
        grid.add(_type = new JComboBox(), c2);

        grid.add(new Spacer(1, 1), c1);
        grid.add(_typeLabel = new JLabel(), c2);

        grid.add(new JLabel("description:"), c1);
        grid.add(_desc = new JTextField(20), c2);

        // configure the behavior of the widgets
        DocumentAdapter docValidate = new DocumentAdapter() {
            @Override
            public void documentChanged () {
                validateData();
            }
        };
        _name.getDocument().addDocumentListener(docValidate);
        _desc.getDocument().addDocumentListener(docValidate);

        _type.setEditable(false);
        _type.addActionListener(new ActionListener() {
            public void actionPerformed (ActionEvent event) {
                validateData();

                EditableDataPack.DataType type =
                    (EditableDataPack.DataType) _type.getSelectedItem();
                _typeLabel.setText(type.getDescription());
            }
        });
        for (EditableDataPack.DataType type : EditableDataPack.DataType.values()) {
            if (type != EditableDataPack.DataType.UNKNOWN_TYPE) {
                _type.addItem(type);
            }
        }

        // finally, validate everything
        validateData();
    }

    // from AbstractAddDialog
    protected void createRow ()
    {
        _pack.addData(_name.getText().trim(), (EditableDataPack.DataType) _type.getSelectedItem(),
            null, _desc.getText().trim(), true);
    }

    protected void validateData ()
    {
        _okAction.setEnabled(areFieldsValid());
    }

    /**
     * Are all the configured fields valid?
     */
    protected boolean areFieldsValid ()
    {
        String name = _name.getText().trim();
        boolean nameOK = !StringUtil.isBlank(name) && (null == _pack.getDataEntry(name));
        boolean descOK = !StringUtil.isBlank(_desc.getText());
        boolean typeOK = (_type.getSelectedItem() != null);

        _name.setForeground(nameOK ? Color.BLACK : Color.RED);

        return nameOK && typeOK && descOK;
    }

    protected JTextField _name;
    protected JComboBox _type;
    protected JTextField _desc;
    protected JLabel _typeLabel;
}
