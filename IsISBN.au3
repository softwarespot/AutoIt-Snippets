#include <StringConstants.au3>

Example()

Func Example()
	Local Const $iType10 = 10, $iType13 = 13

	; 10-digit ISBN numbers.
	PrintISBN('ISBN0-9752298-0-X', $iType10, True) ; Is a 10-digit ISBN number.
	PrintISBN('ISBN0-9752298-0-4', $iType10, False) ; Is not a 10-digit ISBN number.
	PrintISBN('ISBN1-84356-028-3', $iType10, True) ; Is a 10-digit ISBN number.
	PrintISBN('ISBN0-19-852663-6', $iType10, True) ; Is a 10-digit ISBN number.
	PrintISBN('ISBN 1 86197 271 7', $iType10, True) ; Is a 10-digit ISBN number.
	PrintISBN('ISBN 4 86197 271 7', $iType10, False) ; Is not a 10-digit ISBN number.

	ConsoleWrite(@CRLF) ; Empty line.

	; 13-digit ISBN numbers.
	PrintISBN('ISBN-13: 978-0-306-40615-7', $iType13, True) ; Is a 13 digit ISBN number.
	PrintISBN('ISBN-13: 978-1-86197-876-9', $iType13, True) ; Is a 13 digit ISBN number.
	PrintISBN('ISBN-13: 978-1-86197-876-8', $iType13, False) ; Is not a 13 digit ISBN number.
EndFunc   ;==>Example

Func PrintISBN($sISBN, $iType, $bExpected)
	ConsoleWrite($sISBN & ' => ' & IsISBN($sISBN, $iType) & ' [Expected: ' & $bExpected & ']' & @CRLF)
EndFunc   ;==>PrintISBN

; #FUNCTION# ====================================================================================================================
; Name ..........: IsISBN
; Description ...: Check if a string contains a valid ISBN number.
; Syntax ........: IsISBN($sISBN, $iType)
; Parameters ....: $sISBN               - A string value containing an ISBN number.
;                  $iType               - An integer value or either 10 or 13, depending on the ISBN type to check.
; Return values .: Success: True
;                  Failure: False and sets @error to non-zero on error:
;					1 = String was empty or contained only whitespace.
;					2 = Type was incorrect.
;					3 = StringToASCIIArray() was empty.
; Author ........: guinness
; Link ..........: https://en.wikipedia.org/wiki/International_Standard_Book_Number
; Example .......: Yes
; ===============================================================================================================================
Func IsISBN($sISBN, $iType)
	If Not StringStripWS($sISBN, $STR_STRIPALL) Then Return SetError(1, 0, False)

	Local Const $iType10 = 10, $iType13 = 13
	$iType = Int($iType)
	If $iType <> $iType10 And $iType <> $iType13 Then Return SetError(2, 0, False)

	Local $aArray = StringToASCIIArray($sISBN)
	Local $iLength = UBound($aArray) - 1
	If $iLength < 0 Then Return SetError(3, 0, False)

	Local Const $iNine = 57, $iZero = 48
	Local $iCounter = 0, $iSum = 0
	Switch $iType
		Case $iType10
			If $aArray[$iLength] = 88 Or $aArray[$iLength] = 120 Then
				$iLength -= 1
				$iSum = 10
			EndIf

			$iCounter = 10
			For $i = 0 To $iLength
				If $aArray[$i] < $iZero Or $aArray[$i] > $iNine Then
					ContinueLoop
				EndIf
				$iSum += ($aArray[$i] - $iZero) * $iCounter
				$iCounter -= 1
			Next
			Return Mod($iSum, 11) = 0 ; Divisible by 11.

		Case $iType13
			Local Const $iOne = 1, $iThree = 3
			$iCounter = $iOne
			For $i = 0 To $iLength
				If $aArray[$i] < $iZero Or $aArray[$i] > $iNine Then
					ContinueLoop
				EndIf
				$iSum += ($aArray[$i] - $iZero) * $iCounter
				$iCounter = ($iCounter = $iOne) ? $iThree : $iOne
			Next
			Return Mod($iSum, 10) = 0 ; Divisible by 10.
	EndSwitch

	Return False
EndFunc   ;==>IsISBN
