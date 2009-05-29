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
// HPReuseManager - a class which allows for the reuse of HackProof datatypes
// to avoid leaking memory

package com.whirled.contrib.hackproof {

    /** This is a class which aids in the management of using and reusing
     * HPInts, HPUInts, HPBooleans, and HPNumbers.  This is available because
     * the garbage collection for those classes is not complete.  As a result,
     * creating them for use in temporary objects can leak memory and
     * slow things down.
     *
     * <p> Use of this class is not mandatory.
     * If you are only using a small number of HackProof variables or only
     * using them in permanent objects,
     * use of this class is not needed. */
    public class HPReuseManager {

        static protected var hpints : Array = new Array();
        static protected var hpuints : Array = new Array();
        static protected var hpbooleans : Array = new Array();
        static protected var hpnumbers : Array = new Array();

        /** Returns a recycled HPInt, or if none is available, creates
            a new one.  In either case, you always get an HPInt you
            can use. */
        public static function getHPInt() : HPInt {
            if (hpints.length != 0) {
                return hpints.pop();
            } else {
                return new HPInt();
            }
        }

        /** Returns an HPInt to the pool for future reuse.  If you are
            calling this be completely certain that you aren't going
            to try to use it again. */
        public static function releaseHPInt(hpi : HPInt) : void {
            hpints.push(hpi);
        }

        /** Returns a recycled HPUInt, or if none is available, creates
            a new one.  In either case, you always get an HPUInt you
            can use. */
        public static function getHPUInt() : HPUInt {
            if (hpuints.length != 0) {
                return hpuints.pop();
            } else {
                return new HPUInt();
            }
        }

        /** Returns an HPUInt to the pool for future reuse.  If you are
            calling this be completely certain that you aren't going
            to try to use it again. */
        public static function releaseHPUInt(hpui : HPUInt) : void {
            hpuints.push(hpui);
        }

        /** Returns a recycled HPNumber, or if none is available, creates
            a new one.  In either case, you always get an HPNumber you
            can use. */
        public static function getHPNumber() : HPNumber {
            if (hpnumbers.length != 0) {
                return hpnumbers.pop();
            } else {
                return new HPNumber();
            }
        }

        /** Returns an HPNumber to the pool for future reuse.  If you are
            calling this be completely certain that you aren't going
            to try to use it again. */
        public static function releaseHPNumber(hpn : HPNumber) : void {
            hpnumbers.push(hpn);
        }

        /** Returns a recycled HPBoolean, or if none is available, creates
            a new one.  In either case, you always get an HPBoolean you
            can use. */
        public static function getHPBoolean() : HPBoolean {
            if (hpbooleans.length != 0) {
                return hpbooleans.pop();
            } else {
                return new HPBoolean();
            }
        }

        /** Returns an HPBoolean to the pool for future reuse.  If you are
            calling this be completely certain that you aren't going
            to try to use it again. */
        public static function releaseHPBoolean(hpb : HPBoolean) : void {
            hpbooleans.push(hpb);
        }
    }
}

        
