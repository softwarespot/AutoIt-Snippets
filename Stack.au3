#AutoIt3Wrapper_Run_Au3Check=N
#include <Array.au3>

Global Const $STACK_GUID = '40927D46-DE64-11E3-A054-047274EB0A54'
Global Enum $STACK_INDEX, $STACK_COUNT, $STACK_ID, $STACK_UBOUND, $STACK_MAX

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
	ConsoleWrite('Capacity: ' & Stack_Capacity($hStack) & @CRLF)

	Stack_ForEach($hStack, AppendUnderscore) ; Loop through the stack and pass each item to the custom function.

	ConsoleWrite('Contains Example_150: ' & (Stack_ForEach($hStack, Contains_150) = False) & @CRLF) ; It will return False if found so as to exit the ForEach() loop, hence why False is compared
	ConsoleWrite('Contains Example_1000: ' & (Stack_ForEach($hStack, Contains_1000) = False) & @CRLF) ; It will return False if found so as to exit the ForEach() loop, hence why False is compared

	Local $aStack = Stack_ToArray($hStack) ; Create an array from the stack.
	_ArrayDisplay($aStack)

	Stack_Clear($hStack) ; Clear the stack.
	Stack_TrimExcess($hStack) ; Decrease the memory footprint.
EndFunc   ;==>Example

Func AppendUnderscore(ByRef $vItem)
	$vItem &= '_'
	Return Random(0, 1, 1) ? True : False ; Randomise when to return True Or False. The false was break from the ForEach() function.
EndFunc   ;==>AppendUnderscore

Func Contains_150(ByRef $vItem)
	Return $vItem == 'Example_150' ? False : True ; If found exit the loop by setting to False.
EndFunc   ;==>Contains_150

Func Contains_1000(ByRef $vItem)
	Return $vItem == 'Example_1000' ? False : True ; If found exit the loop by setting to False.
EndFunc   ;==>Contains_1000

; Functions:
; Stack - Create a stack handle.
; Stack_ToArray - Create an array from the stack.
; Stack_Capacity - Retrieve the capacity of the internal stack elements.
; Stack_Clear - Remove all items/objects from the stack.
; Stack_Count - Retrieve the number of items/objects on the stack.
; Stack_ForEach - Loop through the stack and pass each item/object to a custom function for processing.
; Stack_Peek - Peek at the item/object in the stack.
; Stack_Pop - Pop the last item/object from the stack.
; Stack_Push - Push an item/object to the stack.
; Stack_TrimExcess - Set the capacity to the number of items/objects in the stack.

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack
; Description ...: Create a stack handle.
; Syntax ........: Stack([$iInitialSize = Default])
; Parameters ....: $iInitialSize        - [optional] Initialise the stack with a certain size. Useful if you know how large the stack will grow. Default is zero
; Parameters ....: None
; Return values .: Handle that should be passed to all relevant stack functions.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack($iInitialSize = Default)
	Return __Stack($iInitialSize, False)
