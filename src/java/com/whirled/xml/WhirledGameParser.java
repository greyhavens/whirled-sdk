//
// $Id$

package com.whirled.xml;

import com.threerings.ezgame.xml.GameParser;

import com.whirled.data.WhirledGameDefinition;

/**
 * Customizes the EZ game parser for the Whirled test server.
 */
public class WhirledGameParser extends GameParser
{
    @Override // from GameParser
    protected String getGameDefinitionClass ()
    {
        return WhirledGameDefinition.class.getName();
    }
}
