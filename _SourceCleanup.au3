#include <Constants.au3>

Local $sData = FileRead(@ScriptFullPath)
_SourceCleanup($sData)
MsgBox($MB_SYSTEMMODAL, '', $sData)

; $iFlags = 1 Remove multi-comments (#cs or #comment-start & #ce or #comment-end)
; $iFlags = 2 Remove single-line comments (; Comment ... )
; $iFlags = 4 Strip all leading white space;
; $iFlags = 8 Strip all trailing white space.
; $iFlags = 16 Remove lines containing only @LF, @CR or @CRLF.
; $iFlags = 32 Remove lines containing only @LF, @CR, @CRLF or whitespace characters.
; $iFlags = 64 Remove #region or #endregion directives.
; $iFlags = 128 Remove strings between single and double quotes.
Func _SourceCleanup(ByRef $sData, $iFlags = Default) ; Regular expressions by DXRW4E & function layout by guinness.
	Local Enum Step *2 $eCLEANUP_MULTICOMMENTS, $eCLEANUP_SINGLECOMMENTS, $eCLEANUP_LEADINGWS, $eCLEANUP_TRAILINGWS, $eCLEANUP_EMPTYLINESONLY, _
			$eCLEANUP_STRIPEMPTYLINESPLUSWS, $eCLEANUP_REGIONS, $eCLEANUP_STRINGLITERALS
	If $iFlags = Default Then
		$iFlags = BitOR($eCLEANUP_MULTICOMMENTS, $eCLEANUP_SINGLECOMMENTS, $eCLEANUP_LEADINGWS, $eCLEANUP_TRAILINGWS, $eCLEANUP_EMPTYLINESONLY, _
				$eCLEANUP_STRIPEMPTYLINESPLUSWS, $eCLEANUP_REGIONS, $eCLEANUP_STRINGLITERALS)
	EndIf
	If BitAND($iFlags, $eCLEANUP_STRINGLITERALS) = $eCLEANUP_STRINGLITERALS Then
		; Strip string literals. By PhoenixXL. Topic: http://www.autoitscript.com/forum/topic/148546-regular-expression-strip-quoted-string-literals/
		$sData = StringRegExpReplace($sData, "([""']).*?\1", "''")
		$sData = StringRegExpReplace($sData, '["'']{2,}', "''") ; Strip multiple quotes. By PhoenixXL.
	EndIf
	If BitAND($iFlags, $eCLEANUP_MULTICOMMENTS) = $eCLEANUP_MULTICOMMENTS Then
		$sData = StringRegExpReplace(@CRLF & $sData & @CRLF, '(?is)(\n\h*#(?:cs|comments?-start)[^\n]*\n.*?\n\h*#(?:ce|comments?-end)[^\n]*)', @LF)
	EndIf
	If BitAND($iFlags, $eCLEANUP_SINGLECOMMENTS) = $eCLEANUP_SINGLECOMMENTS Then
		$sData = StringRegExpReplace(@CRLF & $sData & @CRLF, '\n\h*;[^\n]*', '')
		; Strip single line comments. By PhoenixXL. Topic: http://www.autoitscript.com/forum/topic/148540-find-all-words-starting-with/#entry1056292
		$sData = StringRegExpReplace($sData, '(?m)(;.*?$)', '') ; ';[^\n]*'
	EndIf
	If BitAND($iFlags, $eCLEANUP_LEADINGWS) = $eCLEANUP_LEADINGWS Then
		$sData = StringRegExpReplace($sData, '\n\h+', @LF)
	EndIf
	If BitAND($iFlags, $eCLEANUP_TRAILINGWS) = $eCLEANUP_TRAILINGWS Then
		$sData = StringRegExpReplace($sData, '\h+(?=\R)', '')
	EndIf
	If BitAND($iFlags, $eCLEANUP_EMPTYLINESONLY) = $eCLEANUP_EMPTYLINESONLY Then
		$sData = StringRegExpReplace($sData, '\n[\r\n]*\n', @LF)
	EndIf
	If BitAND($iFlags, $eCLEANUP_STRIPEMPTYLINESPLUSWS) = $eCLEANUP_STRIPEMPTYLINESPLUSWS Then
		$sData = StringRegExpReplace($sData, '\n\s*\n', @LF)
	EndIf
	If BitAND($iFlags, $eCLEANUP_REGIONS) = $eCLEANUP_REGIONS Then
		$sData = StringRegExpReplace($sData, '(?i)\n\h*(?:#region|#endregion)(?!\w)[^\n]*\n', @LF)
	EndIf
EndFunc   ;==>_SourceCleanup
