#AutoIt3Wrapper_Run_Au3Check=N
#include <Array.au3>

Global Enum $QUEUE_FIRSTINDEX, $QUEUE_LASTINDEX, $QUEUE_COUNT, $QUEUE_UBOUND, $QUEUE_MAX

Example()

Func Example()
	Local $hQueue = Queue() ; Create a queue object.

	For $i = 1 To 20
		If Queue_Enqueue($hQueue, 'Example_' & $i) Then ConsoleWrite('Enqueue: ' & 'Example_' & $i & @CRLF) ; Push random data to the queue.
	Next

	For $i = 1 To 15
		ConsoleWrite('Dequeue: ' & Queue_Dequeue($hQueue) & @CRLF) ; Pop from the queue.
		If Queue_Enqueue($hQueue, 'Example_' & $i * 10) Then ConsoleWrite('Enqueue: ' & 'Example_' & $i * 10 & @CRLF) ; Push random data to the queue.
	Next
	ConsoleWrite('Peek: ' & Queue_Peek($hQueue) & @CRLF)
	ConsoleWrite('Peek: ' & Queue_Peek($hQueue) & @CRLF)

	ConsoleWrite('Count: ' & Queue_Count($hQueue) & @CRLF)

	Queue_ForEach($hQueue, AppendUnderscore) ; Randomise when to return True Or False. The false was break from the ForEach() function.

	ConsoleWrite('Contains: ' & (Queue_ForEach($hQueue, Contains) = False) & @CRLF) ; It will return False if found so as to exit the ForEach() loop, hence why False is compared

	Local $aQueue = Queue_ToArray($hQueue) ; Create an array from the queue.
	_ArrayDisplay($aQueue)

	Queue_Clear($hQueue) ; Clear the queue.
	Queue_TrimToSize($hQueue) ; Decrease the memory footprint.
EndFunc   ;==>Example

Func AppendUnderscore(ByRef $vItem)
	$vItem &= '_'
	Return Random(0, 1, 1) ? True : False ; Randomise when to return True Or False. The false was break from the ForEach() function.
EndFunc   ;==>AppendUnderscore

Func Contains(ByRef $vItem)
	Return $vItem == 'Example_150' ? False : True ; If found exit the loop by setting to False.
EndFunc   ;==>Contains

; Functions:
; Queue - Create a queue handle.
; Queue_ToArray - Create an array from the queue.
; Queue_Clear - Remove all items/objects from the queue.
; Queue_Count - Retrieve the number of items/objects on the queue.
; Queue_Dequeue - Pop the first item/object from the queue.
; Queue_Enqueue - Push an item/object to the queue.
; Queue_ForEach - Loop through the queue and pass each item/object to a custom function for processing.
; Queue_Peek - Peek at the item/object in the queue.
; Queue_TrimToSize - Set the capacity to the number of items/objects in the queue.

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue
; Description ...: Create a queue handle.
; Syntax ........: Queue([$iInitialSize = Default])
; Parameters ....: $iInitialSize        - [optional] Initialise the queue with a certain size. Useful if you know how large the queue will grow. Default is zero
; Parameters ....: None
; Return values .: Handle that should be passed to all relevant queue functions.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue($iInitialSize = Default)
	Return __Queue($iInitialSize, False)
EndFunc   ;==>Queue

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_ToArray
; Description ...: Create an array from the queue.
; Syntax ........: Queue_ToArray(ByRef $aQueue)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
; Return values .: Success: A zero based array.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_ToArray(ByRef $aQueue)
	If UBound($aQueue) >= $QUEUE_MAX And $aQueue[$QUEUE_COUNT] Then
		Local $aArray[$aQueue[$QUEUE_COUNT]]
		Local $j = 0
		For $i = $aQueue[$QUEUE_FIRSTINDEX] + 1 To $aQueue[$QUEUE_LASTINDEX]
			$aArray[$j] = $aQueue[$i]
			$j += 1
		Next
		Return $aArray
	EndIf
	Return SetError(1, 0, Null)
EndFunc   ;==>Queue_ToArray

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_Clear
; Description ...: Remove all items/objects from the queue.
; Syntax ........: QueueClear(ByRef $aQueue)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
; Return values .: Success: Items/objects removed from the queue
;				   Failure: None
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_Clear(ByRef $aQueue)
	$aQueue = __Queue($aQueue, False)
	Return True
EndFunc   ;==>Queue_Clear

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_Count
; Description ...: Retrieve the number of items/objects on the queue.
; Syntax ........: Queue_Count(ByRef $aQueue)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
; Return values .: Success: Count of the items/objects on the queue.
;				   Failure: None
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_Count(ByRef $aQueue)
	Return UBound($aQueue) >= $QUEUE_MAX And $aQueue[$QUEUE_COUNT] >= 0 ? $aQueue[$QUEUE_COUNT] : 0
EndFunc   ;==>Queue_Count

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_ForEach
; Description ...: Loop through the queue and pass each item/object to a custom function for processing.
; Syntax ........: Queue_ForEach(ByRef $aQueue, $hFunc)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
;                  $hFunc               - A delegate to a function that has a single ByRef input and a return value of either True (continue looping) or False (exit looping).
; Return values .: Success: Return value of either True or False from the delegate function.
;				   Failure: Null
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_ForEach(ByRef $aQueue, $hFunc)
	Local $fReturn = Null
	If UBound($aQueue) >= $QUEUE_MAX And IsFunc($hFunc) Then
		For $i = $aQueue[$QUEUE_FIRSTINDEX] + 1 To $aQueue[$QUEUE_LASTINDEX]
			$fReturn = $hFunc($aQueue[$i])
			If Not $fReturn Then
				ExitLoop
			EndIf
		Next
	EndIf
	Return $fReturn
