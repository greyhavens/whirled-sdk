package com.whirled.contrib.core.util {
    
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * Utility for image manipulation. 
 * Most of the ColorMatrixFilter transform code is adapted from TweenFilterLite, which came with the following license notice:
 * CODED BY: Jack Doyle, jack@greensock.com
 * Copyright 2007, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
 */
public class ImageTool
{
    public static function createTintTransform (rgbTint :uint, amount :Number = 1.0) :Array
    {
        // separate tintColor into its ARGB components
        var r :Number = Number((rgbTint >> 16) & 0x000000FF) / Number(255);
        var g :Number = Number((rgbTint >> 8) & 0x000000FF) / Number(255);
        var b :Number = Number(rgbTint & 0x000000FF) / Number(255);
        
        var opp :Number = 1.0 - amount;
        
        return [
            opp + amount * r * LUM_R,       amount * r * LUM_G,       amount * r * LUM_B, 0, 0,
                  amount * g * LUM_R, opp + amount * g * LUM_G,       amount * g * LUM_B, 0, 0,
                  amount * b * LUM_R,       amount * b * LUM_G, opp + amount * b * LUM_B, 0, 0,
                                   0,                        0,                        0, 1, 0,
        ];
    }
    
    public static function createTintFilter (rgbTint :uint) :ColorMatrixFilter
    {
        return new ColorMatrixFilter(createTintTransform(rgbTint));
    }
    
    public static function createTintedBitmap (srcBitmap :Bitmap, rgbTint :uint) :Bitmap
    {
        var tintData :BitmapData = new BitmapData(srcBitmap.width, srcBitmap.height, true, 0);
        var tintFilter :ColorMatrixFilter = createTintFilter(rgbTint);

        tintData.applyFilter(
            srcBitmap.bitmapData,
            new Rectangle(0, 0, srcBitmap.width, srcBitmap.height),
            new Point(0, 0),
            tintFilter);

        return new Bitmap(tintData);
    }
    
    public static function createThresholdTransform (n :Number) :Array 
    {
        return [
            LUM_R * 256, LUM_G * 256, LUM_B * 256, 0,  -256 * n, 
            LUM_R * 256, LUM_G * 256, LUM_B * 256, 0,  -256 * n, 
            LUM_R * 256, LUM_G * 256, LUM_B * 256, 0,  -256 * n, 
                      0,           0,           0, 1,         0
        ]; 
    }
    
    public static function createHueTransform (n :Number) :Array 
    {
        n *= Math.PI / 180;
        var c :Number = Math.cos(n);
        var s :Number = Math.sin(n);
        
        return [
            (LUM_R + (c * (1 - LUM_R))) + (s * (-LUM_R)), (LUM_G + (c * (-LUM_G))) + (s * (-LUM_G)), (LUM_B + (c * (-LUM_B))) + (s * (1 - LUM_B)), 0, 0, 
            (LUM_R + (c * (-LUM_R))) + (s * 0.143), (LUM_G + (c * (1 - LUM_G))) + (s * 0.14), (LUM_B + (c * (-LUM_B))) + (s * -0.283), 0, 0, 
            (LUM_R + (c * (-LUM_R))) + (s * (-(1 - LUM_R))), (LUM_G + (c * (-LUM_G))) + (s * LUM_G), (LUM_B + (c * (1 - LUM_B))) + (s * LUM_B), 0, 0, 
            0, 0, 0, 1, 0
        ];
        
    }
    
    public static function createBrightnessTransform (n :Number) :Array 
    {
        n = (n * 100) - 100;
        
        return [
            1, 0, 0, 0, n,
            0, 1, 0, 0, n,
            0, 0, 1, 0, n,
            0, 0, 0, 1, 0,
            0, 0, 0, 0, 1
        ];
    }
    
    public static function createSaturationTransform (n :Number) :Array 
    {
        var inv :Number = 1 - n;
        var r :Number = inv * LUM_R;
        var g :Number = inv * LUM_G;
        var b :Number = inv * LUM_B;
        
        return [
            r + n, g    , b    , 0, 0,
            r    , g + n, b    , 0, 0,
            r    , g    , b + n, 0, 0,
            0    , 0    , 0    , 1, 0
        ];
    }
    
    public static function createContrastTransform (n :Number) :Array 
    {
        n += 0.01;
        
        return [
            n, 0, 0, 0, 128 * (1 - n),
            0, n, 0, 0, 128 * (1 - n),
            0, 0, n, 0, 128 * (1 - n),
            0, 0, 0, 1, 0
        ];
    }
    
    protected static const LUM_R :Number = 0.212671;
    protected static const LUM_G :Number = 0.715160;
    protected static const LUM_B :Number = 0.072169;
}

}