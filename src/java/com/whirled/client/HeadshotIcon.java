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
    public HeadshotIcon (WhirledOccupantInfo info, Dimension size)
    {
        this(info, size.width, size.height);
    }

    public HeadshotIcon (WhirledOccupantInfo info, int width, int height)
    {
        _width = width;
        _height = height;
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

        float scale = (width > height) ? _width/(float)width : _height/(float)height;
        scale = Math.min(1f, scale);
        int swidth = Math.round(scale * width);
        int sheight = Math.round(scale * height);
        int sx = (_width - swidth)/2, sy = (_height - sheight)/2;
        g.drawImage(_image, x + sx, y + sy, swidth, sheight, null, host);
    }
    
    // from interface Icon
    public int getIconWidth ()
    {
        return _width;
    }

    // from interface Icon
    public int getIconHeight ()
    {
        return _height;
    }

    protected int _width, _height;
    protected URL _current;
    protected Image _image;
}
