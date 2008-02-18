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
