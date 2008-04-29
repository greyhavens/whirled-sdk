//
// $Id$

package com.whirled.contrib {

import flash.display.MovieClip;
import flash.geom.ColorTransform;

import com.threerings.flash.MathUtil;

/**
 * Various tools for converting between different color models and applying 
 * colors to Movie Clips. 
 * <p>The methods for changing the colors of Movie Clips change the entire Movie
 * clip to that color, it is not a tint. This is useful for Movie Clips that have 
 * re-colorable childs to easily change their color. Examples include balloons, game tokens 
 * and furniture items. </p>
 *
 * Author: jdnx429
 */
public class ColorConversion {
    /** 
     * Converts a color from the CMY color model to HSB. The values for cyan, magenta,
     * and yellow should be supplied in the range of 0.0 to 1.0. 
     * @param cyan the cyan value. 
     * @param magenta the magenta value.
     * @param yellow the yellow value
     *
     * @return an Array in the format [hue, saturation, brightness]. The range for hue is 
     * 0-360.  The range for saturation and brightness is 0.0-1.0
     */
    public static function CMYtoHSB (cyan :Number, magenta :Number, yellow :Number) :Array 
    {
        var red :Number = (1 - cyan) * 255;
        var green :Number = (1 - magenta) * 255;
        var blue :Number = (1 - yellow) * 255;
        var tempArray :Array = RGBtoHSB(red,green,blue);
        
        return tempArray;
    }

    /**
     * Converts a color from the RGB color model to HSB. The values for the arguments
     * should be supplied in the range of 0 to 255.
     * @param r the red value. 
     * @param g the green value.
     * @param b the blue value
     *
     * @return an Array in the format [hue, saturation, brightness]. The range for hue is 0-360.  
     * The range for saturation and brightness is 0.0-1.0
     */
    public static function RGBtoHSB (r :Number, g :Number, b :Number) :Array 
    {
        // red, green, blue values are given in 0-255
        // we normalize them to 0-1
        var red :Number = r / 255;
        var green :Number = g / 255;
        var blue :Number = b / 255;
        if (red < 0.001) {
            red=0;
        }
        if (green < 0.001) {
            green=0;
        }
        if (blue < 0.001) {
            blue=0;
        }

        var rgbArray :Array = [red, green, blue];
        rgbArray.sort(Array.DESCENDING);
        
        var max :Number = rgbArray[0];
        var min :Number = rgbArray[2];
        var hue :Number = 0;
        var sat :Number = 0;
        var bri :Number = 0;

        if ((max == red) && (green >= blue)) {
            hue = 60 * ((green-blue)/(max-min)) + 0;
        }
        if ((max == red) && (green < blue)) {
            hue = 60 * ((green-blue)/(max-min)) + 360;
        }
        if (max == green) {
            hue = 60 * ((blue-red)/(max-min)) + 120;
        }
        if ( max == blue ) {
            hue = 60 * ((red-green)/(max-min)) + 240;
        }
        if (max == min) {
            hue = 0;
        }
        if (max == 0 ) {
            sat = 0;
        } else {
            sat = 1-(min/max);
        }
        bri = max;
        
        return [hue, sat, bri];
    }

    /**
     * Converts a color from the HSB color model to RGB. The value for hue should be
     * in the range of 0-360. Sat and bri should be in the range of 0.0 to 1.0 
     * @param hue the hue of the color. 
     * @param sat the saturation value.
     * @param bri the brightness value.
     *
     * @return an Array in the format [red, green, blue]. The range for all is 0-255.  
     */
    public static function HSBtoRGB (hue :Number, sat :Number, bri :Number) :Array 
    {
        var red :Number = 0;
        var green :Number = 0;
        var blue :Number = 0;

        var huetype :int = Math.floor(hue / 60);
        var f :Number = hue / 60 - huetype;
        var p :Number = bri * (1 - sat);
        var q :Number = bri * (1 - f * sat);
        var t :Number = bri * (1 - (1 - f) * sat);

        switch (huetype) {
        case 0:
            red = bri;
            green = t;
            blue = p;
            break;

        case 1:
            red = q;
            green = bri;
            blue = p;
            break;

        case 2:
            red = p;
            green = bri;
            blue = t;
            break;

        case 3:
            red = p;
            green = q;
            blue = bri;
            break;

        case 4:
            red = t;
            green = p;
            blue = bri;
            break;

        case 5:
            red = bri;
            green = p;
            blue = q;
            break;
        }

        var redint :int = Math.round(255 * red);
        var greenint :int = Math.round(255 * green);
        var blueint :int = Math.round(255 * blue);
        return [redint, greenint, blueint];
    }

    protected static function HSBtoRGBMultAlpha (hue :Number, sat :Number, bri :Number) :Array 
    {
        var RGB :Array = HSBtoRGB(hue, sat, bri);
        var RGBMult :Array = [1, RGB[0] / 255, RGB[1] / 255, RGB[2] / 255];
        return RGBMult;
    }

    /**
     * Converts a color from the RGB color model to CMY. The values for the arguments should be
     * in the range of 0-255. 
     * @param red the red value.
     * @param green the green value.
     * @param blue the blue value.
     *
     * @return an Array in the format [cyan, magenta, yellow]. The range for all is 0-1.  
     */
    public static function RGBtoCMY (r :Number, g :Number, b :Number) :Array 
    {
        var cyan :Number = 1 - r / 255;
        var magenta :Number = 1 - g / 255;
        var yellow :Number = 1 - b / 255;
        return [cyan, magenta, yellow];
    }

    /**
     * Converts a color from the CMY color model to RGB. The values for the arguments should be
     * in the range of 0.0-1.0. 
     * @param cyan 
     * @param magenta
     * @param yellow
     *
     * @return an Array in the format [red, green, blue]. The range for all is 0-255.  
     */
    public static function CMYtoRGB (cyan :Number, magenta :Number, yellow :Number) :Array 
    {
        var red :Number = 255 * (1-cyan);
        var green :Number = 255 * (1-magenta);
        var blue :Number = 255 * (1-yellow);
        return [red, green, blue];
    }
    
    /**
     * Converts a color from the HSB color model to CMY. The value for hue should be
     * in the range of 0-360. Sat and bri should be in the range of 0.0 to 1.0 
     * @param hue the hue of the color. 
     * @param sat the saturation value.
     * @param bri the brightness value.
     *
     * @return an Array in the format [cyan, magenta, yellow]. The range for all is 0.0 to 1.0  
     */
    public static function HSBtoCMY (hue :Number, sat :Number, bri :Number) :Array 
    {
        var RGB :Array = HSBtoRGB(hue, sat, bri);
        var CMY :Array = RGBtoCMY(RGB[0], RGB[1], RGB[2]);
        return CMY;
    }

    protected static function CMYtoLCHab (cmyArray :Array) :Array 
    {
        // This function outputs an array of the LCH+ab color values based on the CMY inputs
        // The LCH+ab array is used in  the color comparison. 
                    
        var red :Number = (1 - cmyArray[0]);
        var green :Number = (1 - cmyArray[1]);
        var blue :Number = (1 - cmyArray[2]);

        if (red > 0.04045) {
            red = Math.pow(((red + 0.055) / 1.055), 2.4);
        } else {
            red = red / 12.92;
        }

        if (green > 0.04045) {
            green = Math.pow(((green + 0.055) / 1.055), 2.4);
        } else {
            green = green / 12.92;
        }

        if (blue > 0.04045) {
            blue = Math.pow(((blue + 0.055) / 1.055), 2.4);
        } else {
            blue = blue / 12.92;
        }

        red = red * 100;
        green = green * 100;
        blue = blue * 100;

        // Observer. = 2°, Illuminant = D65

        var X :Number = red * 0.4124 + green * 0.3576 + blue * 0.1805;
        var Y :Number = red * 0.2126 + green * 0.7152 + blue * 0.0722;
        var Z :Number = red * 0.0193 + green * 0.1192 + blue * 0.9505;

        //CONVERTING FROM XYZ TO LAB
        X = X / 95.047; //ref_X =  95.047  Observer =  2°, Illuminant =  D65
        Y = Y / 100.00; //ref_Y = 100.000
        Z = Z / 108.883; //ref_Z = 108.883

        if (X > 0.008856) {
            X = Math.pow(X, 1/3);
        } else {
            X = (7.787 * X) + (16 / 116);
        }

        if (Y > 0.008856) {
            Y = Math.pow(Y, 1/3);
        } else {
            Y = (7.787 * Y) + (16 / 116);
        }
        
        if (Z > 0.008856) {
            Z = Math.pow(Z, 1/3);
        } else {
            Z = (7.787 * Z) + (16 / 116);
        }

        var CIEL :Number = (116 * Y) - 16;
        var CIEa :Number = 500 * (X - Y);
        var CIEb :Number = 200 * (Y - Z);
        
        //CONVERTING FROM LAB TO LCH
        var CIEc :Number = Math.sqrt(CIEa * CIEa  + CIEb * CIEb);
        var CIEh :Number = (Math.atan2(CIEb, CIEa) * (180/Math.PI) + 360) % 360;
        return [CIEL, CIEc, CIEh, CIEa, CIEb];
    }
    
    /**
     * Changes the color of a Movie Clip using the RGB color model
     * @param mc the Movie Clip that is to be colored.
     * @param RGB an Array in the format of [red, green, blue]. The range for each should be 
     *        0-255.
     */
    public static function changeColorRGB (mc :MovieClip, RGB :Array) :void 
    {
        var tempColorTransform :ColorTransform = new ColorTransform();
        var colorR :int = RGB[0];
        var colorG :int = RGB[1];
        var colorB :int = RGB[2];
        var tempColor :int = colorR * 65536 + colorG * 256 + colorB;

        tempColorTransform.color = tempColor;
        mc.transform.colorTransform = tempColorTransform;
    }
    
    /**
     * Changes the color of a Movie Clip using the CMY color model
     * @param mc the Movie Clip that is to be colored. 
     * @param CMY an Array in the format of [cyan, magenta, yellow]. 
     *        The range for each should be 0.0-1.0
     */
    public static function changeColorCMY (mc :MovieClip, CMY :Array) :void 
    {
        // ensure proper range of the CMY values
        var cyanComp :Number = MathUtil.clamp(CMY[0], 0.0, 1.0);
        var magentaComp :Number = MathUtil.clamp(CMY[1], 0.0, 1.0);
        var yellowComp :Number = MathUtil.clamp(CMY[2], 0.0, 1.0);

        // Now we convert to RGB and apply the transformation matrix
        var red :int = Math.floor((1 - cyanComp) * 255);
        var green :int = Math.floor((1 - magentaComp) * 255);
        var blue :int = Math.floor((1 - yellowComp) * 255);
        changeColorRGB(mc, [red, green, blue])
    }

    /**
     * Changes the color of a Movie Clip using the HSB color model
     * @param mc the Movie Clip that is to be colored.. 
     * @param HSB an Array in the format of [hue, saturation, brightness]. 
     * The range for hue is 0-360. The range for saturation and brightness is 0.0-1.0
     */
    public static function changeColorHSB (mc :MovieClip, HSB :Array) :void 
    {
        var RGB :Array = HSBtoRGB(HSB[0], HSB[1], HSB[2]);
        changeColorRGB(mc, RGB);
    }

    /**
     * Returns the color difference between two colors as defined by 
     * <a href="http://en.wikipedia.org/wiki/Color_difference#CIEDE2000">CIEDE2000</a>.
     * The maximum color difference, that between black and white is 100. 
     * <p>The range of the arguments should be 0.0 to 1.0</p>
     * @param cmy1 the first color to be compared in the format of [cyan, magenta, yellow]
     * @param cmy2 the second color to be compared in the format of [cyan, magenta, yellow]
     * @return the difference between two colors, in the range of 0-100. 
     */
    public static function compareColorsCMY (cmy1 :Array, cmy2 :Array) :Number 
    {
        var temp1 :Array = CMYtoLCHab(cmy1);
        var temp2 :Array = CMYtoLCHab(cmy2);
        return calcColorDiff(cmy1, cmy2);
    }

    /**
     * Returns the color difference between two colors as defined by 
     * <a href="http://en.wikipedia.org/wiki/Color_difference#CIEDE2000">CIEDE2000</a>.
     * The maximum color difference, that between black and white is 100.
     * <p>The range of the arguments should be 0 to 255</p>
     * @param rgb1 the first color to be compared in the format of [red, green, blue]
     * @param rgb2 the second color to be compared in the format of [red, green, blue]
     * @return the difference between two colors, in the range of 0-100. 
     */
    public static function compareColorsRGB (rgb1 :Array, rgb2 :Array) :Number 
    {
        var cmy1 :Array = RGBtoCMY(rgb1[0], rgb1[1], rgb1[2]);
        var cmy2 :Array = RGBtoCMY(rgb2[0], rgb2[1], rgb2[2]);
        return compareColorsCMY(cmy1, cmy2);
    }

    protected static function calcColorDiff (currColor :Array, goalColor :Array) :Number 
    {
        var LCHab1:Array = CMYtoLCHab(currColor);
        var LCHab2:Array = CMYtoLCHab(goalColor);
                            
        var L1:Number = LCHab1[0];
        var C1:Number = LCHab1[1];
        var H1:Number = LCHab1[2];
        var a1:Number = LCHab1[3];
        var b1:Number = LCHab1[4];
        var L2:Number = LCHab2[0];
        var C2:Number = LCHab2[1];
        var H2:Number = LCHab2[2];
        var a2:Number = LCHab2[3];
        var b2:Number = LCHab2[4];
        var toDeg:Number = 180 / (Math.PI);
        var toRad:Number = 1 / toDeg;

        // after pulling out the numbers we need to place them into the get the secondary
        // numbers that will be used in the final formula
        var Cab :Number = (C1+C2)/2;
        var G :Number = 
            0.5 * (1 - (Math.sqrt((Math.pow(Cab,7) / ((Math.pow(Cab,7) + Math.pow(25,7)))))));
        
        var a1prime :Number = a1 * (1+G);
        var a2prime :Number = a2 * (1+G);
        var C1prime :Number = Math.sqrt(a1prime * a1prime + b1 * b1);
        var C2prime :Number = Math.sqrt(a2prime * a2prime + b2 * b2);
        var h1prime :Number = 0;
        if ((a1prime == 0) && (b1 == 0)) {
            h1prime = 0;
        } else {
            h1prime = (Math.atan2(b1, a1prime) * toDeg + 360) % 360;
        }

        var h2prime:Number = 0;
        if ((a2prime == 0) && (b2 == 0)) {
            h2prime = 0;
        } else {
            h2prime = (Math.atan2(b2,a2prime) * toDeg + 360) % 360;
        }

        var deltaL :Number = L2 - L1;
        var deltaC :Number = C2prime - C1prime;
        var deltaH :Number = h2prime - h1prime;
        if ((C1prime == 0) && (C2prime == 0)) {
            deltaH = 0;
        } else if (Math.abs(deltaH) <= 180) {
            deltaH = h2prime - h1prime;
        } else if (deltaH > 180) {
            deltaH = h2prime - h1prime - 360;
        } else if (deltaH < -180) {
            deltaH = h2prime - h1prime + 360;
        }

        var deltaHue :Number = 2 * Math.sqrt(C1prime * C2prime) * Math.sin(deltaH * toRad / 2);
        var LprimeAvg :Number = (L1 + L2) / 2;
        var CprimeAvg :Number = (C1prime + C2prime) / 2;
        var hprimeAvg :Number = 0;
        var hcheck1 :Number = Math.abs(h1prime - h2prime);
        var hcheck2 :Number = h1prime + h2prime;
        if ((C1prime == 0) && (C2prime == 0)) {
            hprimeAvg = 0;
        } else if (hcheck1 <= 180) {
            hprimeAvg = (h1prime + h2prime) / 2;
        } else if ((hcheck1 > 180) && (hcheck2 < 360)) {
            hprimeAvg = (h1prime + h2prime + 360) / 2;
        } else if ((hcheck1 > 180) && (hcheck2 >=  360)) {
            hprimeAvg = (h1prime + h2prime - 360) / 2;
        }
        
        var T :Number = 1 - 
            0.17 * Math.cos(hprimeAvg * toRad - Math.PI/6) + 
            0.24 * Math.cos(2 * hprimeAvg * toRad) + 
            0.32 * Math.cos(3 * hprimeAvg * toRad + Math.PI/30) - 
            0.20 * Math.cos(4 * hprimeAvg * toRad - (Math.PI) * 21/60);
        var deltaTheta :Number = 30 * Math.exp(-1 * (Math.pow((hprimeAvg - 275) / 25, 2)));
        var RC :Number = 2 * 
            Math.sqrt((Math.pow(CprimeAvg, 7)) / ((Math.pow(CprimeAvg, 7) + Math.pow(25, 7))));
        var SL :Number = 1 + 
            (0.015 * Math.pow((LprimeAvg - 50), 2)) / 
            (Math.sqrt(20 + Math.pow((LprimeAvg - 50), 2)));
        var SC :Number = 1 +  0.045 * CprimeAvg;
        var SH :Number = 1 + 0.015 * CprimeAvg * T;
        var RT :Number = -1 * Math.sin(2 * deltaTheta * toRad) * RC;
        var LS2 :Number = Math.pow((deltaL / SL), 2);
        var CS2 :Number = Math.pow((deltaC / SC), 2);
        var HS2 :Number = Math.pow((deltaHue / SH), 2);
        var RTCH :Number = RT * (deltaC / SC) * (deltaHue / SH);
        var e2000 :Number = Math.sqrt(LS2 + CS2 + HS2 + RTCH);
        return e2000
    }
}
}
