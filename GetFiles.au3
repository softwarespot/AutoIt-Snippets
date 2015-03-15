#include <WinAPIFiles.au3>

Global Enum Step *2 $GETFILES_NOT_DIRECTORY, $GETFILES_NOT_EXISTS ; GetFiles @error

Example()

Func Example()
	Local $sFileList = ''
	GetFiles($sFileList, @ScriptDir) ; This uses no global variable
	If @error Then
		ConsoleWrite("Error: Check the enumeration above that matches the error code = " & @error & @CRLF)
	Else
		$sFileList = StringReplace($sFileList, '|', @CRLF) ; Replace the pipe char for @CRLF
		ConsoleWrite($sFileList & @CRLF)
	EndIf
EndFunc   ;==>Example

Func GetFiles(ByRef $sFileList, $sFilePath)
	Local Static $iCounter = 0

	$sFilePath = _WinAPI_PathAddBackslash($sFilePath) ; Add backslash
	If _WinAPI_PathIsDirectory($sFilePath) <> $FILE_ATTRIBUTE_DIRECTORY Then ; Is not a directory
		Return SetError($GETFILES_NOT_DIRECTORY, 0, '')
	EndIf

	Local $hFileFind = FileFindFirstFile($sFilePath & '*')
	If $hFileFind = -1 Then ; File not found
		Return SetError($GETFILES_NOT_EXISTS, 0, '')
	EndIf

	Local $sFileName = ''
	While True
		$sFileName = FileFindNextFile($hFileFind)
		If @error Then
			ExitLoop
		EndIf

		If @extended Then ; Is directory.
			$iCounter += 1 ; Used for recursion level
			GetFiles($sFileList, $sFilePath & $sFileName)
			$iCounter -= 1 ; Used for recursion level
		Else
			$sFileList &= $sFilePath & $sFileName & '|'
		EndIf
	WEnd
	FileClose($hFileFind)

	If $iCounter = 0 Then ; First recursion level, therefore strip pipe char
		$sFileList = StringTrimRight($sFileList, StringLen('|'))
	EndIf
EndFunc   ;==>GetFiles
