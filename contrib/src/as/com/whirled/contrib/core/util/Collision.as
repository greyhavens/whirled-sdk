package com.whirled.contrib.core.util {

import com.whirled.contrib.core.*;

public class Collision
{
    /** Returns true if the two circles intersect. */
    public static function circlesIntersect (
        center1 :Vector2,
        radius1 :Number,
        center2 :Vector2,
        radius2 :Number) :Boolean
    {
        var maxDistSquared :Number = ((radius1 + radius2) * (radius1 + radius2));
        var dVec :Vector2 = Vector2.subtract(center1, center2);

        return (dVec.lengthSquared <= maxDistSquared);
    }
    
    /** 
     * Returns the minimum distance between the point "pt" and the line segement that lies
     * between linePt1 and linePt2.
     * 
     * If linePt1 and linePt2 are coincident, the function will return Infinity.
     */
    public static function minDistanceFromPointToLineSegment (pt :Vector2, linePt1 :Vector2, linePt2 :Vector2) :Number
    {
        // technique described at http://local.wasp.uwa.edu.au/~pbourke/geometry/pointline/
        
        // determine 'u'
        var uDenom :Number = Vector2.subtract(linePt2, linePt1).lengthSquared;
        
        if (uDenom == 0) {
            return Infinity;    // the line points given are coincident
        }
        
        var uNumer :Number = (((pt.x - linePt1.x) * (linePt2.x - linePt1.x)) + ((pt.y - linePt1.y) * (linePt2.y - linePt1.y)));
        
        var u :Number = uNumer / uDenom;
        
        /* if u is not between 0 and 1, there is no point on the line segment that forms
           a tangent to the line with pt. i.e.:
           
           * pt
           
                 *-----------* line
        */
        
        if (u < 0 || u > 1) {
            // find the smallest distance between pt and both line segment points
            var a :Number = Math.abs(Vector2.subtract(linePt1, pt).length);
            var b :Number = Math.abs(Vector2.subtract(linePt2, pt).length);
            
            return Math.min(a, b);
        } else {
            // solve for the point of intersection of the tangent
            var p :Vector2 = new Vector2();
            
            p.x = linePt1.x + (u * (linePt2.x - linePt1.x));
            p.y = linePt1.y + (u * (linePt2.y - linePt1.y));
            
            // return the distance from pt to p
            p.subtract(pt);
            return Math.abs(p.length);
        }
    }
}

}
