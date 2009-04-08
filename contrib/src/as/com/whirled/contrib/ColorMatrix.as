// ColorMatrix Class v1.2
//
// Author: Mario Klingemann
// http://www.quasimondo.com

// Changes in v1.1:
// Changed the RGB to luminance constants
// Added colorize() method

// Changes in v1.2:
// Added clone()
// Added randomize()
// Added blend()
// Added "filter" property

package com.whirled.contrib {

import flash.filters.ColorMatrixFilter;

public class ColorMatrix
{
    public static function create (mat :Object = null) :ColorMatrix
    {
        return new ColorMatrix(mat);
    }

    public static function createHSB (... args) :ColorMatrix
    {
        var mat :ColorMatrix = new ColorMatrix();
        if (args.length > 0) {
            mat.adjustHue(args[0]);
        }
        if (args.length > 1) {
            mat.adjustSaturation(args[1]);
        }
        if (args.length > 2) {
            mat.adjustBrightness(args[2], args[2], args[2]);
        }
        return mat;
    }

    /*
   Function: ColorMatrix

    Constructor

   Parameters:

      mat - if omitted matrix gets initialized with an
            identity matrix. Alternatively it can be
            initialized with another ColorMatrix or
            an array (there is currently no check
            if the array is valid. A correct array
            contains 20 elements.)


    */
    public function ColorMatrix ( mat:Object = null )
    {
        if (mat is ColorMatrix )
        {
            matrix = mat.matrix.concat();
        } else if (mat is Array )
        {
            matrix = mat.concat();
        } else
        {
            reset();
        }

    }

    /*
   Function: reset

    resets the matrix to the neutral identity matrix. Applying this
    matrix to an image will not make any changes to it.

   Parameters:
      none
    */
    public function reset() :ColorMatrix
    {
        matrix = IDENTITY.concat();
        return this;
    }


    public function clone():ColorMatrix
    {
        return new ColorMatrix( matrix );
    }

    /**
     * Matches the effects of the "Adjust Color" filter in the FAT
     *
     * @param brightness an integer between -100 and 100
     * @param contrast an integer between -100 and 100
     * @param saturation an integer between -100 and 100
     * @param hue an integer between -180 and 180
     */
    public function adjustColor (brightness :int, contrast :int, saturation :int, hue :int)
        :ColorMatrix
    {
        if (brightness != 0) {
            adjustBrightness(brightness, brightness, brightness);
        }

        if (contrast != 0) {
            var actualContrast :Number = (contrast * 0.01);
            adjustContrast(actualContrast, actualContrast, actualContrast);
        }

        if (saturation != 0) {
            adjustSaturation(1 + (saturation * 0.01));
        }

        if (hue != 0) {
            adjustHue(hue);
        }

        return this;
    }


    /*
   Function: adjustSaturation

    changes the saturation

   Parameters:

      s - typical values come in the range 0.0 ... 2.0 where
                0.0 means 0% Saturation
                0.5 means 50% Saturation
                1.0 is 100% Saturation (aka no change)
                2.0 is 200% Saturation

                Other values outside of this range are possible
                -1.0 will invert the hue but keep the luminance


    Returns:

        nothing


    */

    public function adjustSaturation ( s:Number ) :ColorMatrix
    {
        var i_s:Number=1-s;

        var irlum:Number = i_s * r_lum;
        var iglum:Number = i_s * g_lum;
        var iblum:Number = i_s * b_lum;

        var mat:Array =        [irlum + s, iglum    , iblum    , 0, 0,
                                irlum    , iglum + s, iblum    , 0, 0,
                                irlum    , iglum    , iblum + s, 0, 0,
                                0        , 0        , 0        , 1, 0 ];


        concat(mat);

        return this;
    }

    public function adjustContrast ( r:Number, g:Number, b:Number ) :ColorMatrix
    {
        g = g || r;
        b = b || r;

        r+=1;
        g+=1;
        b+=1;

        var mat:Array =       [r,0,0,0,128*(1-r),
                                0,g,0,0,128*(1-g),
                                0,0,b,0,128*(1-b),
                            0,0,0,1,0];


        concat(mat);

        return this;
    }

    public function adjustBrightness (r:Number, g:Number, b:Number) :ColorMatrix
    {
        g = g || r;
        b = b || r;

        var mat:Array =       [1,0,0,0,r,
                                0,1,0,0,g ,
                                0,0,1,0,b ,
                            0,0,0,1,0 ];


        concat(mat);

        return this;
    }

    public function adjustHue( angle:Number ) :ColorMatrix
    {
        angle *= Math.PI/180;

        var c:Number = Math.cos( angle );
        var s:Number = Math.sin( angle );

        var f1:Number = 0.213;
        var f2:Number = 0.715;
        var f3:Number = 0.072;

        var mat:Array = [(f1 + (c * (1 - f1))) + (s * (-f1)), (f2 + (c * (-f2))) + (s * (-f2)), (f3 + (c * (-f3))) + (s * (1 - f3)), 0, 0, (f1 + (c * (-f1))) + (s * 0.143), (f2 + (c * (1 - f2))) + (s * 0.14), (f3 + (c * (-f3))) + (s * -0.283), 0, 0, (f1 + (c * (-f1))) + (s * (-(1 - f1))), (f2 + (c * (-f2))) + (s * f2), (f3 + (c * (1 - f3))) + (s * f3), 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];

        concat(mat);

        return this;
    }

    public function colorize ( rgb:Number, amount:Number = 1) :ColorMatrix
    {

        var r:Number = ( ( rgb >> 16 ) & 0xff ) / 255;
        var g:Number = ( ( rgb >> 8  ) & 0xff ) / 255;
        var b:Number = (   rgb         & 0xff ) / 255;

        var inv_amount:Number = 1 - amount;


        var mat:Array =        [ inv_amount + amount*r*r_lum, amount*r*g_lum,  amount*r*b_lum, 0, 0,
                                amount*g*r_lum, inv_amount + amount*g*g_lum, amount*g*b_lum, 0, 0,
                                    amount*b*r_lum,amount*b*g_lum, inv_amount + amount*b*b_lum, 0, 0,
                                0 , 0 , 0 , 1, 0 ];


        concat(mat);

        return this;
    }

    /**
     * Performs the same transformation as the FAT "Tint" function.
     */
    public function tint (rgb :Number, amount :Number = 1) :ColorMatrix
    {
        var r:Number = ( ( rgb >> 16 ) & 0xff ) * amount;
        var g:Number = ( ( rgb >> 8  ) & 0xff ) * amount;
        var b:Number = (   rgb         & 0xff ) * amount;

        var inv_amount:Number = 1 - amount;

        var mat:Array =        [ inv_amount, 0, 0, 0, r,
                                 0, inv_amount, 0, 0, g,
                                 0, 0, inv_amount, 0, b,
                                 0, 0, 0, 1, 0 ];

        concat(mat);

        return this;
    }

    /**
     * Converts the target to grayscale.
     */
    public function makeGrayscale () :ColorMatrix
    {
        const oneThird :Number = 1 / 3;

        var mat :Array = [ oneThird, oneThird, oneThird, 0, 0,
                           oneThird, oneThird, oneThird, 0, 0,
                           oneThird, oneThird, oneThird, 0, 0,
                           0, 0, 0, 1, 0 ];

        concat(mat);

        return this;
    }

    public function setAlpha( alpha:Number ) :ColorMatrix
    {
        var mat:Array =        [ 1, 0, 0, 0, 0,
                                0, 1, 0, 0, 0,
                                    0, 0, 1, 0, 0,
                                0, 0, 0, alpha, 0 ];

        concat(mat);

        return this;
    }

    public function desaturate() :ColorMatrix
    {
        var mat:Array =        [ r_lum, g_lum, b_lum, 0, 0,
                                r_lum, g_lum, b_lum, 0, 0,
                                    r_lum, g_lum, b_lum, 0, 0,
                                0    , 0    , 0    , 1, 0 ];

        concat(mat);

        return this;
    }

    public function invert() :ColorMatrix
    {
        var mat:Array =        [ -1 ,  0,  0, 0, 255,
                                    0 , -1,  0, 0, 255,
                                0 ,  0, -1, 0, 255,
                                0,   0,  0, 1,   0];

        concat(mat);

        return this;
    }

    public function threshold( t:Number ) :ColorMatrix
    {
        var mat:Array =            [r_lum*256, g_lum*256, b_lum*256, 0,  -256*t,
                                    r_lum*256 ,g_lum*256, b_lum*256, 0,  -256*t,
                                    r_lum*256, g_lum*256, b_lum*256, 0,  -256*t,
                                    0, 0, 0, 1, 0];
        concat(mat);

        return this;
    }

    public function randomize( amount :Number = 1 ) :ColorMatrix
    {
        var inv_amount:Number = 1 - amount;

        var r1:Number = inv_amount +  amount * ( Math.random() - Math.random() );
        var g1:Number = amount     * ( Math.random() - Math.random() );
        var b1:Number = amount     * ( Math.random() - Math.random() );

        var o1:Number = amount * 255 * (Math.random() - Math.random());

        var r2:Number = amount     * ( Math.random() - Math.random() );
        var g2:Number = inv_amount +  amount * ( Math.random() - Math.random() );
        var b2:Number = amount     * ( Math.random() - Math.random() );

        var o2:Number = amount * 255 * (Math.random() - Math.random());


        var r3:Number = amount     * ( Math.random() - Math.random() );
        var g3:Number = amount     * ( Math.random() - Math.random() );
        var b3:Number = inv_amount +  amount * ( Math.random() - Math.random() );

        var o3:Number = amount * 255 * (Math.random() - Math.random());

        var mat:Array =            [r1, g1, b1, 0, o1,
                                    r2 ,g2, b2, 0, o2,
                                    r3, g3, b3, 0, o3,
                                    0 ,  0,  0, 1, 0 ];

        concat(mat);

        return this;
    }


    public function setChannels (r:Number, g:Number, b:Number, a:Number ) :ColorMatrix
    {
        var rf:Number =((r & 1) == 1 ? 1:0) + ((r & 2) == 2 ? 1:0) + ((r & 4) == 4 ? 1:0) + ((r & 8) == 8 ? 1:0);
        if (rf>0) rf=1/rf;
        var gf:Number =((g & 1) == 1 ? 1:0) + ((g & 2) == 2 ? 1:0) + ((g & 4) == 4 ? 1:0) + ((g & 8) == 8 ? 1:0);
        if (gf>0) gf=1/gf;
        var bf:Number =((b & 1) == 1 ? 1:0) + ((b & 2) == 2 ? 1:0) + ((b & 4) == 4 ? 1:0) + ((b & 8) == 8 ? 1:0);
        if (bf>0) bf=1/bf;
        var af:Number =((a & 1) == 1 ? 1:0) + ((a & 2) == 2 ? 1:0) + ((a & 4) == 4 ? 1:0) + ((a & 8) == 8 ? 1:0);
        if (af>0) af=1/af;

        var mat:Array =       [(r & 1) == 1 ? rf:0,(r & 2) == 2 ? rf:0,(r & 4) == 4 ? rf:0,(r & 8) == 8 ? rf:0,0,
                                (g & 1) == 1 ? gf:0,(g & 2) == 2 ? gf:0,(g & 4) == 4 ? gf:0,(g & 8) == 8 ? gf:0,0,
                                (b & 1) == 1 ? bf:0,(b & 2) == 2 ? bf:0,(b & 4) == 4 ? bf:0,(b & 8) == 8 ? bf:0,0,
                            (a & 1) == 1 ? af:0,(a & 2) == 2 ? af:0,(a & 4) == 4 ? af:0,(a & 8) == 8 ? af:0,0];

        concat(mat);

        return this;
    }

    public function blend( m:ColorMatrix, amount:Number ) :ColorMatrix
    {
        var inv_amount:Number = 1 - amount;

        for (var i:Number = 0; i < 20; i++ )
        {
            matrix[i] = inv_amount * matrix[i] + amount * m.matrix[i];
        }

        return this;
    }

    public function concat (mat :Array) :ColorMatrix
    {
        var temp:Array = [];
        var i:Number = 0;

        for (var y:Number = 0; y < 4; y++ )
        {

            for (var x:Number = 0; x < 5; x++ )
            {
                temp[i + x] = mat[i    ] * matrix[x     ] +
                            mat[i+1] * matrix[x +  5] +
                            mat[i+2] * matrix[x + 10] +
                            mat[i+3] * matrix[x + 15] +
                            (x == 4 ? mat[i+4] : 0);
            }
            i+=5;
        }

        matrix = temp;

        return this;
    }

    public function createFilter():ColorMatrixFilter
    {
        return new ColorMatrixFilter( matrix );
    }


    protected var matrix:Array;


    // RGB to Luminance conversion constants as found on
    // Charles A. Poynton's colorspace-faq:
    // http://www.faqs.org/faqs/graphics/colorspace-faq/

    private static const r_lum:Number = 0.212671;
    private static const g_lum:Number = 0.715160;
    private static const b_lum:Number = 0.072169;

    /*

    // There seem  different standards for converting RGB
    // values to Luminance. This is the one by Paul Haeberli:

    private static var r_lum:Number = 0.3086;
    private static var g_lum:Number = 0.6094;
    private static var b_lum:Number = 0.0820;

    */

    private static const IDENTITY:Array = [
       1,0,0,0,0,
       0,1,0,0,0,
       0,0,1,0,0,
       0,0,0,1,0
    ];
}

}
