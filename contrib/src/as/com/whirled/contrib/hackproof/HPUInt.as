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
// Copyright 2009 Keith Irwin
//
// $id$
//
// HackProofInt - a class which will hold an integer value and is
// resistant to simple searching, modification and freezing attacks
// from Cheat Engine or other similar programs.

package com.whirled.contrib.hackproof {

    import flash.events.EventDispatcher;

    /**
     * This class holds an unsigned integer value.  From the point of view
     * of the programmer, it should work just like a normal uint,
     * except that it needs to be accessed using the "value" member
     * and it will dispatch a HackDetected event if the value is
     * tampered with externally.
     *
     * <p> Also, HPUInts will not have all
     * of their parts garbage collected, so if a large number of
     * them are used in a program, memory leakage will occur.
     * If you need to use HPUInts in disposable objects, it is
     * recommended that you use the HPReuseManager to allocate
     * and deallocate HPUInts as needed.
     *
     * <p> Here's how HPUInt works:<br>
     * The value is actually stored as the difference of two
     * numbers, one of which is generated randomly.  As a result,
     * the stored value will not appear in memory anywhere.
     * It also stores a checksum in a separate location.
     */
    public class HPUInt extends EventDispatcher {
        
        private static var masterSum : uint = 0;
        private static var checkSums : Array = new Array();
        private static var numberOfHackProofUInts : uint = 0;

        /* Used so that we can throw events from a static method.
         * Once at least one HPUInt exists, it will always point
         * to one. */
        private static var aHackProofUInt : HPUInt = null;

        private var myID : uint;
        private var valuePart1 : uint;
        private var valuePart2 : uint;

        /** Creates a new HPUInt with the default value of 0. */
        public function HPUInt() {
            myID = numberOfHackProofUInts;
            numberOfHackProofUInts++;
            
            valuePart1 = Math.random()*uint.MAX_VALUE;
            valuePart2 = valuePart1; //Initial value: 0
            checkSums.push(2*valuePart1);
            masterSum += 2*valuePart1;
            aHackProofUInt = this;
        }

        /** Contains the value. */
        public function get value() : uint {
            //checkIntegrity();
            /* This function call has been inlined for speed. */
            if (valuePart1+valuePart2 != checkSums[myID]) {
                dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.UINT_HACK_DETECTED));
            }
            /* End inlining. */
            valuePart1++;
            valuePart2++;
            checkSums[myID] += 2;
            masterSum += 2;
            return valuePart1 - valuePart2;
        }

        public function set value(newval : uint) : void {
            //checkIntegrity();
            /* We had inlined this call for speed, but we're
             * now modifying it to set a flag and pushing the
             * event dispatch until later to avoid infinite
             * loops in the event that an HP variable is set
             * inside of a HackDetected event handler. */
            var hackDetected : Boolean = 
                (valuePart1+valuePart2 != checkSums[myID]);

            masterSum -= checkSums[myID];
            valuePart1 = Math.random()*uint.MAX_VALUE;
            valuePart2 = valuePart1 - newval;
            checkSums[myID] = valuePart1 + valuePart2;
            masterSum += checkSums[myID];

            if (hackDetected) {
                dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.UINT_HACK_DETECTED));
            }
        }

        /** Although each HPInt is checked each time it is read or
            written, this function can be used to check that it hasn't
            been modified at other times.  Calling this is never necessary. */
        public function checkIntegrity() : Boolean {
            /* This function has been inlined above.  If any changes are
             * made to it, corresponding changes should be made to the
             * getter and setter for value. */
            if (valuePart1+valuePart2 != checkSums[myID]) {
                dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.UINT_HACK_DETECTED));
                return false;
            } else {
                return true;
            }
        }

        /** Used to verify the master checksum for HPIInt.
            This should be called every once and a while if you
            want to be certain that freezing attacks are not occuring. */
        public static function verifyAll() : Boolean {
            var total : uint = 0;
            for each (var sum:int in checkSums) {
                total += sum;
            }
            if (total != masterSum) {
                if (aHackProofUInt != null) {
                    aHackProofUInt.dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.INT_HACK_DETECTED));
                }
                return false;
            } else {
                return true;
            }
        }
    }
}