#include <StringConstants.au3>

Global Const $NAN = 'NaN'
Global Enum $ASCII_HYPHEN = 45, $ASCII_0 = 48, $ASCII_1, $ASCII_2, $ASCII_3, $ASCII_4, $ASCII_5, $ASCII_6, $ASCII_7, $ASCII_8, $ASCII_9

; Based on the .NET approach, kind of.
Example()

Func Example()
	ConsoleWrite('Int_Parse() = ' & Int_Parse('-100') & @CRLF) ; Returns an integer data type.
	ConsoleWrite('Int_Parse() = ' & Int_Parse('One') & @CRLF) ; Returns NaN.

	Local $iNumber ; This will get set to 0 by default in the TryParse function.
	If Int_TryParse('99', $iNumber) Then
		ConsoleWrite('$iNumber = ' & $iNumber & @CRLF)
	Else
		ConsoleWrite('It was not an integer.' & @CRLF)
	EndIf

	If Int_TryParse('Nine', $iNumber) Then
		ConsoleWrite('$iNumber = ' & $iNumber & @CRLF)
	Else
		ConsoleWrite('It was not an integer. $iNumber = ' & $iNumber & @CRLF)
	EndIf
EndFunc   ;==>Example

; Returns the integer parsed or NaN.
Func Int_Parse($sValue)
	Local $iValue
	Return (Int_TryParse($sValue, $iValue) ? $iValue : $NAN) ; This is just a wrapper around Int_TryParse().
EndFunc   ;==>Int_Parse

; Returns true or false if the string was parsed as an integer and sets the ByRef variable to either zero (if on failure) or the integer parsed.
Func Int_TryParse($sValue, ByRef $iValue)
	$iValue = 0 ; Set the out parameter.
	Local $bIsParse = False
	If Not (StringStripWS($sValue, $STR_STRIPALL) == '') Or Not ($sValue == Null) Then
		$bIsParse = True

		Local $aChars = StringToASCIIArray($sValue), _
				$iIterator = 1
		For $i = UBound($aChars) - 1 To 0 Step -1 ; Reverse through the loop.
			If $aChars[$i] < $ASCII_0 Or $aChars[$i] > $ASCII_9 Then
				If $i = 0 And $aChars[$i] = $ASCII_HYPHEN Then ; If the char is - (ASCII - $ASCII_HYPHEN (45)) then treat as a negative value.
					$iValue *= -1
				Else ; If not the end of the char array then it's not a number.
					$bIsParse = False
					$iValue = 0 ; Set the out parameter.
				EndIf
				ExitLoop
			EndIf

			If $aChars[$i] > 0 Then
				$iValue += ($aChars[$i] - $ASCII_0) * $iIterator
			EndIf
			$iIterator *= 10
		Next
	EndIf
	Return $bIsParse
EndFunc   ;==>Int_TryParse
