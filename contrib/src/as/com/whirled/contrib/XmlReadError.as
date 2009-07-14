package com.whirled.contrib {

public class XmlReadError extends Error
{
    public function XmlReadError (message :String = "", badXml :XML = null)
    {
        super(getErrString(message, badXml), 0);
    }

    protected static function getErrString (message :String, badXml :XML = null) :String
    {
        var errString :String = message;
        if (badXml != null) {
            errString += "\n" + badXml.toXMLString();
        }

        return errString;
    }
}

}