EndFunc   ;==>Queue_ForEach

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_Peek
; Description ...: Peek at the item/object in the queue.
; Syntax ........: Queue_Peek(ByRef $aQueue)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
; Return values .: Success: Item/object in the queue.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_Peek(ByRef $aQueue)
	Return UBound($aQueue) >= $QUEUE_MAX And $aQueue[$QUEUE_FIRSTINDEX] >= $QUEUE_MAX ? $aQueue[$aQueue[$QUEUE_FIRSTINDEX] + 1] : SetError(1, 0, Null)
EndFunc   ;==>Queue_Peek

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_Dequeue
; Description ...: Pop the first item/object from the queue.
; Syntax ........: Queue_Dequeue(ByRef $aQueue)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
; Return values .: Success: Item/object popped from the queue.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_Dequeue(ByRef $aQueue)
	If UBound($aQueue) >= $QUEUE_MAX And $aQueue[$QUEUE_LASTINDEX] >= $QUEUE_MAX Then
		$aQueue[$QUEUE_FIRSTINDEX] += 1
		$aQueue[$QUEUE_COUNT] -= 1 ; Decrease the count.
		Local $vData = $aQueue[$aQueue[$QUEUE_FIRSTINDEX]] ; Save the queue item/object.
		$aQueue[$aQueue[$QUEUE_FIRSTINDEX]] = Null ; Set to null.
		; If ($aQueue[$QUEUE_FIRSTINDEX] - $QUEUE_MAX) > 15 Then ; If there are too many blank rows then re-size the queue.
		; $aQueue = __Queue($aQueue, True)
		; EndIf
		Return $vData
	EndIf
	Return SetError(1, 0, Null)
EndFunc   ;==>Queue_Dequeue

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_Enqueue
; Description ...: Push an item/object to the queue.
; Syntax ........: Queue_Enqueue(ByRef $aQueue, $vData)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
;                  $vData               - Item/object.
; Return values .: Success: True.
;				   Failure: Sets @error to non-zero and returns Null.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_Enqueue(ByRef $aQueue, $vData)
	If UBound($aQueue) >= $QUEUE_MAX Then
		$aQueue[$QUEUE_LASTINDEX] += 1 ; Increase the queue by 1.
		$aQueue[$QUEUE_COUNT] += 1 ; Increase the count.
		If $aQueue[$QUEUE_LASTINDEX] >= $aQueue[$QUEUE_UBOUND] Then ; ReDim the internal queue array if required.
			$aQueue[$QUEUE_UBOUND] = Ceiling($aQueue[$QUEUE_UBOUND] * 1.5)
			ReDim $aQueue[$aQueue[$QUEUE_UBOUND]]
		EndIf
		$aQueue[$aQueue[$QUEUE_LASTINDEX]] = $vData ; Set the queue element.
		Return True
	EndIf
	Return SetError(1, 0, Null)
EndFunc   ;==>Queue_Enqueue

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue_TrimToSize
; Description ...: Set the capacity to the number of items/objects in the queue.
; Syntax ........: Queue_TrimToSize(ByRef $aQueue)
; Parameters ....: $aQueue              - [in/out] Handle returned by Queue().
; Return values .: Success: True.
;				   Failure: None
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue_TrimToSize(ByRef $aQueue)
	$aQueue = __Queue($aQueue, True)
	Return True
EndFunc   ;==>Queue_TrimToSize

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Queue
; Description ...: Create a new queue object or re-size a current queue object.
; Syntax ........: __Queue([$vQueue = Default[, $fIsCopyObjects = Default]])
; Parameters ....: $vQueue              - [optional] A variant value of either Default or queue object. Default is Default.
;                  $fIsCopyObjects      - [optional] Copy the previous queue items/objects. Default is False
; Return values .: New queue object.
; Author ........: guinness
; ===============================================================================================================================
Func __Queue($vQueue = Default, $fIsCopyObjects = False)
	Local $iCount = (UBound($vQueue) >= $QUEUE_MAX) ? $vQueue[$QUEUE_COUNT] : ((IsInt($vQueue) And $vQueue > 0) ? $vQueue : 0)

	Local $aQueue[$QUEUE_MAX + $iCount]
	$aQueue[$QUEUE_FIRSTINDEX] = $QUEUE_MAX - 1
	$aQueue[$QUEUE_LASTINDEX] = $QUEUE_MAX - 1
	$aQueue[$QUEUE_COUNT] = 0
	$aQueue[$QUEUE_UBOUND] = $QUEUE_MAX + $iCount

	If $fIsCopyObjects And $iCount > 0 Then ; If copy previous count is greater than zero then add the copy the items/objects.
		$aQueue[$QUEUE_LASTINDEX] = $QUEUE_MAX - 1 + $iCount
		$aQueue[$QUEUE_COUNT] = $iCount

		Local $j = $vQueue[$QUEUE_FIRSTINDEX] + 1
		For $i = $QUEUE_MAX To $QUEUE_MAX + $iCount - 1
			$aQueue[$i] = $vQueue[$j]
			$j += 1
		Next
	EndIf
	$vQueue = 0
	Return $aQueue
EndFunc   ;==>__Queue
