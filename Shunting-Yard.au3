#include <StringConstants.au3>

#include "Stack.au3"

Example()

Func Example()
	; Create postfix notation (RPN) from infix notation.
	ConsoleWrite(StringFormat('%s: == %s', '3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3', ShuntingYard_Parse('3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3')) & @CRLF)
	ConsoleWrite('Reference: 3 4 2 * 1 5 - 2 3 ^ ^ / +' & @CRLF)

	ConsoleWrite(@CRLF); A new line.

	ConsoleWrite(StringFormat('%s: == %s', '3 + 4', ShuntingYard_Parse('3 + 4')) & @CRLF)
	ConsoleWrite('Reference: 3 4 +' & @CRLF)

	ConsoleWrite(@CRLF); A new line.

	; Expression from: http://www.slideshare.net/grahamwell/shunting-yard.

	ConsoleWrite(StringFormat('%s: == %s', '2 + (3 * (8 - 4))', ShuntingYard_Parse('2 + (3 * (8 - 4))')) & @CRLF)
	ConsoleWrite('Reference: 2 3 8 4 - * +' & @CRLF)

	ConsoleWrite(@CRLF); A new line.

	; Calculate postfix notation (RPN) examples.
	ConsoleWrite('3 4 + == ' & ShuntingYard_Calculate('3 4 +') & @CRLF)
	ConsoleWrite('3 4 2 * 1 5 - 2 3 ^ ^ / + == ' & ShuntingYard_Calculate('3 4 2 * 1 5 - 2 3 ^ ^ / +') & @CRLF)
	ConsoleWrite('2 3 8 4 - * + == ' & ShuntingYard_Calculate('2 3 8 4 - * +') & @CRLF)
EndFunc   ;==>Example

Func ShuntingYard_Calculate($sExpression)
	Local $aChar = StringSplit($sExpression, '', $STR_NOCOUNT), _
			$hStack = Stack(), _ ; Create a stack to push/pop to.
			$iNumber1 = 0, $iNumber2 = 2, _
			$sDigits = '', _ ; Hold string digits e.g. in case there are numbers greater than 1 digit long.
			$sToken = '' ; Token.
	For $i = 0 To UBound($aChar) - 1
		$sToken = $aChar[$i]

		If StringIsDigit($sToken) Then
			$sDigits &= $sToken
		ElseIf __ShuntingYard_IsOperator($sToken) Then
			$iNumber2 = Stack_Pop($hStack)
			$iNumber1 = Stack_Pop($hStack)
			Stack_Push($hStack, __ShuntingYard_Eval($iNumber1, $iNumber2, $sToken))
		ElseIf StringIsSpace($sToken) And Not ($sDigits == '') Then
			If StringIsInt($sDigits) Or StringIsFloat($sDigits) Then
				$iNumber1 = Number($sDigits)
				Stack_Push($hStack, $iNumber1)
			EndIf
			$sDigits = ''
			$iNumber1 = 0
		EndIf
	Next
	Return Stack_Pop($hStack)
EndFunc   ;==>ShuntingYard_Calculate

Func ShuntingYard_Parse($sExpression)
	Local $aChar = StringSplit($sExpression, '', $STR_NOCOUNT), _
			$bIsBracket = False, _ ; Is parenthesis.
			$hStack = Stack(), _ ; Create a stack to push/pop to.
			$sOutput, _ ; Output string.
			$sToken = '' ; Token.
	For $i = 0 To UBound($aChar) - 1
		$sToken = $aChar[$i]

		If StringIsDigit($sToken) Then ; If a digit add to the output string.
			$sOutput &= $sToken
		ElseIf __ShuntingYard_IsOperator($sToken) Then ; Check if a valid token.
			If __ShuntingYard_IsBracket($sToken) Then
				$bIsBracket = $sToken == '(' ; True if open bracket else False if closing.
				If $bIsBracket Then ; Open bracket.
					Stack_Push($hStack, $sToken)
				Else ; Closing bracket.
					$sOutput &= ' '
					Do ; Repeat until '(' is found.
						$sOutput &= Stack_Pop($hStack)
					Until (Stack_Peek($hStack) == '(')
					Stack_Pop($hStack)
				EndIf
			Else
				$sOutput &= " " ; Workaround for spacing and certain expressions.
				If Stack_Count($hStack) > 0 And __ShuntingYard_HasHigherPrecedence($sToken, Stack_Peek($hStack)) Then
					$sOutput &= Stack_Pop($hStack)
					Stack_Push($hStack, $sToken)
					$sOutput &= " " ; Workaround for spacing and certain expressions.
				Else
					Stack_Push($hStack, $sToken)
				EndIf
			EndIf
		EndIf
	Next

	If Stack_Count($hStack) > 0 Then ; Append what is left on the stack in reverse order.
		$sOutput &= ' '
		While (Stack_Count($hStack) > 0)
			$sOutput &= Stack_Pop($hStack) & ' '
		WEnd
	EndIf
	Return $sOutput
EndFunc   ;==>ShuntingYard_Parse

Func __ShuntingYard_Eval($iNumber1, $iNumber2, $sChar)
	Switch $sChar
		Case '+'
			Return $iNumber1 + $iNumber2

		Case '-', ChrW(8722) ; Char 8722 is - but the unicode char code
			Return $iNumber1 - $iNumber2

		Case '*'
			Return $iNumber1 * $iNumber2

		Case '/'
			Return $iNumber1 / $iNumber2

		Case '^'
			Return $iNumber1 ^ $iNumber2

		Case Else
			Return $iNumber1

	EndSwitch
EndFunc   ;==>__ShuntingYard_Eval

Func __ShuntingYard_HasHigherPrecedence($sChar1, $sChar2)
	Local $iChar1 = __ShuntingYard_PrecendenceValue($sChar1), _
			$iChar2 = __ShuntingYard_PrecendenceValue($sChar2)
	If $iChar1 = 0 And $iChar2 = 0 Then
		Return False
	EndIf
	Return $iChar1 <= $iChar2 And Not ($sChar1 == '^')
EndFunc   ;==>__ShuntingYard_HasHigherPrecedence

Func __ShuntingYard_IsBracket($sChar)
	Return $sChar == '(' Or $sChar == ')'
EndFunc   ;==>__ShuntingYard_IsBracket

Func __ShuntingYard_IsOperator($sChar)
	Return $sChar == '+' Or $sChar == '-' Or $sChar == ChrW(8722) Or $sChar == '*' Or $sChar == '/' Or $sChar == '^' Or $sChar == '(' Or $sChar == ')'; Char 8722 is - but the unicode char code.
EndFunc   ;==>__ShuntingYard_IsOperator

Func __ShuntingYard_PrecendenceValue($sChar)
	Switch $sChar
		Case '+', '-'
			Return 2

		Case '*', '/'
			Return 3

		Case '^'
			Return 4

		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>__ShuntingYard_PrecendenceValue
