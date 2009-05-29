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
// HPBoolean - a class which will hold a boolean value and is
// resistant to simple searching, modification and freezing attacks
// from Cheat Engine or other similar programs.

package com.whirled.contrib.hackproof {

    import flash.events.EventDispatcher;

    /**
     * This class holds a boolean (true/false) value.  From the point of view
     * of the programmer, it should work just like a normal Boolean,
     * except that it needs to be accessed using the "value" member
     * and it will dispatch a HackDetected event if the value is
     * tampered with externally.
     *
     * <p> Also, HPBooleanss will not have all
     * of their parts garbage collected, so if a large number of
     * them are used in a program, memory leakage will occur.
     * If you need to use HPBooleans in disposable objects, it is
     * recommended that you use the HPReuseManager to allocate
     * and deallocate HPBooleans as needed.
     *
     * <p> Here's how HPBoolean works:<br>
     * The value is actually stored as whether or not one number is
     * larger than another, with both numbers being generated randomly.
     * As a result, the stored value will not appear in memory anywhere.
     * It also stores a checksum in a separate location.
     */
    public class HPBoolean extends EventDispatcher {
        
        private static var masterSum : uint = 0;
        private static var checkSums : Array = new Array();
        private static var numberOfHackProofBooleans : uint = 0;

        /* Used so that we can throw events from a static method.
         * Once at least one HPBoolean exists, it will always point
         * to one. */
        private static var aHackProofBoolean : HPBoolean = null;

        private var myID : uint;
        private var valuePart1 : uint;
        private var valuePart2 : uint;

        /** Creates a new HPBoolean with the default value of false. */
        public function HPBoolean() {
            myID = numberOfHackProofBooleans;
            numberOfHackProofBooleans++;
            
            valuePart1 = Math.random()*uint.MAX_VALUE;
            valuePart2 = Math.random()*uint.MAX_VALUE;
            if (valuePart1 > valuePart2) {
                switchValues();
            } // Initial value: false;
            checkSums.push(valuePart1+valuePart2);
            masterSum += 2*valuePart1;
            aHackProofBoolean = this;
        }

        private function switchValues() : void {
            var temp : uint = valuePart1;
            valuePart1 = valuePart2;
            valuePart2 = temp;
        }

        /** Contians the boolean value. */
        public function get value() : Boolean {
            var returnValue : Boolean = valuePart1 > valuePart2;

            //checkIntegrity();
            /* We are inlining this call for speed. */
            if (valuePart1+valuePart2 != checkSums[myID]) {
                dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.BOOLEAN_HACK_DETECTED));
            }
            /* End inlining */

            valuePart1++;
            valuePart2++;
            checkSums[myID] += 2;
            masterSum += 2;
            
            /* Unfortunately, there is a small downside to this approach.
             * There is a possibility that adding one to each value caused
             * one of them to overflow.  If so, then the value of the 
             * HPBoolean has just changed.  As such we need to change it back.
             * I hate using a branch here because it isn't very efficient,
             * but hopefully the branch predictor will do the correct thing
             * and always predict that the if condition will always be false.
             */
            if (returnValue != (valuePart1 > valuePart2)) {
                switchValues();
            }
            return returnValue;
        }

        public function set value(newval : Boolean) : void {
            //checkIntegrity();
            /* We had inlined this call for speed, but we're 
             * now modifying it to set a flag and pushing the
             * event dispatch until later to avoid infinite
             * loops in the event that an HP variable is set
             * inside of a HackDetected event handler for
             * that same variable. */
            var hackDetected : Boolean =
                (valuePart1+valuePart2 != checkSums[myID]);

            masterSum -= checkSums[myID];
            valuePart1 = Math.random()*uint.MAX_VALUE;
            valuePart2 = Math.random()*uint.MAX_VALUE;
            if (newval != (valuePart1 > valuePart2)) {
                switchValues();
            } // Make sure the value is correct.
            checkSums[myID] = valuePart1 + valuePart2;
            masterSum += checkSums[myID];
            if (hackDetected) {
                dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.BOOLEAN_HACK_DETECTED));
            }
        }

        /** Although each HPInt is checked each time it is read or
            written, this function can be used to check that it hasn't
            been modified at other times.  Calling this is never necessary. */
        public function checkIntegrity() : Boolean {
            /* This function has been inlined above.  If any changes are
             * made here, they should also be made to the getter and setter
             * for value. */
            if (valuePart1+valuePart2 != checkSums[myID]) {
                dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.BOOLEAN_HACK_DETECTED));
                return false;
            } else {
                return true;
            }
        }

        /** Used to verify the master checksum for HPBoolean.
            This should be called every once and a while if you
            want to be certain that freezing attacks are not occuring. */
        public static function verifyAll() : Boolean {
            var total : uint = 0;
            for each (var sum:uint in checkSums) {
                total += sum;
            }
            if (total != masterSum) {
                aHackProofBoolean.dispatchEvent(new HackDetectedEvent
                              (HackDetectedEvent.BOOLEAN_HACK_DETECTED));
                return false;
            } else {
                return true;
            }
        }
    }
}
