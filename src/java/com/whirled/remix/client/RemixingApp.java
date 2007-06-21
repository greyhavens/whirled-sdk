//
// $Id$

package com.whirled.remix.client;


import javax.swing.JFrame;

import com.samskivert.util.ResultListener;

import com.whirled.remix.data.EditableDataPack;

public class RemixingApp
{
    public static void main (String[] args)
    {
        new EditableDataPack(args[0], new ResultListener<EditableDataPack>() {
            public void requestCompleted (EditableDataPack pack) {
                JFrame frame = new JFrame("Remixing");
                frame.setContentPane(new RemixingPanel(pack));
                frame.pack();
                frame.setVisible(true);
            }

            public void requestFailed (Exception cause) {
                cause.printStackTrace();
                System.exit(1);
            }
        });
    }
}
