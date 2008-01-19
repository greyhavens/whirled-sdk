package com.whirled.contrib.core.util {
    
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
    
public class ImageTool
{
    public static function createTintFilter (rgbTint :uint) :ColorMatrixFilter
    {
        // separate tintColor into its ARGB components
        var r :Number = Number((rgbTint >> 16) & 0x000000FF) / Number(255);
        var g :Number = Number((rgbTint >> 8) & 0x000000FF) / Number(255);
        var b :Number = Number(rgbTint & 0x000000FF) / Number(255);

        // build the matrix
        var mat :Array = [
            r, 0, 0, 0, 0,
            0, g, 0, 0, 0,
            0, 0, b, 0, 0,
            0, 0, 0, 1, 0
        ];
        
        return new ColorMatrixFilter(mat);
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
}

}