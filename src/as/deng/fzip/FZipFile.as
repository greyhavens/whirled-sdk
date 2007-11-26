/*
 * Copyright (C) 2006 Claus Wahlers and Max Herkender
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

package deng.fzip
{
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.utils.*;

	/**
	 * Represents a file contained in a ZIP archive loaded by FZip.
	 */		
	public class FZipFile
	{
		private var _versionHost:int = -1;
		private var _versionNumber:String = "";
		private var _compressionMethod:int = -1;
		private var _encrypted:Boolean = false;
		private var _implodeDictSize:int = -1;
		private var _implodeShannonFanoTrees:int = -1;
		private var _deflateSpeedOption:int = -1;
		private var _hasDataDescriptor:Boolean = false;
		private var _hasCompressedPatchedData:Boolean = false;
		private var _date:Date;
		private var _crc32:uint;
		private var _hasAdler32:Boolean = false;
		private var _adler32:uint;
		private var _sizeCompressed:uint = 0;
		private var _sizeUncompressed:uint = 0;
		private var _sizeFilename:uint = 0;
		private var _sizeExtra:uint = 0;
		private var _filename:String = "";
		private var _filenameEncoding:String;
		private var _extraFields:Dictionary;
		private var _content:*;

		private var isCompressed:Boolean = false;
		private var parseState:Namespace = fileHead;

		// load states
		private namespace idle;
		private namespace fileHead;
		private namespace fileHeadExt;
		private namespace fileContent;
		
		// compression methods
		/**
		 * @private
		 */		
		public static const COMPRESSION_NONE:int = 0;
		/**
		 * @private
		 */		
		public static const COMPRESSION_SHRUNK:int = 1;
		/**
		 * @private
		 */		
		public static const COMPRESSION_REDUCED_1:int = 2;
		/**
		 * @private
		 */		
		public static const COMPRESSION_REDUCED_2:int = 3;
		/**
		 * @private
		 */		
		public static const COMPRESSION_REDUCED_3:int = 4;
		/**
		 * @private
		 */		
		public static const COMPRESSION_REDUCED_4:int = 5;
		/**
		 * @private
		 */		
		public static const COMPRESSION_IMPLODED:int = 6;
		/**
		 * @private
		 */		
		public static const COMPRESSION_TOKENIZED:int = 7;
		/**
		 * @private
		 */		
		public static const COMPRESSION_DEFLATED:int = 8;
		/**
		 * @private
		 */		
		public static const COMPRESSION_DEFLATED_EXT:int = 9;
		/**
		 * @private
		 */		
		public static const COMPRESSION_IMPLODED_PKWARE:int = 10;

		/**
		 * @private
		 */		
		private static var HAS_INFLATE:Boolean = testInflate();
		/**
		 * @private
		 */		
		private static function testInflate():Boolean {
			var ret:Boolean = false;
			try {
				var ba:ByteArray = new ByteArray();
				ba.uncompress("deflate");
				ret = true;
			}
			catch(e:Error) {}
			return ret;
		}
		
		/**
		 * Constructor
		 */		
		public function FZipFile(filenameEncoding:String = "utf-8") {
			_filenameEncoding = filenameEncoding;
			_extraFields = new Dictionary();
		}
		
		/**
		 * The ZIP specification version supported by the software 
		 * used to encode the file.
		 */
		public function get versionNumber():String {
			return _versionNumber;
		}
		
		/**
		 * The Date and time the file was created.
		 */
		public function get date():Date {
			return _date;
		}
		
		/**
		 * The size of the compressed file (in bytes).
		 */
		public function get sizeCompressed():uint {
			return _sizeCompressed;
		}
		
		/**
		 * The size of the uncompressed file (in bytes).
		 */
		public function get sizeUncompressed():uint {
			return _sizeUncompressed;
		}
		
		/**
		 * The file name (including relative path).
		 */
		public function get filename():String {
			return _filename;
		}
		
		/**
		 * The raw file. 
		 */
		public function get content():ByteArray {
			if(isCompressed) {
				_content.position = 0;
				_content.uncompress();
				_content.position = 0;
				isCompressed = false;
			}
			return _content;
		}
		
		/**
		 * Gets the files content as string.
		 * 
		 * @param recompress If <code>true</code>, the raw file content
		 * is recompressed after decoding the string.
		 * 
		 * @param charset The character set used for decoding.
		 * 
		 * @return The file as string.
		 */
		public function getContentAsString(recompress:Boolean = true, charset:String = "utf-8"):String {
			if(isCompressed) {
				_content.position = 0;
				_content.uncompress();
			}
			_content.position = 0;
			var str:String;
			// Is readMultiByte completely trustworthy with utf-8?
			// For now, readUTFBytes will take over.
			if(charset == "utf-8") {
				str = _content.readUTFBytes(_content.bytesAvailable);
			} else {
				str = _content.readMultiByte(_content.bytesAvailable, charset);
			}
			_content.position = 0;
			if(isCompressed) {
				if(recompress) {
					_content.compress();
					_content.position = 0;
				} else {
					isCompressed = true;
				}
			}
			return str;
		}


		/**
		 * @private
		 */		
		internal function parse(stream:IDataInput):Boolean {
			while (stream.bytesAvailable && parseState::parse(stream));
			return (parseState === idle);
		}

		/**
		 * @private
		 */		
		idle function parse(stream:IDataInput):Boolean {
			return false;
		}

		/**
		 * @private
		 */		
		fileHead function parse(stream:IDataInput):Boolean {
			if(stream.bytesAvailable >= 30) {
				parseHead(stream);
				if(_sizeFilename + _sizeExtra > 0) {
					parseState = fileHeadExt;
				} else {
					parseState = fileContent;
				}
				return true;
			}
			return false;
		}

		/**
		 * @private
		 */		
		fileHeadExt function parse(stream:IDataInput):Boolean {
			if(stream.bytesAvailable >= _sizeFilename + _sizeExtra) {
				parseHeadExt(stream);
				parseState = fileContent;
				return true;
			}
			return false;
		}
		
		/**
		 * @private
		 */		
		fileContent function parse(stream:IDataInput):Boolean {
			if(_hasDataDescriptor) {
				// Data descriptors are not supported
				parseState = idle;
				throw new Error("Data descriptors are not supported.");
			} else if(_sizeCompressed == 0) {
				// This entry has no file attached
				parseState = idle;
			} else if(stream.bytesAvailable >= _sizeCompressed) {
				parseContent(stream);
				parseState = idle;
			} else {
				return false;
			}
			return true;
		}

		/**
		 * @private
		 */		
		protected function parseHead(data:IDataInput):void {
			var vSrc:uint = data.readUnsignedShort();
			_versionHost = vSrc >> 8;
			_versionNumber = Math.floor((vSrc & 0xff) / 10) + "." + ((vSrc & 0xff) % 10);
			var flag:uint = data.readUnsignedShort();
			_compressionMethod = data.readUnsignedShort();
			_encrypted = (flag & 0x01) !== 0;
			_hasDataDescriptor = (flag & 0x08) !== 0;
			_hasCompressedPatchedData = (flag & 0x20) !== 0;
			if ((flag & 800) !== 0) {
				_filenameEncoding = "utf-8";
			}
			if(_compressionMethod === COMPRESSION_IMPLODED) {
				_implodeDictSize = (flag & 0x02) !== 0 ? 8192 : 4096;
				_implodeShannonFanoTrees = (flag & 0x04) !== 0 ? 3 : 2;
			} else if(_compressionMethod === COMPRESSION_DEFLATED) {
				_deflateSpeedOption = (flag & 0x06) >> 1;
			}
			var msdosTime:uint = data.readUnsignedShort();
			var msdosDate:uint = data.readUnsignedShort();
			var sec:int = (msdosTime & 0x001f);
			var min:int = (msdosTime & 0x07e0) >> 5;
			var hour:int = (msdosTime & 0xf800) >> 11;
			var day:int = (msdosDate & 0x001f);
			var month:int = (msdosDate & 0x01e0) >> 5;
			var year:int = ((msdosDate & 0xfe00) >> 9) + 1980;
			_date = new Date(year, month - 1, day, hour, min, sec, 0);
			_crc32 = data.readUnsignedInt();
			_sizeCompressed = data.readUnsignedInt();
			_sizeUncompressed = data.readUnsignedInt();
			_sizeFilename = data.readUnsignedShort();
			_sizeExtra = data.readUnsignedShort();
		}
		
		/**
		 * @private
		 */		
		protected function parseHeadExt(data:IDataInput):void {
			if (_filenameEncoding == "utf-8") {
				_filename = data.readUTFBytes(_sizeFilename);// Fixes a bug in some players
			} else {
				_filename = data.readMultiByte(_sizeFilename, _filenameEncoding);
			}
			var bytesLeft:uint = _sizeExtra;
			while(bytesLeft > 4) {
				var headerId:uint = data.readUnsignedShort();
				var dataSize:uint = data.readUnsignedShort();
				if(dataSize > bytesLeft) {
					throw new Error("Parse error in file " + _filename + ": Extra field data size too big.");
				}
				if(headerId === 0xdada && dataSize === 4) {
					_adler32 = data.readUnsignedInt();
					_hasAdler32 = true;
				} else if(dataSize > 0) {
					var extraBytes:ByteArray = new ByteArray();
					data.readBytes(extraBytes, 0, dataSize);
					_extraFields[headerId] = extraBytes;
				}
				bytesLeft -= dataSize + 4;
			}
			if(bytesLeft > 0) {
				data.readBytes(new ByteArray(), 0, bytesLeft);
			}
		}

		/**
		 * @private
		 */		
		protected function parseContent(data:IDataInput):void {
			_content = new ByteArray();
			_content.endian = Endian.BIG_ENDIAN;
			if(_compressionMethod === COMPRESSION_DEFLATED && !_encrypted) {
				if(HAS_INFLATE) {
					// Adobe Air supports inflate decompression.
					// If we got here, this is an Air application
					// and we can decompress without using the Adler32 hack.
					data.readBytes(_content, 0, _sizeCompressed);
					_content.uncompress(CompressionAlgorithm.DEFLATE);
					_content.position = 0;
				} else if(_hasAdler32) {
					// Add header
					// CMF (compression method and info)
					_content.writeByte(0x78);
					// FLG (compression level, preset dict, checkbits)
					var flg:uint = (~_deflateSpeedOption << 6) & 0xc0;
					flg += 31 - (((0x78 << 8) | flg) % 31);
					_content.writeByte(flg);
					// Add raw deflate-compressed file
					data.readBytes(_content, 2, _sizeCompressed);
					// Add adler32 checksum
					_content.position = _content.length;
					_content.writeUnsignedInt(_adler32);
					// Flag as compressed
					isCompressed = true;
					// Reset fileposition to start-of-file
					_content.position = 0;
				} else {
					throw new Error("Adler32 checksum not found.");
				}
			} else if(_compressionMethod == COMPRESSION_NONE) {
				data.readBytes(_content, 0, _sizeCompressed);
				isCompressed = false;
			} else {
				throw new Error("Compression method " + _compressionMethod + " is not supported.");
			}
		}
	}
}