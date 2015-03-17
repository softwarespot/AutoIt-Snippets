Global Enum Step *2 $EXTRACTLINE_EMPTY, $EXTRACTLINE_INVALIDFORMAT, $EXTRACTLINE_LESSTHANONE, $EXTRACTLINE_OUTOFBOUNDS

Example()

Func Example()
	Local $sText = ''
	For $i = 1 To 10
		$sText &= 'Line ' & $i & ': With some extra characters at the end.' & @CRLF
	Next

	; Valid examples:
	PrintLine($sText, 10) ; Second to last line
	PrintLine($sText, 1) ; First line
	PrintLine($sText, 11) ; Last line
	PrintLine($sText, Random(2, 9, 1)) ; Random line

	; @error examples:
	PrintLine(Null, 9) ; Null string
	PrintLine($sText, 'Nine') ; Invalid number
	PrintLine($sText, -100) ; Invalid line number
	PrintLine($sText, 100) ; Out of bounds
EndFunc   ;==>Example

; Not part of the ExtractLine() function
Func PrintLine($sValue, $iLine)
	Local $bIsIncludeEOL = Random(0, 1, 1) = 1
	Local $sLine = ExtractLine($sValue, $iLine, $bIsIncludeEOL)
	ConsoleWrite('Line: ' & $iLine & ', IncludeEOL: ' & $bIsIncludeEOL & ', ' & '@error: ' & @error & ', Extracted: ' & $sLine & @CRLF)
EndFunc   ;==>PrintLine

Func ExtractLine($sValue, $iLine, $bIncludeEOL = False) ; NOTE: This assumes line endings are \r\n, especially if you're using windows.
	If $sValue = Null Or $sValue == '' Then
		Return SetError($EXTRACTLINE_EMPTY, 0, '')
	EndIf
	If IsString($iLine) Then ; Check if the line number is a string
		If Not StringIsDigit($sValue) Then ; The user didn't pass a line number
			Return SetError($EXTRACTLINE_INVALIDFORMAT, 0, '')
		EndIf
		$iLine = Int($iLine) ; Parse as an integer datatype
	EndIf
	
	Local Const $eSTART_LINE = 1
	If $iLine < $eSTART_LINE Then ; Only line numbers 1 and above are supported
		Return SetError($EXTRACTLINE_LESSTHANONE, 0, '')
	EndIf
	If $bIncludeEOL = Default Or Not IsBool($bIncludeEOL) Then ; If include the EOL is default or not a boolean datatype then set as false
		$bIncludeEOL = False
	EndIf

	Local Const $eEOLLENGTH = StringLen(@CRLF) ; Constant for the length of \r\n (which should be 2)

	Local $iBefore = $eSTART_LINE
	If $iLine > $eSTART_LINE Then
		$iBefore = StringInStr($sValue, @CRLF, Default, $iLine - 1) ; Find the @CRLF before
		$iBefore += $eEOLLENGTH ; Optionally include the EOL
	EndIf

	Local $iAfter = StringInStr($sValue, @CRLF, Default, $iLine) ; Find the @CRLF after
	If $iAfter >= $eSTART_LINE Then
		$iAfter += ($bIncludeEOL ? $eEOLLENGTH : 0) ; Optionally include the EOL
	EndIf

	If $iAfter = 0 And $iBefore = $eEOLLENGTH Then
		Return SetError($EXTRACTLINE_OUTOFBOUNDS, 0, '')
	EndIf

	Return StringMid($sValue, $iBefore, $iAfter - $iBefore) ; Get the line using the before index and then calculating the length
EndFunc   ;==>ExtractLine
