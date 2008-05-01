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

package com.whirled.contrib {

import flash.media.Camera;

import com.threerings.util.Config;

import com.whirled.EntityControl;

/**
 * Handles saving the user's preferred camera to the flash player's local persistent memory.
 */
public class PreferredCamera
{
    /**
     * Return this user's preferred Camera, or the default Camera, or null.
     */
    public static function getPreferredCamera (ctrl :EntityControl) :Camera
    {
        var prefCam :String = getPreferredCameraName();
        if (prefCam != null) {
            // find the preferred camera in the list of cameras
            var index :int = Camera.names.indexOf(prefCam);
            if (index != -1) {
                return ctrl.getCamera(String(index));
            }
        }
        return ctrl.getCamera();
    }

    /**
     * Get the name of this user's preferred camera, or null.
     * Note: this camera may or may not be a valid camera currently.
     */
    public static function getPreferredCameraName () :String
    {
        return getConfig().getValue("camera", null) as String;
    }

    /**
     * Set this user's preferred camera.
     *
     * @param cameraName the 'name' property of the Camera to save as the user's
     * preferred Camera, or null to unset the preferred camera.
     */
    public static function setPreferredCamera (cameraName :String) :void
    {
        if (cameraName != null) {
            getConfig().setValue("camera", cameraName);
        } else {
            getConfig().remove("camera");
        }
    }

    private static function getConfig () :Config
    {
        return new Config("prefCamera");
    }
}
}
