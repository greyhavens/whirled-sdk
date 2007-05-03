//
// $Id$

package com.whirled.util;

import java.awt.image.BufferedImage;

import com.threerings.media.image.ImageManager;
import com.threerings.media.sound.SoundManager;
import com.threerings.media.tile.TileManager;

import com.threerings.toybox.util.ToyBoxContext;

/**
 * Extends the ToyBox context with Whirled bits.
 */
public abstract class WhirledContext extends ToyBoxContext
{
    /**
     * Provides image loading and caching.
     */
    public abstract ImageManager getImageManager ();

    /**
     * Provides tileset loading and caching.
     */
    public abstract TileManager getTileManager ();

    /**
     * Provides a means for loading and playing sounds.
     */
    public abstract SoundManager getSoundManager ();

    @Override // from ToyBoxContext
    public BufferedImage loadImage (String rsrcPath)
    {
        return getImageManager().getImage(rsrcPath);
    }
}
