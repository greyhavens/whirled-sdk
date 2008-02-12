package com.whirled.contrib.core.util {

import com.whirled.contrib.core.*;

import flash.display.DisplayObject;
import flash.geom.Point;

public class Collision
{
    /** Returns true if the two circular display objects intersect. */
    public static function circularDisplayObjectsIntersect (
        center1 :Vector2,
        radius1 :Number,
        do1 :DisplayObject,
        center2 :Vector2,
        radius2 :Number,
        do2 :DisplayObject) :Boolean
    {
        if (null == do1 || null == do2 || null == do1.parent || null == do2.parent) {
            throw new ArgumentError("do1 and do2 must be non-null, and part of the display list");
        }
        
        var p :Point = center1.toPoint();
        p = do1.parent.localToGlobal(p);
        p = do2.parent.globalToLocal(p);
        
        return Collision.circlesIntersect(Vector2.fromPoint(p), radius1, center2, radius2);
    }
    
    /** Returns true if the two circles intersect. */
    public static function circlesIntersect (
        center1 :Vector2,
        radius1 :Number,
        center2 :Vector2,
        radius2 :Number) :Boolean
    {
        var minDistSquared :Number = ((radius1 + radius2) * (radius1 + radius2));
        var dVec :Vector2 = Vector2.subtract(center1, center2);

        return (dVec.lengthSquared <= minDistSquared);
    }
    
    /**
     * Returns a value in [0, 1] that indicates the distance along the path given
     * by (distance * direction) that the circle given by (center1, radius1) will
     * intersect the circle given by (center2, radius2), or -1 if no intersection
     * occurs.
     * 
     * "direction" must be a unit-length vector. The two circles must not already be
     * intersecting.
     */
    public static function movingCircleIntersectsCircle (
        center1 :Vector2,
        radius1 :Number,
        direction :Vector2,
        distance :Number,
        center2 :Vector2,
        radius2 :Number) :Number
    {
        // http://www.gamasutra.com/features/20020118/vandenhuevel_02.htm
        
        var c :Vector2 = center2.getSubtract(center1);
        var cLengthSquared :Number = c.lengthSquared;
        
        // the circle will not move far enough
        if (c.lengthSquared >= (distance * distance)) {
            return -1;
        }
        
        var d :Number = c.dot(direction);
        
        // the circle is moving in the wrong direction
        if (d <= 0) {
            return -1;
        }
        
        var f :Number = (cLengthSquared + (d * d));
        var minDistSquared :Number = ((radius1 + radius2) * (radius1 + radius2));
        
        // the circle won't intersect
        if (f > minDistSquared) {
            return -1;
        }
        
        var t :Number = minDistSquared - f;
        
        var collideDistance :Number = d - Math.sqrt(t);
        
        if (collideDistance > distance) {
            return -1;
        }
        
        return collideDistance / distance;
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
