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
	If $sData == '' Then
		Return $sData
	EndIf
	Local $aArray = StringToASCIIArray($sData)
	For $i = 0 To UBound($aArray) - 1
		If ($aArray[$i] >= 65 And $aArray[$i] <= 77) Or ($aArray[$i] >= 97 And $aArray[$i] <= 109) Then
			$aArray[$i] += 13
		ElseIf ($aArray[$i] >= 78 And $aArray[$i] <= 90) Or ($aArray[$i] >= 110 And $aArray[$i] <= 122) Then
			$aArray[$i] -= 13
		EndIf
	Next
	Return StringFromASCIIArray($aArray)
EndFunc   ;==>Rot13
