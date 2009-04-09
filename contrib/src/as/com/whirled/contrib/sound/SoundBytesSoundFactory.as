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

import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.utils.ByteArray;

import com.whirled.contrib.cache.DataSource;

/**
 * This class will take bytes from a DataSource and supply a Sound that will play those bytes.
 * This class requires Flash 10.
 */
public class SoundBytesSoundFactory
    implements SoundFactory
{
    public function SoundBytesSoundFactory (source :DataSource)
    {
        _source = source;
    }

    // from SoundFactory
    public function getSound (name :String) :Sound
    {
        var bytes :ByteArray = _source.getObject(name) as ByteArray;
        if (bytes == null) {
            return null;
        }

        var offset :int = 0;
        var sound :Sound = new Sound();
        var provideSound :Function;
        provideSound = function (event :SampleDataEvent) :void {
            if (offset + SAMPLE_EVENT_BYTE_SIZE <= bytes.length) {
                event.data.writeBytes(bytes, offset, SAMPLE_EVENT_BYTE_SIZE);
                offset += SAMPLE_EVENT_BYTE_SIZE;

            } else {
                event.data.writeBytes(bytes, offset, bytes.length - offset);
                sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, provideSound);
            }
        }
        sound.addEventListener(SampleDataEvent.SAMPLE_DATA, provideSound);
        return sound;
    }

    protected var _source :DataSource;

    // Each sample is 8 bytes in length, and we want to provide chunks of 8192 samples, as
    // recommended in the docs
    protected static const SAMPLE_EVENT_BYTE_SIZE :int = 8192 * 8;
}
}
