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
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.sound {

import flash.media.Sound;
import flash.utils.ByteArray;

import com.whirled.contrib.cache.DataSource;

/**
 * This class will take sounds from a SoundFactory and supply the decompressed wave bytes in
 * ByteArray form as a DataSource.  This class requires Flash 10.
 */
public class SoundBytesDataSource
    implements DataSource
{
    public function SoundBytesDataSource (factory :SoundFactory)
    {
        _factory = factory;
    }

    // from DataSource
    public function getObject (name :String) :Object
    {
        var sound :Sound = _factory.getSound(name);
        if (sound == null) {
            return null;
        }

        var startPosition :int = 0;
        var bytes :ByteArray = new ByteArray();
        while (sound.extract(bytes, SAMPLES_PER_LOOP, startPosition) > 0) {
            startPosition = -1;
        }
        return bytes;
    }

    protected var _factory :SoundFactory;

    protected static const SAMPLES_PER_LOOP :int = 8192;
}
}
