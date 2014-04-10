#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

Example()

Func Example()
	Local $sEncoded = Rot13('Rotate this string.') ; Encode the string.
	MsgBox($MB_SYSTEMMODAL, '', 'Encoded: ' & $sEncoded)

	Local $sDecoded = Rot13($sEncoded) ; Decode the rotated string.
	MsgBox($MB_SYSTEMMODAL, '', 'Decoded: ' & $sDecoded)
EndFunc   ;==>Example

Func Rot13($sData)
	Local $aArray = StringSplit($sData, '', $STR_NOCOUNT), _
			$iChr = 0, _
			$sReturn = ''
	For $i = 0 To UBound($aArray) - 1
		$iChr = Asc($aArray[$i])
		If ($iChr >= 65 And $iChr <= 77) Or ($iChr >= 97 And $iChr <= 109) Then
			$sReturn &= Chr($iChr + 13)
		ElseIf ($iChr >= 78 And $iChr <= 90) Or ($iChr >= 110 And $iChr <= 122) Then
			$sReturn &= Chr($iChr - 13)
		Else
			$sReturn &= $aArray[$i]
		EndIf
	Next
	Return $sReturn
EndFunc   ;==>Rot13
