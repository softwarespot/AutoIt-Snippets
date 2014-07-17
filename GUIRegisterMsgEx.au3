; Initial idea by mLipok: http://www.autoitscript.com/forum/topic/162515-guiregistermsg-udf/
; Compared to mine mLipok's idea was limited to a certain set of WM_MESSAGES and would call all the registered functions.
; This UDF works as was suggested in the Trac Tickets: #2624 & #2629, where each WM_MESSAGE is associated with a function. It's basically
; allowing GUIRegisterMsg() to register multiple messages.

#include <GUIConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>

Global Const $GUIREGISTERMSGEX_GUID = 'E5D40BB9-0B3F-4515-8A75-225A9C3E9B43'
Global Enum $GUIREGISTERMSGEX_ADD = 1025, $GUIREGISTERMSGEX_DELETE ; 1025 = $WM_USER + 1
Global Const $GUIREGISTERMSGEX = 0
Global Enum $GUIREGISTERMSGEX_FIRSTCOL_INDEX, $GUIREGISTERMSGEX_MESSAGEINDEX, $GUIREGISTERMSGEX_FIRSTROW_INDEX
Global Enum $GUIREGISTERMSGEX_COLUMN_UBOUND, $GUIREGISTERMSGEX_ID, $GUIREGISTERMSGEX_INDEX, $GUIREGISTERMSGEX_RESETCOUNT, $GUIREGISTERMSGEX_ROW_UBOUND, $GUIREGISTERMSGEX_MESSAGESTRING, $GUIREGISTERMSGEX_MAX
Global Const $GUIREGISTERMSGEX_CALL_ERROR = 0xDEAD
Global Const $GUIREGISTERMSGEX_CALL_PARAMS = 0xBEEF

#Region Example usage.

Example()

Func Example() ; By Melba23
	Local $hGUI = GUICreate('Test', 500, 500)
	Local $idButton_R1 = GUICtrlCreateButton('Reg 1', 10, 10, 80, 30)
	Local $idButton_U1 = GUICtrlCreateButton('UnReg 1', 100, 10, 80, 30)
	GUICtrlCreateLabel('ConsoleWrite ''1'' if mouse moved', 200, 20, 300, 20)
	Local $idButton_R2 = GUICtrlCreateButton('Reg 2', 10, 50, 80, 30)
	Local $idButton_U2 = GUICtrlCreateButton('UnReg 2', 100, 50, 80, 30)
	GUICtrlCreateLabel('ConsoleWrite ''2'' if mouse moved', 200, 60, 300, 20)
	Local $idButton_R3 = GUICtrlCreateButton('Reg 3', 10, 90, 80, 30)
	Local $idButton_U3 = GUICtrlCreateButton('UnReg 3', 100, 90, 80, 30)
	GUICtrlCreateLabel('ConsoleWrite ''Left'' if left button pressed', 200, 100, 300, 20)
	Local $idButton_R4 = GUICtrlCreateButton('Reg 4', 10, 130, 80, 30)
	Local $idButton_U4 = GUICtrlCreateButton('UnReg 4', 100, 130, 80, 30)
	GUICtrlCreateLabel('ConsoleWrite ''Right'' if right button pressed', 200, 140, 300, 20)

	GUISetState(@SW_SHOW, $hGUI)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idButton_R1
				_GUIRegisterMsgEx($WM_MOUSEMOVE, _Move_1)
				ConsoleWrite(@CRLF)

			Case $idButton_U1
				_GUIRegisterMsgEx($WM_MOUSEMOVE, _Move_1, True)
				ConsoleWrite(@CRLF)

			Case $idButton_R2
				_GUIRegisterMsgEx($WM_MOUSEMOVE, _Move_2)
				ConsoleWrite(@CRLF)

			Case $idButton_U2
				_GUIRegisterMsgEx($WM_MOUSEMOVE, _Move_2, True)
				ConsoleWrite(@CRLF)

			Case $idButton_R3
				_GUIRegisterMsgEx($WM_LBUTTONDOWN, _Press_1)
				ConsoleWrite(@CRLF)

			Case $idButton_U3
				_GUIRegisterMsgEx($WM_LBUTTONDOWN, _Press_1, True)
				ConsoleWrite(@CRLF)

			Case $idButton_R4
				_GUIRegisterMsgEx($WM_RBUTTONDOWN, _Press_2)
				ConsoleWrite(@CRLF)

			Case $idButton_U4
				_GUIRegisterMsgEx($WM_RBUTTONDOWN, _Press_2, True)
				ConsoleWrite(@CRLF)

		EndSwitch
	WEnd
	GUIDelete($hGUI)
