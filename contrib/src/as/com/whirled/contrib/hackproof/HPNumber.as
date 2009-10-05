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
// HPNumber - a class which will hold a floating-point value and is
// resistant to simple searching, modification and freezing attacks
// from Cheat Engine or other similar programs.

package com.whirled.contrib.hackproof {

    import flash.events.EventDispatcher;

    import flash.utils.ByteArray;

    /**
     * This class holds a floating point number value. 
     * From the point of view
     * of the programmer, it should work just like a normal Number,
     * except that it needs to be accessed using the "value" member
     * and it will dispatch a HackDetected event if the value is
     * tampered with externally.
     *
     * <p> Also, HPNumbers will not have all
     * of their parts garbage collected, so if a large number of
     * them are used in a program, memory leakage will occur.
     * If you need to use HPNumbers in disposable objects, it is
     * recommended that you use the HPReuseManager to allocate
     * and deallocate HPNumbers as needed.
     *
     * <p> Under the hood, HPNumber is actually stored using two
     * HPInts.
     */
    public class HPNumber extends EventDispatcher {
        
        private var valuePart1 : HPInt;
        private var valuePart2 : HPInt;

        private var ba : ByteArray;

        /** Creates a new HPNumber with the default value of 0. */
        public function HPNumber() {
            valuePart1 = new HPInt();
            valuePart2 = new HPInt();
            ba = new ByteArray();
            valuePart1.addEventListener(HackDetectedEvent.
                                             UINT_HACK_DETECTED,hackFound);
            valuePart2.addEventListener(HackDetectedEvent.
                                             UINT_HACK_DETECTED,hackFound);
            value = 0;
        }

        /** Contains the floating-point number value. */
        public function get value() : Number {
            ba.position = 0;
            ba.writeInt(valuePart1.value);
            ba.writeInt(valuePart2.value);
            ba.position = 0;
            return ba.readDouble();
        }

        public function set value(newval : Number) : void {
            ba.position = 0;
            ba.writeDouble(newval);
            ba.position = 0;
            valuePart1.value = ba.readInt();
            valuePart2.value = ba.readInt();
        }

        /** Used to verify the master checksum for HPNumber.
            This actually just calls HPInt.verifyAll(). */
        public static function verifyAll() : Boolean {
            return HPInt.verifyAll();
        }

        private function hackFound(e : HackDetectedEvent) : void {
            dispatchEvent(new HackDetectedEvent
                          (HackDetectedEvent.NUMBER_HACK_DETECTED));    
        }
    }
}
