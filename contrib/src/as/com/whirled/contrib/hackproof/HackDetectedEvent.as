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
// HackDetectedEvent - a event which is thrown when other classes
// detect modification and freezing attacks
// from Cheat Engine or other similar programs.

package com.whirled.contrib.hackproof {

    import flash.events.Event;

    /** This is the event thrown when an HPInt, HPUInt, HPNumber,
     * or HPBoolean either has their value changed or frozen. */
    public class HackDetectedEvent extends Event {

        /** Indicates a hack against an HPInt, does not specify
            which HPInt or which attack. */
        public static const INT_HACK_DETECTED:String = "intHack";
        /** Indicates a hack against an HPUInt, does not specify
            which HPUInt or which attack. */
        public static const UINT_HACK_DETECTED:String = "uintHack";
        /** Indicates a hack against an HPBoolean, does not specify
            which HPBoolean or which attack. */
        public static const BOOLEAN_HACK_DETECTED:String = "booleanHack";
        /** Indicates a hack against an HPNumber, does not specify
            which HPNumber or which attack. */
        public static const NUMBER_HACK_DETECTED:String = "numberHack";
        /*      public static const SCALED_NUMBER_HACK_DETECTED:String = 
            "scaledNumberHack";
            public static const OBJECT_HACK_DETECTED:String = "objectHack";*/

        public function HackDetectedEvent(eventName:String) {
            super(eventName,true,false);
        }
    }
}
