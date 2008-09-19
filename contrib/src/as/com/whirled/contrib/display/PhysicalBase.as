// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 J Daniels (jdnx429 on Whirled)
//
// $Id$

package com.whirled.contrib.display {

import flash.display.MovieClip;

import flash.events.TimerEvent;

import flash.utils.Timer;

/**
 * This class allows Movie Clips to move in accordance with simple physics including acceleration 
 * and drag. There are no collision dynamics in this class. However, this is useful for animating
 * projectiles or particles. 
 *
 * <p><b>Important!</b> The convention for coordinates in Flash is that an increase in the
 * <b>y</b> direction indicates movement in a downward direction. To apply an acceleration that 
 * forces objects downwards use a positive acceleration, not a negative acceleration.</p>
 * 
 * <p>This class is meant to be extended.</p>
 *
 * Author: jdnx429
 */
public class PhysicalBase extends MovieClip {
    /** The x component of the object's speed in pixels/second. */
    public var speedX :Number = 0; // in pixels per second

    /**
    * The y component of the object's speed in pixels/second. A positive number indicates
    * a downward direction. 
    */
    public var speedY :Number = 0; // in pixels per second

    /** The x component of the object's acceleration in pixels/second/second.  */
    public var accelX :Number = 0; // in pixels per second

    /**
     * The y component of the object's acceleration in pixels/second/second. A positive number 
     * indicates a downward direction. 
     */
    public var accelY :Number = 0; // in pixels per second/per second

    /**
     * The drag constant of the object. The range is typically 0.0 to 5.0.  The ultimate 
     * decceleration force is a combination of the drag constant and the speed of the object. 
     */
    public var drag :Number =  0.0; // in pixel/seconds per pixel/second above the drag Limit

    /**
     * The minimum speed at which drag occurs in pixels/second. While the object is below this 
     * speed no drag is applied. At speeds above the dragLimit, drag progressively increases
     * with speed. 
     */
    public var dragLimit :Number = 1000; // minimum speed at which drag occurs

    /**
     * The timer that controls object updating. This is set to 33.333 milliseconds which 
     * translates to 30 frames per second. Changing the delay of the timer won't change the speed 
     * of the objects, only how often the objects are rendered. 
     */
    public var physicalTimer :Timer = new Timer(1000/30); // for the timer

    /**
     * Creates a PhysicalBase object at the location specfied. 
     * @param xpos - the x-coordinate of the object.
     * @param ypost - the y-coordinate of the object. 
     */
    public function PhysicalBase (xpos :Number, ypos :Number)
    {
        this.x = xpos;
        this.y = ypos;
    }

    /**
     * Initializes the Timer that controls the object and starts moving the object in accordance 
     * with its properties.
     */
    public function startMoving () :void 
    {
        physicalTimer.start();
        physicalTimer.addEventListener(TimerEvent.TIMER, update, false, 0,true);
    }

    /**
     * Sets all speed and acceleration to 0, stopping the object. 
     */
    public function halt() :void 
    {
        speedX = 0;
        speedY = 0;
        accelX = 0;
        accelY = 0;
    }

    /**
    * Destroys the object. Removes the EventListener to the Timer that controls the object and
    * removes it from the Stage or parent Movie Clip
    */
    public function destroy () :void 
    {
        this.parent.removeChild(this);
        physicalTimer.stop();
        physicalTimer.removeEventListener(TimerEvent.TIMER, update);
    }

    /**
     * Called on every TimerEvent and updates the position of the object. 
     * On subclasses this is a good place for addtional checks such as making sure
     * the object is destroyed when it leaves the screen. 
     */
    private function update (e :TimerEvent) :void 
    {
        // TODO: This may need to be updated. 
        applyDrag();
        
        this.x += speedX * (physicalTimer.delay/1000) + 0.5 * (accelX) * 
                  (physicalTimer.delay/1000) * (physicalTimer.delay/1000);
        this.y += speedY * (physicalTimer.delay/1000) + 0.5 * (accelY) * 
                  (physicalTimer.delay/1000) * (physicalTimer.delay/1000) ;
        
        speedX += accelX * (physicalTimer.delay/1000);
        speedY += accelY * (physicalTimer.delay/1000);
    }

    /**
     * Sets the speed of the object using the x and y components.
     * 
     * @param xnum the x component of the speed.
     * @param ynum the y component of the speed.
     */
    public function setSpeedComp (xnum :Number, ynum :Number) :void 
    {
        speedX = xnum;
        speedY = ynum;
    }

    /**
     * Sets the speed of the object using the speed of the object and an angle.
     * 
     * @param speed the speed of the object
     * @param angle the angle of the object - this is set in degrees. Remember that y is positive 
     *              the downward direction. An angle of 90 degrees therefore is straight down. 
     */
    public function setSpeedVector (speed :Number, angle :Number) :void 
    {
        //angle should be in degrees!
        angle = angle / (180/Math.PI);
        speedX = speed * Math.cos(angle);
        speedY = speed * Math.sin(angle);
    }

    /**
     * Adds the current speed vector with the supplied vector. 
     * 
     * @param speed the speed of the speed vector to be added to the object. 
     * @param angle the angle of the speed vector to be added to the object. This is set in 
     *              degrees. 
     */
    public function addSpeedVector (speed :Number, angle :Number) :void 
    {
        //angle should be in degrees!
        angle = angle / (180 / Math.PI);
        speedX = speedX + (speed * Math.cos(angle))
        speedY = speedY + (speed * Math.sin(angle))
    }

    /**
     * Check this, watch speed and accel.
     */
    public function addAccVector (acc :Number, angle :Number) :void 
    {
        //angle should be in degrees!
        angle = angle / (180/Math.PI);
        accelX = accelX + (acc * Math.cos(angle))
        accelY = accelY + (acc * Math.sin(angle))
    }

    /**
     * Sets the location of the object.
     *
     * @param xpos the x-coordinate of the object.
     * @param ypos the y-coordinate of the object.
     */
    public function setLocation (xpos :Number, ypos :Number) :void 
    {
        this.x = xpos;
        this.y = ypos;
    }

    /**
     * Sets the acceleration of the object using x and y components.
     *
     * @param xacc the x component of the acceleration.
     * @param yacc the y component of the acceleration.
     */
    public function setAccComp (xacc :Number, yacc :Number) :void 
    {
        accelX = xacc;
        accelY = yacc;
    }

    /** 
     * Sets the acceleration of the object using a vector.
     *
     * @param acc the acceleration of the object.
     * @param angle the angle of the applied acceleration in degrees. Y-coordinates are positive 
     *              in the downward direction. An angle of 90 degrees is therefore straight down.
     */
    public function setAccVector (acc :Number, angle :Number) :void 
    {
        angle = angle / (180/Math.PI);
        accelX = acc * Math.cos(angle);
        accelY = acc * Math.sin(angle);
    }

    /** 
     * Sets the drag and the drag limit of the object.
     *
     * @param dragnum the drag of the object.
     * @param dragLimitnum the dragLimit of the object.
     */
    public function setDrag (dragnum :Number, dragLimitnum :Number) :void 
    {
        drag = dragnum;
        if (dragLimitnum < 0) {
            dragLimitnum = 0;
        }
        dragLimit = dragLimitnum
    }
    
    protected function applyDrag() :void 
    {
        var currSpeed :Number = getSpeed();
        if (currSpeed > dragLimit) {
            var dragSlowdown :Number = 1 - ((currSpeed - dragLimit) * drag * 
                                            (physicalTimer.delay/1000)) / currSpeed;
            speedX = speedX * dragSlowdown;
            speedY = speedY * dragSlowdown;
        }
    }
 
    /**
     * Returns the current speed of the object in pixels per second.
     * 
     * @return the speed of the object. 
     */
    public function getSpeed () :Number 
    {
        return Math.sqrt(Math.pow(speedX, 2) + Math.pow(speedY, 2));
    }

    /**
     * Returns the current direction of the object. 
     * 
     * @return the angle in degrees that the object is moving in. 
     */
    public function getAngle () :Number 
    {
        return Math.atan2(speedY, speedX) * 180 / Math.PI;
    }
}
}
