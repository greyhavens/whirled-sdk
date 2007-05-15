//
// $Id$

package com.whirled.client;

import java.awt.BorderLayout;
import java.awt.EventQueue;
import java.io.FileReader;
import javax.swing.JComponent;
import javax.swing.JPanel;

import com.samskivert.util.Config;
import com.samskivert.util.RunQueue;
import com.threerings.util.KeyDispatcher;
import com.threerings.util.MessageManager;

import com.threerings.media.FrameManager;
import com.threerings.media.ManagedJFrame;
import com.threerings.media.image.ImageManager;
import com.threerings.media.sound.SoundManager;
import com.threerings.media.tile.TileManager;
import com.threerings.resource.ResourceManager;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;

import com.threerings.ezgame.data.EZGameConfig;
import com.threerings.parlor.client.ParlorDirector;
import com.threerings.toybox.client.ToyBoxDirector;

import com.whirled.util.WhirledContext;
import com.whirled.xml.WhirledGameParser;

import static com.whirled.Log.log;

/**
 * Provides the necessary framework and classloading for the Java game test client.
 */
public class WhirledClient
    implements RunQueue
{
    /**
     * Initializes a new client and provides it with a frame in which to display everything.
     */
    public void init (ManagedJFrame frame, final String gameId)
        throws Exception
    {
        // create our context
        _ctx = createContextImpl();

        // create the directors/managers/etc. provided by the context
        createContextServices();

        // keep this for later
        _frame = frame;
        _keydisp = new KeyDispatcher(_frame);

        // stuff our top-level pane into the top-level of our shell
        _frame.setContentPane(_root);

        _client.addClientObserver(new ClientAdapter() {
            public void clientDidLogon (Client client) {
                startTestGame(gameId);
            }
        });
    }

    /**
     * Returns a reference to the context in effect for this client. This reference is valid for
     * the lifetime of the application.
     */
    public WhirledContext getContext ()
    {
        return _ctx;
    }

    /**
     * Sets the main user interface panel.
     */
    public void setMainPanel (JComponent panel)
    {
        // remove the old panel
        _root.removeAll();
	// add the new one
	_root.add(panel, BorderLayout.CENTER);
        // swing doesn't properly repaint after adding/removing children
        _root.revalidate();
        _root.repaint();
    }

    // documentation inherited from interface RunQueue
    public void postRunnable (Runnable run)
    {
        // queue it on up on the awt thread
        EventQueue.invokeLater(run);
    }

    // documentation inherited from interface RunQueue
    public boolean isDispatchThread ()
    {
        return EventQueue.isDispatchThread();
    }

    /**
     * Called once we're logged on to start up the test game.
     */
    protected void startTestGame (String gameId)
    {
        // parse the game definition
        EZGameConfig config;
        try {
            WhirledGameParser parser = new WhirledGameParser();
            config = new EZGameConfig(
                -1, parser.parseGame(new FileReader(gameId + ".xml")));
        } catch (Exception e) {
            log.warning("Failed to start test game: " + e);
            System.exit(0);
            return; // not reached
        }

        _ctx.getParlorDirector().startSolitaire(config, new InvocationService.ConfirmListener() {
            public void requestProcessed () {
                // nothing needed
            }
            public void requestFailed (String cause) {
                log.warning("Failed to start test game: " + cause);
                System.exit(0);
            }
        });
    }

    /**
     * Creates the {@link WhirledContext} implementation that will be passed around to all of the
     * client code. Derived classes may wish to override this and create some extended context
     * implementation.
     */
    protected WhirledContext createContextImpl ()
    {
        return new WhirledContextImpl();
    }

    /**
     * Creates and initializes the various services that are provided by the context. Derived
     * classes that provide an extended context should override this method and create their own
     * extended services. They should be sure to call <code>super.createContextServices</code>.
     */
    protected void createContextServices ()
        throws Exception
    {
        // create the handles on our various services
        _client = new Client(null, this);

        // create our managers
        _rsrcmgr = new ResourceManager("rsrc");
        _msgmgr = new MessageManager(MESSAGE_MANAGER_PREFIX);
        _imgmgr = new ImageManager(_rsrcmgr, _frame);
        _tilemgr = new TileManager(_imgmgr);
        _sndmgr = new SoundManager(_rsrcmgr);

        // and our directors
        _locdir = new LocationDirector(_ctx);
        _occdir = new OccupantDirector(_ctx);
        _chatdir = new ChatDirector(_ctx, _msgmgr, "TODO");
        _pardtr = new ParlorDirector(_ctx);
    }

    /**
     * The context implementation. This provides access to all of the objects and services that are
     * needed by the operating client.
     */
    protected class WhirledContextImpl extends WhirledContext
    {
        /**
         * Apparently the default constructor has default access, rather than protected access,
         * even though this class is declared to be protected. Why, I don't know, but we need to be
         * able to extend this class elsewhere, so we need this.
         */
        protected WhirledContextImpl () {
        }

        public Client getClient () {
            return _client;
        }

        public DObjectManager getDObjectManager () {
            return _client.getDObjectManager();
        }

        public Config getConfig () {
            return _config;
        }

        public ResourceManager getResourceManager () {
            return _rsrcmgr;
        }

        public LocationDirector getLocationDirector () {
            return _locdir;
        }

        public OccupantDirector getOccupantDirector () {
            return _occdir;
        }

        public ChatDirector getChatDirector () {
            return _chatdir;
        }

        public ParlorDirector getParlorDirector () {
            return _pardtr;
        }

        public void setPlaceView (PlaceView view) {
            setMainPanel((JComponent)view);
        }

        public void clearPlaceView (PlaceView view) {
            // we'll just let the next place view replace our old one
        }

        public MessageManager getMessageManager () {
            return _msgmgr;
        }

        public ToyBoxDirector getToyBoxDirector () {
            throw new RuntimeException("ToyBoxDirector is not supported in Whirled.");
        }

        public FrameManager getFrameManager () {
            return _frame.getFrameManager();
        }

        public KeyDispatcher getKeyDispatcher () {
            return _keydisp;
        }

        public ImageManager getImageManager () {
            return _imgmgr;
        }

        public TileManager getTileManager () {
            return _tilemgr;
        }

        public SoundManager getSoundManager () {
            return _sndmgr;
        }
    }

    protected WhirledContext _ctx;
    protected ManagedJFrame _frame;
    protected JPanel _root = new JPanel(new BorderLayout()); // TODO?
    protected Config _config = new Config("toybox");

    protected Client _client;
    protected ResourceManager _rsrcmgr;
    protected MessageManager _msgmgr;
    protected KeyDispatcher _keydisp;

    protected ImageManager _imgmgr;
    protected TileManager _tilemgr;
    protected SoundManager _sndmgr;

    protected LocationDirector _locdir;
    protected OccupantDirector _occdir;
    protected ChatDirector _chatdir;
    protected ParlorDirector _pardtr;

    /** The prefix prepended to localization bundle names before looking them up in the
     * classpath. */
    protected static final String MESSAGE_MANAGER_PREFIX = "rsrc.i18n";
}
