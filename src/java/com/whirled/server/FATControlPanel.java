//
// $Id$
//
// Copyright (c) 2007-2011 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import java.io.File;
import java.io.Reader;
import java.io.StringReader;

import java.awt.EventQueue;
import java.awt.Font;
import java.awt.event.ActionEvent;

import javax.swing.Action;
import javax.swing.AbstractAction;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JSlider;
import javax.swing.JTextArea;

import org.apache.commons.io.FileUtils;

import com.google.inject.Guice;
import com.google.inject.Injector;

import com.samskivert.util.PrefsConfig;
import com.samskivert.util.StringUtil;

import com.samskivert.swing.GroupLayout;
import com.samskivert.swing.SimpleSlider;
import com.samskivert.swing.Spacer;
import com.samskivert.swing.VGroupLayout;
import com.samskivert.swing.util.SwingUtil;

import com.whirled.server.WhirledTestServer;

import static com.whirled.Log.log;

/**
 * Displays the FAT server control panel.
 */
public class FATControlPanel extends JFrame
{
    public static void main (String[] args)
    {
        // create and display our panel
        FATControlPanel panel = new FATControlPanel();
        panel.pack();
        SwingUtil.centerWindow(panel);
        panel.setVisible(true);
        panel.checkPlayerPath();
    }

    protected FATControlPanel ()
    {
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        JPanel panel = new JPanel(new VGroupLayout(VGroupLayout.NONE, VGroupLayout.STRETCH,
                                                   5, VGroupLayout.TOP));
        panel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        JLabel title = new JLabel("Whirled Test Environment");
        title.setFont(new Font("Dialog", Font.PLAIN, 18));
        title.setHorizontalAlignment(JLabel.CENTER);
        panel.add(title);

        JPanel swfctrl = GroupLayout.makeHStretchBox(5);
        swfctrl.add(new JLabel("Game SWF:"), GroupLayout.FIXED);
        swfctrl.add(_curswf = new JLabel("<unset>"));
        swfctrl.add(new JButton(_changeSWF), GroupLayout.FIXED);
        panel.add(swfctrl);

        panel.add(new JLabel("Config:"));
        panel.add(_gconfig = new JTextArea("", 5, 40));

        SimpleSlider slider = new SimpleSlider("Players:", 1, 8, 1);
        panel.add(slider);
        _players = slider.getSlider();

        panel.add(_status = new JLabel("..."));

        JPanel buttons = GroupLayout.makeHStretchBox(5);
        buttons.add(new JButton(_exitA), GroupLayout.FIXED);
        buttons.add(new JButton(_configA), GroupLayout.FIXED);
        buttons.add(new Spacer(1, 1));
        buttons.add(new JButton(_startA), GroupLayout.FIXED);
        panel.add(buttons);

        setContentPane(panel);

        // set up our configuration if we have one
        String swfpath = _prefs.getValue("fat.swfpath", "");
        if (!StringUtil.isBlank(swfpath)) {
            selectGameSWF(new File(swfpath));
        }
        _gconfig.setText(_prefs.getValue("fat.config", ""));
    }

    protected void checkPlayerPath ()
    {
        // make sure our projector path is configured
        if (StringUtil.isBlank(_prefs.getValue("fat.playerpath", ""))) {
            _configA.actionPerformed(null);
        }
    }

    protected void selectGameSWF (File path)
    {
        _swfpath = path;
        _curswf.setText(_swfpath.getName());
        _prefs.setValue("fat.swfpath", _swfpath.getAbsolutePath());
    }

    protected void startServer ()
    {
        // save our current configuration
        _prefs.setValue("fat.config", _gconfig.getText());

        // copy the latest SWF into place
        File target = new File("dist" + File.separator + "game.swf");
        try {
            FileUtils.copyFile(_swfpath, target);
        } catch (Exception e) {
            _status.setText("Failed to copy SWF (" + _swfpath + "): " + e.getMessage());
            log.warning("Failed to copy " + _swfpath + " to " + target + ".", e);
            return;
        }

        // prepare the server
        final FATServer server = _injector.getInstance(FATServer.class);
        try {
            server.init(_injector, _gconfig.getText(), _players.getValue(),
                _prefs.getValue("fat.playerpath", "flashplayer"), _status);
        } catch (Exception e) {
            log.warning("Unable to initialize server.", e);
            _status.setText("Unable to initialize server: " + e.getMessage());
            return;
        }

        // disable the start button as we're good to go
        _startA.setEnabled(false);
        _status.setText("Server running. Close all clients to end.");

        // start up the server which will handle everything else
        new Thread("WhirledTestServer") {
            public void run () {
                server.run();
                EventQueue.invokeLater(new Runnable() {
                    public void run () {
                        serverDidExit();
                    }
                });
            }
        }.start();
    }

    protected void serverDidExit ()
    {
        _startA.setEnabled(true);
        _status.setText("Ready...");
    }

    protected Action _startA = new AbstractAction("Start") {
        public void actionPerformed (ActionEvent e) {
            startServer();
        }
    };

    protected Action _exitA = new AbstractAction("Exit") {
        public void actionPerformed (ActionEvent e) {
            System.exit(0);
        }
    };

    protected Action _configA = new AbstractAction("Config") {
        public void actionPerformed (ActionEvent e) {
            JFileChooser chooser = new JFileChooser(_prefs.getValue("fat.playerpath", ""));
            chooser.setDialogTitle("Where is your Flash Projector?");
            if (chooser.showOpenDialog(FATControlPanel.this) == JFileChooser.APPROVE_OPTION) {
                _prefs.setValue("fat.playerpath", chooser.getSelectedFile().getAbsolutePath());
            }
        }
    };

    protected Action _changeSWF = new AbstractAction("Change...") {
        public void actionPerformed (ActionEvent e) {
            JFileChooser chooser = new JFileChooser(_swfpath);
            if (chooser.showOpenDialog(FATControlPanel.this) == JFileChooser.APPROVE_OPTION) {
                selectGameSWF(chooser.getSelectedFile());
            }
        }
    };

    protected PrefsConfig _prefs = new PrefsConfig("whirled");

    protected JLabel _status;
    protected JLabel _curswf;
    protected JTextArea _gconfig;
    protected JSlider _players;

    protected File _swfpath = new File("");

    protected Injector _injector = Guice.createInjector(new WhirledTestServer.Module());

    protected static class FATServer extends WhirledTestServer
    {
        public void init (Injector injector, String params, int playerCount,
                          String playerPath, JLabel status)
            throws Exception
        {
            _params = params;
            _playerCount = playerCount;
            _playerPath = playerPath;
            _status = status;
            
            super.init(injector);
        }
        @Override protected boolean hasServerSideCode () {
            return false;
        }
        @Override protected String getDocRoot () {
            return "dist";
        }
        @Override protected Reader getGameConfig () {
            String config = "<game><params>" + _params + "</params></game>";
            return new StringReader(config);
        }
        @Override protected int getPlayerCount () {
            return _playerCount;
        }
        @Override protected String getFlashPlayerPath () {
            return _playerPath;
        }
        @Override protected void reportError (String message, Exception e) {
            log.warning(message, e);
            _status.setText(message);
        }
        
        protected String _params;
        protected int _playerCount;
        protected String _playerPath;
        protected JLabel _status;
    }
}
