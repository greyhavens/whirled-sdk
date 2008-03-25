package com.whirled.contrib.simplegame.util {

import com.threerings.flash.Vector2;

import com.whirled.contrib.simplegame.*;

import flash.display.DisplayObject;
import flash.geom.Point;

public class Collision
{
    /** Returns true if the two circular display objects intersect. */
    public static function circularDisplayObjectsIntersect (
        cA :Vector2,
        rA :Number,
        do1 :DisplayObject,
        cB :Vector2,
        rB :Number,
        do2 :DisplayObject) :Boolean
    {
        if (null == do1 || null == do2 || null == do1.parent || null == do2.parent) {
            throw new ArgumentError("do1 and do2 must be non-null, and part of the display list");
        }
        
        var p :Point = cA.toPoint();
        p = do1.parent.localToGlobal(p);
        p = do2.parent.globalToLocal(p);
        
        return Collision.circlesIntersect(Vector2.fromPoint(p), rA, cB, rB);
    }
    
    /** Returns true if the two circles intersect. */
    public static function circlesIntersect (
        cA :Vector2,
        rA :Number,
        cB :Vector2,
        rB :Number) :Boolean
    {
        return (cB.subtract(cA).lengthSquared <= ((rA + rB) * (rA + rB)));
    }
    
    /**
     * Returns a value in [0, 1] that indicates the distance that circle A's path
     * must be scaled to avoid intersecting with circle B, or -1 if no interesection
     * occurs.
     * 
     * "direction" must be a unit-length vector. The two circles must not already be
     * intersecting.
     */
    public static function movingCircleIntersectsStaticCircle (
        cA :Vector2,
        rA :Number,
        directionA :Vector2,
        distanceA :Number,
        cB :Vector2,
        rB :Number) :Number
    {
        // http://www.gamasutra.com/features/20020118/vandenhuevel_02.htm
        
        var c :Vector2 = cB.subtract(cA);
        var cLengthSquared :Number = c.lengthSquared;
        
        var d :Number = c.dot(directionA);
        
        // A is moving in the wrong direction
        if (d <= 0) {
            return -1;
        }
        
        var f :Number = cLengthSquared - (d * d);
        var minDistSquared :Number = ((rA + rB) * (rA + rB));
        
        // A will pass but not collide with B
        if (f > minDistSquared) {
            return -1;
        }
        
        var t :Number = minDistSquared - f;
        
        if (t < 0) {
            return -1;
        }
        
        var collideDistance :Number = d - Math.sqrt(t);
        
        if (collideDistance > distanceA) {
            return -1;
        }
        
        return collideDistance / distanceA;
    }
    
    /**
     * Returns a value in [0, 1] that indicates the distance that the two circles'
     * paths must be scaled to avoid intersecting each other, or -1 if no interesection
     * will occurs.
     * 
     * dA and dB *don't* need to be unit length vectors. The two circles must not already be
     * intersecting.
     */
    public static function movingCirclesIntersect (
        cA :Vector2,
        rA :Number,
        dA :Vector2,
        cB :Vector2,
        rB :Number,
        dB :Vector2) :Number
    {
        var direction :Vector2 = dA.subtract(dB);
        var distance :Number = dA.normalizeLocalAndGetLength();
        
        return movingCircleIntersectsStaticCircle(cA, rA, direction, distance, cB, rB);
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
        var uDenom :Number = linePt2.subtract(linePt1).lengthSquared;
        
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
            var a :Number = linePt1.subtract(pt).length;
            var b :Number = linePt2.subtract(pt).length;
            
            return Math.min(a, b);
        } else {
            // solve for the point of intersection of the tangent
            var p :Vector2 = new Vector2();
            
            p.x = linePt1.x + (u * (linePt2.x - linePt1.x));
            p.y = linePt1.y + (u * (linePt2.y - linePt1.y));
            
            // return the distance from pt to p
            p.subtractLocal(pt);
            return Math.abs(p.length);
        }
    }
}

}
