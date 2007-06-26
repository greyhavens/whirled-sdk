//
// $Id$

package com.whirled.remix.client;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;

import com.samskivert.swing.GroupLayout;
import com.samskivert.swing.JInternalDialog;

import com.whirled.remix.data.EditableDataPack;

public abstract class AbstractAddDialog extends JInternalDialog
{
    public AbstractAddDialog (JComponent host, EditableDataPack pack, Action popupAction)
    {
        super(host);
        _pack = pack;
        _popupAction = popupAction;

        setClosable(true);
        setResizable(true);

        // create the buttons to close us..
        JPanel butbox = GroupLayout.makeButtonBox(GroupLayout.CENTER);
        butbox.add(new JButton(_okAction = new AbstractAction("Ok") {
            public void actionPerformed (ActionEvent event) {
                createRow();
                dispose();
            }
        }));
        _okAction.setEnabled(false);
        butbox.add(new JButton(new AbstractAction("Cancel") {
            public void actionPerformed (ActionEvent event) {
                dispose();
            }
        }));

        // make a panel to hold everything
        JPanel panel = GroupLayout.makeVBox();
        // allow it to be populated by a subclass
        createContent(panel);
        // add the buttons
        panel.add(butbox);
        add(panel);

        setLayer(JLayeredPane.MODAL_LAYER);
        pack();
        showDialog();
    }

    @Override
    public void dispose ()
    {
        super.dispose();
        _popupAction.setEnabled(true);
    }

    /**
     * Called to add the components of the add dialog.
     */
    protected abstract void createContent (JPanel panel);

    /**
     * Actually create the new rom of data, after OK is pressed.
     */
    protected abstract void createRow ();

    protected EditableDataPack _pack;

    protected Action _okAction;

    protected Action _popupAction;
}
