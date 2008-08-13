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

package com.whirled.contrib.platformer.display {

import flash.display.Shape;
import flash.display.Sprite;

import com.whirled.contrib.platformer.display.Metrics;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.util.SectionalIndex;

/**
 * A layer that is divided into sections which are dynamically added and removed from the display
 * tree depending on what's currently in the view.
 */
public class SectionalLayer extends PieceSpriteLayer
{
    public function SectionalLayer (secWidth :int, secHeight :int)
    {
        _sindex = new SectionalIndex(secWidth, secHeight);
    }

    public override function addPieceSprite (ps :PieceSprite) :void
    {
        ps.z = _count++;
        var p :Piece = ps.getPiece();
        var idx :int = _sindex.getSectionFromTile(p.x, p.y);
        if (_sections[idx] == null) {
            _sections[idx] = new Array();
        }
        //trace("adding piece: " + ps.getPiece() + " to section: " + idx);
        _sections[idx].push(ps);
    }

    public override function clear () :void
    {
        _sections = new Array();
    }

    public override function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        var section :int = getSectionFromCoord(nX, nY);
        if (section != _currentSection) {
            var sx :int = _sindex.getSectionX(section);
            var sy :int = _sindex.getSectionY(section);
            var sprite :Sprite = new Sprite();
            var sections :Array = new Array();
            var indices :Array = new Array();
            for (var xx :int = sx - 1; xx <= sx + 1; xx++) {
                if (!_sindex.validX(xx)) {
                    continue;
                }
                for (var yy :int = sy - 1; yy <= sy + 1; yy++) {
                    if (!_sindex.validY(yy)) {
                        continue;
                    }
                    var sec :Array = _sections[_sindex.getSectionIndex(xx, yy)];
                    if (sec != null) {
                        sections.push(sec);
                        indices.push(0);
                    }
                }
            }
            while (true) {
                var minZ :int = int.MAX_VALUE;
                var arr :int = 0;
                for (xx = 0; xx < sections.length; xx++) {
                    if (indices[xx] < sections[xx].length && sections[xx][indices[xx]].z < minZ) {
                        minZ = sections[xx][indices[xx]].z;
                        arr = xx;
                    }
                }
                if (minZ == int.MAX_VALUE) {
                    break;
                }
                sprite.addChild(sections[arr][indices[arr]]);
                indices[arr]++;
            }
            if (numChildren > 0) {
                removeChildAt(0);
            }
            addChildAt(sprite, 0);
            _currentSection = section;
        }
        super.update(nX, nY);
    }
    /*
            if (_currentSection == int.MIN_VALUE) {
                showSections(sx - 1, sy - 1, sx + 1, sy + 1);
            } else if (_currentSection != section) {
                var cx :int = getSectionX(_currentSection);
                var cy :int = getSectionY(_currentSection);
                if (Math.abs(cx - sx) > 1 || Math.abs(cy - sy) > 1) {
                    showSections(cx - 1, cy - 1, cx + 1, cy + 1, false);
                    showSections(sx - 1, sy - 1, sx + 1, sy + 1);
                } else {
                    if (cx < sx) {
                        showSections(cx - 1, cy - 1, cx - 1, cy + 1, false);
                        showSections(sx + 1, sy - 1, sx + 1, sy + 1);
                    } else if (cx > sx) {
                        showSections(cx + 1, cy - 1, cx + 1, cy + 1, false);
                        showSections(sx - 1, sy - 1, sx - 1, sy + 1);
                    }
                    if (cy < sy) {
                        showSections(cx - 1, cy - 1, cx + 1, cy - 1, false);
                        showSections(sx - 1, sy + 1, sx + 1, sy + 1);
                    } else if (cy > sy) {
                        showSections(cx - 1, cy + 1, cx + 1, cy + 1, false);
                        showSections(sx - 1, sy - 1, sx + 1, sy - 1);
                    }
                }
            }
            _currentSection = section;
        }
        super.update(nX, nY);
    }
    */

    protected function getSectionFromCoord (cx :Number, cy :Number) :int
    {
        return _sindex.getSectionFromTile(
                Math.floor(cx / Metrics.TILE_SIZE), Math.floor(cy / Metrics.TILE_SIZE));
    }

    protected function showSections (x1 :int, y1 :int, x2 :int, y2 :int, show :Boolean = true) :void
    {
        for (var yy :int = y1; yy <= y2; yy++) {
            if (!_sindex.validY(yy)) {
                continue;
            }
            for (var xx :int = x1; xx <= x2; xx++) {
                if (!_sindex.validX(xx)) {
                    continue;
                }
                var idx :int = _sindex.getSectionIndex(xx, yy);
                if (_sections[idx] != null) {
                    if (show) {
                        trace("showing section: " + idx);
                        addChild(_sections[idx]);
                    } else {
                        trace("hiding section: " + idx);
                        removeChild(_sections[idx]);
                    }
                }
            }
        }
    }

    /** Our sections. */
    protected var _sections :Array = new Array();

    protected var _count :int = 0;

    protected var _sindex :SectionalIndex;

    /** The current section we're in. */
    protected var _currentSection :int = int.MIN_VALUE;

}
}
