package com.whirled.contrib.core.util {
    
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
    
public class ImageTool
{
    public static function createTintFilter (argbTint :uint) :ColorMatrixFilter
    {
        // separate tintColor into its ARGB components
        var a :Number = Number((argbTint >> 24) & 0x000000FF) / Number(255);
        var r :Number = Number((argbTint >> 16) & 0x000000FF) / Number(255);
        var g :Number = Number((argbTint >> 8) & 0x000000FF) / Number(255);
        var b :Number = Number(argbTint & 0x000000FF) / Number(255);

        // build the matrix
        var mat :Array = [
            r, 0, 0, 0, 0,
            0, g, 0, 0, 0,
            0, 0, b, 0, 0,
            0, 0, 0, a, 0
        ];
        
        return new ColorMatrixFilter(mat);
    }
    
    public static function createTintedBitmap (srcBitmap :Bitmap, argbTint :uint) :Bitmap
    {
        var tintData :BitmapData = new BitmapData(srcBitmap.width, srcBitmap.height, true, 0);
        var tintFilter :ColorMatrixFilter = createTintFilter(argbTint);

        tintData.applyFilter(
            srcBitmap.bitmapData,
            new Rectangle(0, 0, srcBitmap.width, srcBitmap.height),
            new Point(0, 0),
            tintFilter);

        return new Bitmap(tintData);
    }
}

}