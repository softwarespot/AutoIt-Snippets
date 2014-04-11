#include <Array.au3>

Global Enum $STACK_INDEX, $STACK_UBOUND, $STACK_MAX

Example()

Func Example()
	Local $hStack = Stack() ; Create a stack object.

	For $i = 1 To 20
		If Stack_Push($hStack, 'Example_' & $i) Then ConsoleWrite('Push: ' & 'Example_' & $i & @CRLF) ; Push random data to the stack.
	Next

	For $i = 1 To 15
		ConsoleWrite('Pop: ' & Stack_Pop($hStack) & @CRLF) ; Pop from the stack.
		If Stack_Push($hStack, 'Example_' & $i * 10) Then ConsoleWrite('Push: ' & 'Example_' & $i * 10 & @CRLF) ; Push random data to the stack.
	Next
	ConsoleWrite('Peek: ' & Stack_Peek($hStack) & @CRLF)
	ConsoleWrite('Peek: ' & Stack_Peek($hStack) & @CRLF)

	ConsoleWrite('Count: ' & Stack_Count($hStack) & @CRLF)

	Stack_Clear($hStack) ; Clear the stack.
EndFunc   ;==>Example

; Functions:
; Stack - Create a stack handle.
; Stack_Clear - Remove all items/objects from the stack.
; Stack_Count - Retrieve the number of items/objects on the stack.
; Stack_Peek - Peek at the item/object in the stack.
; Stack_Pop - Pop the last item/object from the stack.
; Stack_Push - Push an item/object to the stack.

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack
; Description ...: Create a stack handle.
; Syntax ........: Stack()
; Parameters ....: None
; Return values .: Handle that should be passed to all relevant stack functions.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack()
	Local $aStack[$STACK_MAX]
	$aStack[$STACK_INDEX] = $STACK_UBOUND
	$aStack[$STACK_UBOUND] = $STACK_MAX
	Return $aStack
EndFunc   ;==>Stack

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_Clear
; Description ...: Remove all items/objects from the stack.
; Syntax ........: Stack_Clear(ByRef $aStack)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
; Return values .: Success: Items/objects removed from the stack.
;				   Failure: None
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_Clear(ByRef $aStack)
	$aStack = Stack()
	Return True
EndFunc   ;==>Stack_Clear

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_Count
; Description ...: Retrieve the number of items/objects on the stack.
; Syntax ........: Stack_Count(ByRef $aStack)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
; Return values .: Success: Count of the items/objects on the stack.
;				   Failure: None
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_Count(ByRef $aStack)
	Return UBound($aStack) And $aStack[$STACK_INDEX] >= $STACK_MAX ? $aStack[$STACK_INDEX] - $STACK_UBOUND : 0
EndFunc   ;==>Stack_Count

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_Peek
; Description ...: Peek at the item/object in the stack.
; Syntax ........: Stack_Peek(ByRef $aStack)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
; Return values .: Success: Item/object in the stack.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_Peek(ByRef $aStack)
	Return UBound($aStack) And $aStack[$STACK_INDEX] >= $STACK_MAX ? $aStack[$aStack[$STACK_INDEX]] : SetError(1, 0, Null)
EndFunc   ;==>Stack_Peek

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_Pop
; Description ...: Pop the last item/object from the stack.
; Syntax ........: Stack_Pop(ByRef $aStack)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
; Return values .: Success: Item/object popped from the stack.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_Pop(ByRef $aStack)
	If UBound($aStack) And $aStack[$STACK_INDEX] >= $STACK_MAX Then
		Local $sData = $aStack[$aStack[$STACK_INDEX]] ; Save the stack item/object.
		$aStack[$aStack[$STACK_INDEX]] = Null ; Set to null.
		$aStack[$STACK_INDEX] -= 1 ; Decrease the index by 1.
		If ($aStack[$STACK_UBOUND] - $aStack[$STACK_INDEX]) > 15 Then ; If there are too many blank rows then re-size the stack.
			$aStack[$STACK_UBOUND] = ($aStack[$STACK_INDEX] < $STACK_MAX) ? $STACK_MAX : $aStack[$STACK_INDEX] + 1
			ReDim $aStack[$aStack[$STACK_UBOUND]]
		EndIf
		Return $sData
	EndIf
	Return SetError(1, 0, Null)
EndFunc   ;==>Stack_Pop

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_Push
; Description ...: Push an item/object to the stack.
; Syntax ........: Stack_Push(ByRef $aStack, $vData)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
;                  $vData               - Item/object.
; Return values .: Success: True.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_Push(ByRef $aStack, $vData)
	If UBound($aStack) Then
		$aStack[$STACK_INDEX] += 1 ; Increase the stack by 1.
		If $aStack[$STACK_INDEX] >= $aStack[$STACK_UBOUND] Then ; ReDim the internal stack array if required.
			$aStack[$STACK_UBOUND] = Ceiling($aStack[$STACK_UBOUND] * 1.5)
			ReDim $aStack[$aStack[$STACK_UBOUND]]
		EndIf
		$aStack[$aStack[$STACK_INDEX]] = $vData ; Set the stack element.
		Return True
	EndIf
	Return SetError(1, 0, Null)
EndFunc   ;==>Stack_Push
