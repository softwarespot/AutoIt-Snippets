#include <Date.au3>
#include <Timers.au3>
#include <WinAPICom.au3>
#include <WinAPISys.au3>

Global Const $STOPWATCH_GUID = _WinAPI_CreateGUID(), $STOPWATCH_TICKSPERMILLISECOND = 10000, $STOPWATCH_TICKSPERSECOND = 10000000
Global Enum $STOPWATCH_TIMER, $STOPWATCH_RUNNING, $STOPWATCH_ELAPSED, $STOPWATCH_ISHIGHRESOLUTION, $STOPWATCH_FREQUENCY, $STOPWATCH_TICKFREQUENCY, $STOPWATCH_ID, $STOPWATCH_MAX

Example()

Func Example()
	Local $hStopWatch = Stopwatch()
	ConsoleWrite('IsRunning: ' & Stopwatch_IsRunning($hStopWatch) & @CRLF) ; Display running status.

	Stopwatch_Start($hStopWatch) ; Start the stopwatch.
	ConsoleWrite('IsRunning: ' & Stopwatch_IsRunning($hStopWatch) & @CRLF) ; Display running status.
	Sleep(1000) ; Wait for 1 second.
	Stopwatch_Stop($hStopWatch) ; Stop the stopwatch.
	ConsoleWrite('Elapsed ms Time: ' & Stopwatch_ElapsedMilliseconds($hStopWatch) & @CRLF)

	Stopwatch_Start($hStopWatch) ; Start the stopwatch again.
	Sleep(2000) ; Wait for 2 seconds.

	For $i = 1 To 10 ; The number of milliseconds is shown even when the stopwatch is running.
		ConsoleWrite('Elapsed ms Time: ' & Stopwatch_ElapsedMilliseconds($hStopWatch) & @CRLF)
		Sleep(250)
	Next

	Stopwatch_Stop($hStopWatch) ; Stop the stopwatch.
	ConsoleWrite('Elapsed ms Time: ' & Stopwatch_ElapsedMilliseconds($hStopWatch) & @CRLF) ; This should be about 5 seconds or so.

	ConsoleWrite('IsRunning: ' & Stopwatch_IsRunning($hStopWatch) & @CRLF) ; Display running status.
EndFunc   ;==>Example

; Stopwatch Class: http://msdn.microsoft.com/en-us/library/system.diagnostics.stopwatch(v=vs.110).aspx
Func Stopwatch()
	Local $aStopwatch[$STOPWATCH_MAX]
	Stopwatch_Reset($aStopwatch)
	$aStopwatch[$STOPWATCH_FREQUENCY] = _WinAPI_QueryPerformanceFrequency()
	If Not $aStopwatch[$STOPWATCH_FREQUENCY] Then
		$aStopwatch[$STOPWATCH_ISHIGHRESOLUTION] = False
		$aStopwatch[$STOPWATCH_FREQUENCY] = $STOPWATCH_TICKSPERSECOND
		$aStopwatch[$STOPWATCH_TICKFREQUENCY] = 1
	Else
		$aStopwatch[$STOPWATCH_ISHIGHRESOLUTION] = True
		$aStopwatch[$STOPWATCH_TICKFREQUENCY] = $STOPWATCH_TICKSPERSECOND
		$aStopwatch[$STOPWATCH_TICKFREQUENCY] /= $aStopwatch[$STOPWATCH_FREQUENCY]
	EndIf
	$aStopwatch[$STOPWATCH_ID] = $STOPWATCH_GUID
	Return $aStopwatch
EndFunc   ;==>Stopwatch

Func Stopwatch_ElapsedMilliseconds(ByRef $aStopwatch)
	Local $iElapsedTime = 0
	If __Stopwatch_IsStopwatch($aStopwatch) Then
		$iElapsedTime = __Stopwatch_GetElapsedDateTimeTicks($aStopwatch) / $STOPWATCH_TICKSPERMILLISECOND
	EndIf
	Return $iElapsedTime
EndFunc   ;==>Stopwatch_ElapsedMilliseconds

Func Stopwatch_ElapsedTicks(ByRef $aStopwatch)
	Local $iElapsedTime = 0
	If __Stopwatch_IsStopwatch($aStopwatch) Then
		$iElapsedTime = __Stopwatch_GetRawElapsedTicks($aStopwatch)
	EndIf
	Return $iElapsedTime
EndFunc   ;==>Stopwatch_ElapsedTicks

Func Stopwatch_IsRunning(ByRef $aStopwatch)
	Return __Stopwatch_IsStopwatch($aStopwatch) ? $aStopwatch[$STOPWATCH_RUNNING] : Null
EndFunc   ;==>Stopwatch_IsRunning

Func Stopwatch_Reset(ByRef $aStopwatch)
	If __Stopwatch_IsStopwatch($aStopwatch) Then
		$aStopwatch[$STOPWATCH_ELAPSED] = 0
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
		$aStopwatch[$STOPWATCH_TIMER] = __Stopwatch_GetTimestamp($aStopwatch)
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
		$aStopwatch[$STOPWATCH_ELAPSED] = __Stopwatch_GetRawElapsedTicks($aStopwatch)
		$aStopwatch[$STOPWATCH_RUNNING] = False
	EndIf
	Return True
EndFunc   ;==>Stopwatch_Stop

Func __Stopwatch_GetElapsedDateTimeTicks(ByRef $aStopwatch)
	Local $iRawElapsedTime = __Stopwatch_GetRawElapsedTicks($aStopwatch)
	If $aStopwatch[$STOPWATCH_ISHIGHRESOLUTION] Then
		$iRawElapsedTime *= $aStopwatch[$STOPWATCH_TICKFREQUENCY]
	Else
		$iRawElapsedTime *= $STOPWATCH_TICKSPERMILLISECOND
	EndIf
	Return $iRawElapsedTime
EndFunc   ;==>__Stopwatch_GetElapsedDateTimeTicks

Func __Stopwatch_GetRawElapsedTicks(ByRef $aStopwatch)
	Local $iElapsedTime = $aStopwatch[$STOPWATCH_ELAPSED]
	If $aStopwatch[$STOPWATCH_RUNNING] Then
		If $aStopwatch[$STOPWATCH_ISHIGHRESOLUTION] Then
			Local $iTimeStamp = __Stopwatch_GetTimestamp($aStopwatch)
			$iTimeStamp = $iTimeStamp - $aStopwatch[$STOPWATCH_TIMER]
			$iElapsedTime += $iTimeStamp
		Else
			$iElapsedTime += TimerDiff($aStopwatch[$STOPWATCH_TIMER])
		EndIf
	EndIf
	Return $iElapsedTime
EndFunc   ;==>__Stopwatch_GetRawElapsedTicks

Func __Stopwatch_GetTimestamp(ByRef $aStopwatch)
	If $aStopwatch[$STOPWATCH_ISHIGHRESOLUTION] Then
		Return _WinAPI_QueryPerformanceCounter()
	Else
		Return TimerInit()
	EndIf
EndFunc   ;==>__Stopwatch_GetTimestamp

Func __Stopwatch_IsStopwatch(ByRef $aStopwatch) ; Internal function only.
	Return UBound($aStopwatch) = $STOPWATCH_MAX And $aStopwatch[$STOPWATCH_ID] = $STOPWATCH_GUID
EndFunc   ;==>__Stopwatch_IsStopwatch
