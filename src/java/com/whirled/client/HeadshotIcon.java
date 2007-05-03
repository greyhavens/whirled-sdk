//
// $Id$

package com.whirled.client;

import java.awt.Component;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Toolkit;
import javax.swing.Icon;

import java.net.URL;

import com.whirled.data.WhirledOccupantInfo;

import static com.whirled.Log.log;

/**
 * Displays an avatar's headshot as an icon.
 */
public class HeadshotIcon implements Icon
{
    /** The size of the icon. The headshot will be scaled and centered to fit. */
    public static final Dimension SIZE = new Dimension(64, 64);

    public HeadshotIcon (WhirledOccupantInfo info)
    {
        setInfo(info);
    }

    /**
     * Updates the headshot for this icon if it has changed.
     */
    public void setInfo (WhirledOccupantInfo info)
    {
        try {
            URL url = new URL(info.getHeadshotURL());
            if (_current != null && _current.equals(url)) {
                return;
            }
            _image = Toolkit.getDefaultToolkit().createImage(_current = url);
        } catch (Exception e) {
            log.warning("Invalid headshot URL [info=" + info + "].");
            return;
        }
    }

    // from interface Icon
    public void paintIcon (Component host, Graphics g, int x, int y)
    {
        int width = _image.getWidth(null);
        int height = _image.getHeight(null);
        if (_image == null || width <= 0 || height <= 0) {
            return;
        }

        float scale = (width > height) ? width/(float)SIZE.width : height/(float)SIZE.height;
        int swidth = (int)Math.round(SIZE.width * scale * width);
        int sheight = (int)Math.round(SIZE.height * scale * height);
        int sx = (SIZE.width - swidth)/2, sy = (SIZE.height - sheight)/2;
        g.drawImage(_image, sx, sy, swidth, sheight, null, host);
    }
    
    // from interface Icon
    public int getIconWidth ()
    {
        return SIZE.width;
    }

    // from interface Icon
    public int getIconHeight ()
    {
        return SIZE.height;
    }

    protected URL _current;
    protected Image _image;
}