EndFunc   ;==>Example

Func _Move_1($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	ConsoleWrite('1')
EndFunc   ;==>_Move_1

Func _Move_2($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	ConsoleWrite('2')
EndFunc   ;==>_Move_2

Func _Press_1($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	ConsoleWrite(' Left ')
EndFunc   ;==>_Press_1

Func _Press_2($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	ConsoleWrite(' Right ')
EndFunc   ;==>_Press_2

#cs
	_GUIRegisterMsgEx($WM_COMMAND, DummyFunction) ; Register DummyFunction() when WM_COMMAND is called.

	_GUIRegisterMsgEx($WM_COPYDATA, DummyFunction)
	_GUIRegisterMsgEx($WM_COPYDATA, DummyFunction) ; Duplicates won't be added to the GUIRegisterMsg().
	_GUIRegisterMsgEx($WM_COPYDATA, SomeFunc)

	_GUIRegisterMsgEx($WM_COPYDATA, DummyFunction, True) ; Unregister the WM_COPYDATA message to call DummyFunction()

	_GUIRegisterMsgEx($WM_SIZE, DummyFunction)
	_GUIRegisterMsgEx($WM_SIZE, SomeFunc)
	_GUIRegisterMsgEx($WM_SIZE, DummyFunction, True) ; Unregister the $WM_SIZE message to call DummyFunction()
	_GUIRegisterMsgEx($WM_SIZE, DummyFunction)

	Func DummyFunction()
	EndFunc   ;==>DummyFunction

	Func SomeFunc()
	EndFunc   ;==>SomeFunc
#ce
#EndRegion Example usage.

Func _GUIRegisterMsgEx($iWM_MESSAGE, $fuDelegate, $bIsUnRegister = False) ; Returns True or False.
	Return __GUIRegisterMsgEx_EVENTPROC($fuDelegate, $iWM_MESSAGE, ($bIsUnRegister ? $GUIREGISTERMSGEX_DELETE : $GUIREGISTERMSGEX_ADD), Null)
EndFunc   ;==>_GUIRegisterMsgEx

Func __GUIRegisterMsgEx_EVENTPROC($hWnd, $iMsg, $wParam, $lParam) ; $hWnd = Func, $iMsg = Windows (WM) message, $wParam = Internal message.
	Local Static $aStorage[$GUIREGISTERMSGEX_FIRSTROW_INDEX][$GUIREGISTERMSGEX_MAX] ; Internal array for storing the WM_MESSAGE and the associated function to call.

	If Not ($aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_ID] = $GUIREGISTERMSGEX_GUID) Then ; Initialise the internal array.

		$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_ID] = $GUIREGISTERMSGEX_GUID

		$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_INDEX] = 0

		$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_RESETCOUNT] = 0

		$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_COLUMN_UBOUND] = $GUIREGISTERMSGEX_MAX
		$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_ROW_UBOUND] = $GUIREGISTERMSGEX_FIRSTROW_INDEX

		$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_MESSAGESTRING] = '|'
	EndIf

	Local $iIndex = Int(StringRegExp($aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_MESSAGESTRING] & '|' & Int($iMsg) & '*-1|', '\|' & Int($iMsg) & '\*(\-?\d+)\|', $STR_REGEXPARRAYGLOBALMATCH)[0])
	Switch $wParam
		Case $GUIREGISTERMSGEX_ADD
			If $iIndex < 0 Then
				$iIndex = $aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_INDEX]
				$aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] = $GUIREGISTERMSGEX_MESSAGEINDEX
				$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_MESSAGESTRING] &= Int($iMsg) & '*' & $iIndex & '|'
				$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_INDEX] += 1
				GUIRegisterMsg($iMsg, __GUIRegisterMsgEx_EVENTPROC) ; Register the message. Note: Once registered this function will always be associated with that message.
			EndIf

			Local $bIsDelegateExists = False
			For $i = $GUIREGISTERMSGEX_FIRSTROW_INDEX To $aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] ; Row count.
				If $aStorage[$i][$iIndex] = $hWnd Then
					$bIsDelegateExists = True
					ExitLoop
				EndIf
			Next

			If Not $bIsDelegateExists Then
				$aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] += 1 ; Increase the count of the message column.

				Local $bIsColAdd = ($iIndex + 1) >= $aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_COLUMN_UBOUND], _ ; Re-size the internal array.
						$bIsRowAdd = $aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] >= $aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_ROW_UBOUND]

				If $bIsColAdd Or $bIsRowAdd Then ; Re-size the internal storage if required.
					If $bIsColAdd Then $aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_COLUMN_UBOUND] = Ceiling($iIndex * 1.3)
					If $bIsRowAdd Then $aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_ROW_UBOUND] = Ceiling($aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] * 1.3)
					ReDim $aStorage[$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_ROW_UBOUND]][$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_COLUMN_UBOUND]]
				EndIf
				$aStorage[$aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex]][$iIndex] = $hWnd
			EndIf
			Return Not $bIsDelegateExists

		Case $GUIREGISTERMSGEX_DELETE
			Local $bIsDeleted = False
			If $iIndex >= 0 Then
				For $i = $GUIREGISTERMSGEX_FIRSTROW_INDEX To $aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] ; Row count.
					If $aStorage[$i][$iIndex] = $hWnd Then
						$aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_RESETCOUNT] += 1
						$aStorage[$i][$iIndex] = Null
						$bIsDeleted = True
					EndIf
				Next
				If $bIsDeleted And $aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_RESETCOUNT] >= 0 Then ; Tidy the internal array by removing empty values.
					Local $iCurrentIndex = $GUIREGISTERMSGEX_FIRSTROW_INDEX
					For $i = $GUIREGISTERMSGEX_FIRSTCOL_INDEX To $aStorage[$GUIREGISTERMSGEX][$GUIREGISTERMSGEX_INDEX] - 1 ; Column count.
						For $j = $GUIREGISTERMSGEX_FIRSTROW_INDEX To $aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$i]
							If $aStorage[$j][$i] = Null Then
								$aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$i] -= 1
								ContinueLoop
							EndIf
							$aStorage[$iCurrentIndex][$i] = $aStorage[$j][$i]
							$iCurrentIndex += 1
						Next
						$iCurrentIndex = $GUIREGISTERMSGEX_FIRSTROW_INDEX
					Next
				EndIf
			EndIf
			Return $bIsDeleted

		Case Else ; WM_MESSAGE.
			If $iIndex >= 0 And $aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] >= $GUIREGISTERMSGEX_FIRSTROW_INDEX Then
				For $i = $GUIREGISTERMSGEX_FIRSTROW_INDEX To $aStorage[$GUIREGISTERMSGEX_MESSAGEINDEX][$iIndex] ; Row count.
					; If IsFunc($aStorage[$i][$iIndex]) Then
					; $aStorage[$i][$iIndex]($hWnd, $iMsg, $wParam, $lParam) ; Execute the registered functions.
					; EndIf
					If IsFunc($aStorage[$i][$iIndex]) Then
						Call($aStorage[$i][$iIndex], $hWnd, $iMsg, $wParam, $lParam)
						If (@error = $GUIREGISTERMSGEX_CALL_ERROR And @extended = $GUIREGISTERMSGEX_CALL_PARAMS) Then
							Call($aStorage[$i][$iIndex], $hWnd, $iMsg, $wParam)
							If (@error = $GUIREGISTERMSGEX_CALL_ERROR And @extended = $GUIREGISTERMSGEX_CALL_PARAMS) Then
								Call($aStorage[$i][$iIndex], $hWnd, $iMsg)
								If (@error = $GUIREGISTERMSGEX_CALL_ERROR And @extended = $GUIREGISTERMSGEX_CALL_PARAMS) Then
									Call($aStorage[$i][$iIndex], $hWnd)
									If (@error = $GUIREGISTERMSGEX_CALL_ERROR And @extended = $GUIREGISTERMSGEX_CALL_PARAMS) Then
										Call($aStorage[$i][$iIndex])
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next
			EndIf

	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>__GUIRegisterMsgEx_EVENTPROC
