Global Enum $STOPWATCH_TIMER, $STOPWATCH_RUNNING, $STOPWATCH_ELAPSEDMS, $STOPWATCH_MAX

Example()

Func Example()
	Local $hStopWatch = Stopwatch()
	ConsoleWrite('IsRunning: ' & Stopwatch_IsRunning($hStopWatch) & @CRLF) ; Display running status.

	Stopwatch_Start($hStopWatch) ; Start the stopwatch.
	ConsoleWrite('IsRunning: ' & Stopwatch_IsRunning($hStopWatch) & @CRLF) ; Display running status.
	Sleep(1000) ; Wait for 1 second.
	Stopwatch_Stop($hStopWatch) ; Stop the stopwatch.
	ConsoleWrite('Elapsed Time: ' & Stopwatch_ElapsedMilliseconds($hStopWatch) & @CRLF)

	Stopwatch_Start($hStopWatch) ; Start the stopwatch again.
	Sleep(2000) ; Wait for 2 seconds.

	For $i = 1 To 10 ; The number of milliseconds is shown even when the stopwatch is running.
		ConsoleWrite('Elapsed Time: ' & Stopwatch_ElapsedMilliseconds($hStopWatch) & @CRLF)
		Sleep(250)
	Next

	Stopwatch_Stop($hStopWatch) ; Stop the stopwatch.
	ConsoleWrite('Elapsed Time: ' & Stopwatch_ElapsedMilliseconds($hStopWatch) & @CRLF) ; This should be about 5 seconds or so.

	ConsoleWrite('IsRunning: ' & Stopwatch_IsRunning($hStopWatch) & @CRLF) ; Display running status.
EndFunc   ;==>Example

; Stopwatch Class: http://msdn.microsoft.com/en-us/library/system.diagnostics.stopwatch(v=vs.110).aspx
Func Stopwatch()
	Local $aStopwatch[$STOPWATCH_MAX]
	Stopwatch_Reset($aStopwatch)
	Return $aStopwatch
EndFunc   ;==>Stopwatch

Func Stopwatch_ElapsedMilliseconds(ByRef $aStopwatch)
	Local $iElapsedTime = 0
	If __Stopwatch_IsStopwatch($aStopwatch) Then
		$iElapsedTime = $aStopwatch[$STOPWATCH_RUNNING] ? $aStopwatch[$STOPWATCH_ELAPSEDMS] + TimerDiff($aStopwatch[$STOPWATCH_TIMER]) : $aStopwatch[$STOPWATCH_ELAPSEDMS]
	EndIf
	Return $iElapsedTime
EndFunc   ;==>Stopwatch_ElapsedMilliseconds

Func Stopwatch_IsRunning(ByRef $aStopwatch)
	Return __Stopwatch_IsStopwatch($aStopwatch) ? $aStopwatch[$STOPWATCH_RUNNING] : False
EndFunc   ;==>Stopwatch_IsRunning

Func Stopwatch_Reset(ByRef $aStopwatch)
	If __Stopwatch_IsStopwatch($aStopwatch) Then
		$aStopwatch[$STOPWATCH_ELAPSEDMS] = 0
		$aStopwatch[$STOPWATCH_RUNNING] = False
		$aStopwatch[$STOPWATCH_TIMER] = 0
	EndIf
	Return True
EndFunc   ;==>Stopwatch_Reset

Func Stopwatch_Restart(ByRef $aStopwatch)
	If __Stopwatch_IsStopwatch($aStopwatch) Then
		Stopwatch_Reset($aStopwatch)
		Stopwatch_Start($aStopwatch)
	EndIf
	Return True
EndFunc   ;==>Stopwatch_Restart

Func Stopwatch_Start(ByRef $aStopwatch)
	If __Stopwatch_IsStopwatch($aStopwatch) And Not $aStopwatch[$STOPWATCH_RUNNING] Then
		$aStopwatch[$STOPWATCH_RUNNING] = True
		$aStopwatch[$STOPWATCH_TIMER] = TimerInit()
	EndIf
	Return True
EndFunc   ;==>Stopwatch_Start

Func Stopwatch_StartNew()
	Local $aStopwatch = Stopwatch()
	Stopwatch_Start($aStopwatch)
	Return $aStopwatch
EndFunc   ;==>Stopwatch_StartNew

Func Stopwatch_Stop(ByRef $aStopwatch)
	If __Stopwatch_IsStopwatch($aStopwatch) And $aStopwatch[$STOPWATCH_RUNNING] Then
		$aStopwatch[$STOPWATCH_ELAPSEDMS] = $aStopwatch[$STOPWATCH_ELAPSEDMS] + TimerDiff($aStopwatch[$STOPWATCH_TIMER])
		$aStopwatch[$STOPWATCH_RUNNING] = False
	EndIf
	Return True
EndFunc   ;==>Stopwatch_Stop

Func __Stopwatch_IsStopwatch(ByRef $aStopwatch) ; Internal function only.
	Return UBound($aStopwatch) = $STOPWATCH_MAX
EndFunc   ;==>__Stopwatch_IsStopwatch