EndFunc   ;==>Stack

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_ToArray
; Description ...: Create an array from the stack.
; Syntax ........: Stack_ToArray(ByRef $aStack)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
; Return values .: Success: A zero based array.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_ToArray(ByRef $aStack)
	If UBound($aStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID And $aStack[$STACK_COUNT] Then
		Local $aArray[$aStack[$STACK_COUNT]]
		Local $j = $aStack[$STACK_COUNT] - 1
		For $i = $STACK_MAX To $aStack[$STACK_INDEX]
			$aArray[$j] = $aStack[$i]
			$j -= 1
		Next
		Return $aArray
	EndIf
	Return SetError(1, 0, Null)
EndFunc   ;==>Stack_ToArray

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_Capacity
; Description ...: Retrieve the capacity of the internal stack elements.
; Syntax ........: Stack_Capacity(ByRef $aStack)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
; Return values .: Success: Capacity of the internal stack.
;				   Failure: None
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_Capacity(ByRef $aStack)
	Return UBound($aStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID ? $aStack[$STACK_UBOUND] - $STACK_MAX : 0
EndFunc   ;==>Stack_Capacity

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
	$aStack = __Stack($aStack, False)
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
	Return UBound($aStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID And $aStack[$STACK_COUNT] >= 0 ? $aStack[$STACK_COUNT] : 0
EndFunc   ;==>Stack_Count

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_ForEach
; Description ...: Loop through the stack and pass each item/object to a custom function for processing.
; Syntax ........: Stack_ForEach(ByRef $aStack, $hFunc)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
;                  $hFunc               - A delegate to a function that has a single ByRef input and a return value of either True (continue looping) or False (exit looping).
; Return values .: Success: Return value of either True or False from the delegate function.
;				   Failure: Null
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_ForEach(ByRef $aStack, $hFunc)
	Local $fReturn = Null
	If UBound($aStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID And IsFunc($hFunc) Then
		For $i = $STACK_MAX To $aStack[$STACK_INDEX]
			$fReturn = $hFunc($aStack[$i])
			If Not $fReturn Then
				ExitLoop
			EndIf
		Next
	EndIf
	Return $fReturn
EndFunc   ;==>Stack_ForEach

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
	Return UBound($aStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID And $aStack[$STACK_INDEX] >= $STACK_MAX ? $aStack[$aStack[$STACK_INDEX]] : SetError(1, 0, Null)
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
	If UBound($aStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID And $aStack[$STACK_INDEX] >= $STACK_MAX Then
		$aStack[$STACK_COUNT] -= 1 ; Decrease the count.
		Local $vData = $aStack[$aStack[$STACK_INDEX]] ; Save the stack item/object.
		$aStack[$aStack[$STACK_INDEX]] = Null ; Set to null.
		$aStack[$STACK_INDEX] -= 1 ; Decrease the index by 1.
		; If ($aStack[$STACK_UBOUND] - $aStack[$STACK_INDEX]) > 15 Then ; If there are too many blank rows then re-size the stack.
		; $aStack = __Stack($aStack, True)
		; EndIf
		Return $vData
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
	If UBound($aStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID Then
		$aStack[$STACK_INDEX] += 1 ; Increase the stack by 1.
		$aStack[$STACK_COUNT] += 1 ; Increase the count.
		If $aStack[$STACK_INDEX] >= $aStack[$STACK_UBOUND] Then ; ReDim the internal stack array if required.
			$aStack[$STACK_UBOUND] = Ceiling(($aStack[$STACK_UBOUND] - $STACK_MAX) * 2) + $STACK_MAX
			ReDim $aStack[$aStack[$STACK_UBOUND]]
		EndIf
		$aStack[$aStack[$STACK_INDEX]] = $vData ; Set the stack element.
		Return True
	EndIf
	Return SetError(1, 0, Null)
EndFunc   ;==>Stack_Push

; #FUNCTION# ====================================================================================================================
; Name ..........: Stack_TrimExcess
; Description ...: Set the capacity to the number of items/objects in the stack.
; Syntax ........: Stack_TrimExcess(ByRef $aStack)
; Parameters ....: $aStack              - [in/out] Handle returned by Stack().
; Return values .: Success: True.
;				   Failure: None
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Stack_TrimExcess(ByRef $aStack)
	$aStack = __Stack($aStack, True)
	Return True
EndFunc   ;==>Stack_TrimExcess

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Stack
; Description ...: Create a new stack object or re-size a current stack object.
; Syntax ........: __Stack([$vStack = Default[, $fIsCopyObjects = Default]])
; Parameters ....: $vStack              - [optional] A variant value of either Default or stack object. Default is Default.
;                  $fIsCopyObjects      - [optional] Copy the previous stack items/objects. Default is False
; Return values .: New stack object.
; Author ........: guinness
; ===============================================================================================================================
Func __Stack($vStack = Default, $fIsCopyObjects = False)
	Local $iCount = (UBound($vStack) >= $STACK_MAX And $aStack[$STACK_ID] = $STACK_GUID) ? $vStack[$STACK_COUNT] : ((IsInt($vStack) And $vStack > 0) ? $vStack : 0)

	Local $iUBound = $STACK_MAX + (($iCount) > 0 ? $iCount : 4) ; STACK_INITIAL_SIZE
	Local $aStack[$iUBound]
	$aStack[$STACK_INDEX] = $STACK_MAX - 1
	$aStack[$STACK_COUNT] = 0
	$aStack[$STACK_ID] = $STACK_GUID
	$aStack[$STACK_UBOUND] = $iUBound

	If $fIsCopyObjects And $iCount > 0 Then ; If copy previous count is greater than zero then add the copy the items/objects.
		$aStack[$STACK_INDEX] = $STACK_MAX - 1 + $iCount
		$aStack[$STACK_COUNT] = $iCount

		ReDim $aStack[$aStack[$STACK_UBOUND]]
	EndIf
	$vStack = 0
	Return $aStack
EndFunc   ;==>__Stack
