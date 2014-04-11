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

	Queue_Clear($hQueue) ; Clear the queue.
EndFunc   ;==>Example

; Functions:
; Queue - Create a queue handle.
; Queue_Clear - Remove all items/objects from the queue.
; Queue_Count - Retrieve the number of items/objects on the queue.
; Queue_Peek - Peek at the item/object in the queue.
; Queue_Dequeue - Pop the first item/object from the queue.
; Queue_Enqueue - Push an item/object to the queue.

; #FUNCTION# ====================================================================================================================
; Name ..........: Queue
; Description ...: Create a queue handle.
; Syntax ........: Queue()
; Parameters ....: None
; Return values .: Handle that should be passed to all relevant queue functions.
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func Queue()
	Return __Queue()
EndFunc   ;==>Queue

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
	$aQueue = Queue()
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
	Return UBound($aQueue) And $aQueue[$QUEUE_COUNT] >= 0 ? $aQueue[$QUEUE_COUNT] : 0
EndFunc   ;==>Queue_Count

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
	Return UBound($aQueue) And $aQueue[$QUEUE_FIRSTINDEX] >= $QUEUE_MAX ? $aQueue[$aQueue[$QUEUE_FIRSTINDEX] + 1] : SetError(1, 0, Null)
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
	If UBound($aQueue) And $aQueue[$QUEUE_LASTINDEX] >= $QUEUE_MAX Then
		$aQueue[$QUEUE_FIRSTINDEX] += 1
		$aQueue[$QUEUE_COUNT] -= 1 ; Decrease the count.
		Local $sData = $aQueue[$aQueue[$QUEUE_FIRSTINDEX]] ; Save the queue item/object.
		$aQueue[$aQueue[$QUEUE_FIRSTINDEX]] = Null ; Set to null.
		If ($aQueue[$QUEUE_FIRSTINDEX] - $QUEUE_UBOUND) > 10 Then ; If there are too many blank rows then re-size the queue.
			$aQueue = __Queue($aQueue)
		EndIf
		Return $sData
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
	If UBound($aQueue) Then
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

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Queue
; Description ...:Create a new queue object or re-size a current queue object.
; Syntax ........: __Queue([$vQueue = Default])
; Parameters ....: $vQueue              - [optional] A variant valueof either Default or queue object. Default is Default.
; Return values .: New queue object.
; Author ........: guinness
; ===============================================================================================================================
Func __Queue($vQueue = Default)
	Local $aQueue = 0
	If $vQueue = Default Or Not UBound($vQueue) Or $vQueue[$QUEUE_COUNT] = 0 Then
		Local $aQueueInit[$QUEUE_MAX]
		$aQueueInit[$QUEUE_FIRSTINDEX] = $QUEUE_UBOUND
		$aQueueInit[$QUEUE_LASTINDEX] = $QUEUE_UBOUND
		$aQueueInit[$QUEUE_COUNT] = 0
		$aQueueInit[$QUEUE_UBOUND] = $QUEUE_MAX
		$aQueue = $aQueueInit
		$aQueueInit = 0
		$vQueue = 0
	Else
		Local $aQueueReDim[$QUEUE_MAX + $vQueue[$QUEUE_COUNT]]
		$aQueueReDim[$QUEUE_FIRSTINDEX] = $QUEUE_UBOUND
		$aQueueReDim[$QUEUE_LASTINDEX] = $QUEUE_UBOUND + $vQueue[$QUEUE_COUNT]
		$aQueueReDim[$QUEUE_COUNT] = $vQueue[$QUEUE_COUNT]
		$aQueueReDim[$QUEUE_UBOUND] = $QUEUE_UBOUND + $vQueue[$QUEUE_COUNT]
		Local $j = $vQueue[$QUEUE_FIRSTINDEX] + 1
		For $i = $QUEUE_MAX To $QUEUE_MAX + $vQueue[$QUEUE_COUNT] - 1
			$aQueueReDim[$i] = $vQueue[$j]
			$j += 1
		Next
		$aQueue = $aQueueReDim
		$aQueueReDim = 0
		$vQueue = 0
	EndIf
	Return $aQueue
EndFunc   ;==>__Queue
