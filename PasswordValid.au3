#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

; Constants for the PasswordValid object
Global Const $PASSWORDVALID_GUID = '501E91C9-58DC-4FA0-ABF8-212914D9EFDD', $PASSWORDVALID_FLAG_VALID = 0
Global Enum $PASSWORDVALID_CONSECUTIVE, $PASSWORDVALID_ID, $PASSWORDVALID_INTS, $PASSWORDVALID_LENGTH, $PASSWORDVALID_LOWERCASE, _
		$PASSWORDVALID_SPACE, $PASSWORDVALID_SPECIAL, $PASSWORDVALID_UPPERCASE, $PASSWORDVALID_MAX

; Enumeration flags
Global Enum Step * 2 $PASSWORDVALID_FLAG_CONSECUTIVE, _
		$PASSWORDVALID_FLAG_INTS, _
		$PASSWORDVALID_FLAG_LENGTH, _
		$PASSWORDVALID_FLAG_LOWERCASE, _
		$PASSWORDVALID_FLAG_SPACE, _
		$PASSWORDVALID_FLAG_SPECIAL, _
		$PASSWORDVALID_FLAG_UPPERCASE, _
		$PASSWORDVALID_FLAG_UNKNOWN

#cs
	> _PasswordValid => Create a password object
	> _PasswordValid_AllowConsecutive => Set to True/False to allow consecutive characters e.g. the S in Password. Default is True
	> _PasswordValid_AllowSpace => Set to True/False to allow spaces. Default is False
	> _PasswordValid_Ints => Set a value for the minimum number of integers. Default is 0
	> _PasswordValid_Length => Set a value for the minimum number of characters. Default is 0
	> _PasswordValid_Lowercase => Set a value for the minimum number of lowercase characters. Default is 0
	> _PasswordValid_Special => Set a value for the minimum number of special characters (ASCII - (33-47, 58-64, 91-96, 123-126) see below). Default is 0
	> _PasswordValid_Uppercase => Set a value for the minimum number of uppercase characters. Default is 0
	> _PasswordValid_Validate => Check if a password matches the specs set

	@extended returns the reason as to why the password passed or failed. Use the following functions to determine the reason as to why
	> _PasswordValid_Error_IsConsecutive => The password failed due to consecutive characters
	> _PasswordValid_Error_IsInts => The password failed due to the minimum number of integers
	> _PasswordValid_Error_IsLength => The password failed due to the minimun length
	> _PasswordValid_Error_IsLowercase => The password failed due the minimum number of lowercase characters
	> _PasswordValid_Error_IsSpace => The password failed due to usage of spaces
	> _PasswordValid_Error_IsSpecial => The password failed due to the minimum number of special characters
	> _PasswordValid_Error_IsUnknown => The object was invalid
	> _PasswordValid_Error_IsUppercase => The password failed due to the minimum number of uppercase characters
	> _PasswordValid_Error_IsValid => The password was valid

	All functions require the object returned by _PasswordValid() to be passed as the first parameter & the second parameter to set the value

	Note: _PasswordValid() doesn't require any parameters to be passed & the second parameter of _PasswordValid_Validate() is the password to validate
	Passwords are case-sensitive, therefore Password is different to that of PasSword

	Special characters include: ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
#ce

Example()

Func Example()
	; Create a password object
	Local $hPassword = _PasswordValid()

	; Assign the password object with allowing a minimum of 2 integers
	_PasswordValid_Ints($hPassword, 2)

	; Assign the password object with allowing a minimum of 6 characters
	_PasswordValid_Length($hPassword, 6)

	; Assign the password object with allowing a minimum of 2 lowercase characters
	_PasswordValid_Lowercase($hPassword, 2)

	; Allow characters to follow after each other
	_PasswordValid_AllowConsecutive($hPassword, True)

	; This password is set to fail, but it's to showcase the @extended return values
	Local Const $bIsValid = _PasswordValid_Validate($hPassword, '4u0')
	Local Const $iErrorFlags = @extended

	ConsoleWrite('The password 4u0 ' & ($bIsValid ? 'passed' : 'failed') & ' the validation. See below for more details.' & @CRLF)

	; Custom function to output to SciTE's console of what exactly failed
	PasswordError($iErrorFlags)

	; Display the result
	MsgBox($MB_SYSTEMMODAL, '', 'Is the password 4ut01It valid: ' & _PasswordValid_Validate($hPassword, '4ut01It'))

	; Destroy the password object
	$hPassword = Null
EndFunc   ;==>Example

; An example of parsing the @extended flag to determine what exactly failed
Func PasswordError($iFlags = @extended)
	If _PasswordValid_Error_IsValid($iFlags) Then
		ConsoleWrite('The password was valid.' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsConsecutive($iFlags) Then
		ConsoleWrite('The password contained repeating characters e.g. S in Password.' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsInts($iFlags) Then
		ConsoleWrite('The password didn''t contain the minimum number of digits.' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsLength($iFlags) Then
		ConsoleWrite('The password didn''t match the miminum length.' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsLowercase($iFlags) Then
		ConsoleWrite('The password didn''t contain the minimum number of lowercase characters.' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsSpace($iFlags) Then
		ConsoleWrite('The password contained space(s).' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsSpecial($iFlags) Then
		ConsoleWrite('The password didn''t contain the minimum number of special characters.' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsUppercase($iFlags) Then
		ConsoleWrite('The password didn''t contain the minimum number of uppercase characters.' & @CRLF)
	EndIf
	If _PasswordValid_Error_IsUnknown($iFlags) Then
		ConsoleWrite('The password object wasn''t valid.' & @CRLF)
	EndIf

	Return True
EndFunc   ;==>PasswordError

#Region PasswordValid UDF functions
Func _PasswordValid()
	Local $aPasswordValid[$PASSWORDVALID_MAX]
	For $i = 0 To $PASSWORDVALID_MAX - 1
		; Set all fields to zero
		$aPasswordValid[$i] = 0
	Next

	; Set the GUID to validate that it's a valid API later on
	$aPasswordValid[$PASSWORDVALID_ID] = $PASSWORDVALID_GUID

	; Set the default of "AllowConsecutive" to True
	_PasswordValid_AllowConsecutive($aPasswordValid, True)

	; Set the default of "AllowSpace" to False
	_PasswordValid_AllowSpace($aPasswordValid, False)

	Return $aPasswordValid
EndFunc   ;==>_PasswordValid

Func _PasswordValid_AllowConsecutive(ByRef $aPasswordValid, $bValue)
	Local $bReturn = False
	If __PasswordValid_IsAPI($aPasswordValid) And IsBool($bValue) Then
		$bReturn = True
		$aPasswordValid[$PASSWORDVALID_CONSECUTIVE] = $bValue
	EndIf

	Return $bReturn
EndFunc   ;==>_PasswordValid_AllowConsecutive

Func _PasswordValid_AllowSpace(ByRef $aPasswordValid, $bValue)
	Local $bReturn = False
	If __PasswordValid_IsAPI($aPasswordValid) And IsBool($bValue) Then
		$bReturn = True
		$aPasswordValid[$PASSWORDVALID_SPACE] = $bValue
	EndIf

	Return $bReturn
EndFunc   ;==>_PasswordValid_AllowSpace

Func _PasswordValid_Ints(ByRef $aPasswordValid, $iValue)
	Local $bReturn = False
	If __PasswordValid_IsAPI($aPasswordValid) And (IsInt($iValue) Or StringIsInt($iValue)) Then
		$bReturn = True
		$aPasswordValid[$PASSWORDVALID_INTS] = Int($iValue)
	EndIf

	Return $bReturn
EndFunc   ;==>_PasswordValid_Ints

Func _PasswordValid_Length(ByRef $aPasswordValid, $iValue)
	Local $bReturn = False
	If __PasswordValid_IsAPI($aPasswordValid) And (IsInt($iValue) Or StringIsInt($iValue)) Then
		$bReturn = True
		$aPasswordValid[$PASSWORDVALID_LENGTH] = Int($iValue)
	EndIf

	Return $bReturn
EndFunc   ;==>_PasswordValid_Length

Func _PasswordValid_Lowercase(ByRef $aPasswordValid, $iValue)
	Local $bReturn = False
	If __PasswordValid_IsAPI($aPasswordValid) And (IsInt($iValue) Or StringIsInt($iValue)) Then
		$bReturn = True
		$aPasswordValid[$PASSWORDVALID_LOWERCASE] = Int($iValue)
	EndIf

	Return $bReturn
EndFunc   ;==>_PasswordValid_Lowercase

Func _PasswordValid_Special(ByRef $aPasswordValid, $iValue)
	Local $bReturn = False
	If __PasswordValid_IsAPI($aPasswordValid) And (IsInt($iValue) Or StringIsInt($iValue)) Then
		$bReturn = True
		$aPasswordValid[$PASSWORDVALID_SPECIAL] = Int($iValue)
	EndIf

	Return $bReturn
EndFunc   ;==>_PasswordValid_Special

Func _PasswordValid_Uppercase(ByRef $aPasswordValid, $iValue)
	Local $bReturn = False
	If __PasswordValid_IsAPI($aPasswordValid) And (IsInt($iValue) Or StringIsInt($iValue)) Then
		$bReturn = True
		$aPasswordValid[$PASSWORDVALID_UPPERCASE] = Int($iValue)
	EndIf

	Return $bReturn
EndFunc   ;==>_PasswordValid_Uppercase

Func _PasswordValid_Validate(ByRef $aPasswordValid, $sPassword)
	Local $iFlags = $PASSWORDVALID_FLAG_UNKNOWN
	If __PasswordValid_IsAPI($aPasswordValid) Then
		$iFlags = $PASSWORDVALID_FLAG_VALID

		Local $bIsValid = False
		If Not $aPasswordValid[$PASSWORDVALID_CONSECUTIVE] Then
			$bIsValid = Not StringRegExp($sPassword, '(.)\1')
			If Not $bIsValid Then
				$iFlags = BitOR($iFlags, $PASSWORDVALID_FLAG_CONSECUTIVE)
			EndIf
		EndIf

		If $aPasswordValid[$PASSWORDVALID_INTS] > 0 Then
			$bIsValid = UBound(StringRegExp($sPassword, '\d', $STR_REGEXPARRAYGLOBALMATCH)) >= $aPasswordValid[$PASSWORDVALID_INTS]
			If Not $bIsValid Then
				$iFlags = BitOR($iFlags, $PASSWORDVALID_FLAG_INTS)
			EndIf
		EndIf

		If $aPasswordValid[$PASSWORDVALID_LENGTH] > 0 Then
			$bIsValid = UBound(StringRegExp($sPassword, '\S', $STR_REGEXPARRAYGLOBALMATCH)) >= $aPasswordValid[$PASSWORDVALID_LENGTH]
			If Not $bIsValid Then
				$iFlags = BitOR($iFlags, $PASSWORDVALID_FLAG_LENGTH)
			EndIf
		EndIf

		If $aPasswordValid[$PASSWORDVALID_LOWERCASE] > 0 Then
			$bIsValid = UBound(StringRegExp($sPassword, '[a-z]', $STR_REGEXPARRAYGLOBALMATCH)) >= $aPasswordValid[$PASSWORDVALID_LOWERCASE]
			If Not $bIsValid Then
				$iFlags = BitOR($iFlags, $PASSWORDVALID_FLAG_LOWERCASE)
			EndIf
		EndIf

		If Not $aPasswordValid[$PASSWORDVALID_SPACE] Then
			$bIsValid = Not StringRegExp($sPassword, '\s')
			If Not $bIsValid Then
				$iFlags = BitOR($iFlags, $PASSWORDVALID_FLAG_SPACE)
			EndIf
		EndIf

		If $aPasswordValid[$PASSWORDVALID_SPECIAL] > 0 Then
			$bIsValid = UBound(StringRegExp($sPassword, '[[:punct:]]', $STR_REGEXPARRAYGLOBALMATCH)) >= $aPasswordValid[$PASSWORDVALID_SPECIAL]
			If Not $bIsValid Then
				$iFlags = BitOR($iFlags, $PASSWORDVALID_FLAG_SPECIAL)
			EndIf
		EndIf

		If $aPasswordValid[$PASSWORDVALID_UPPERCASE] > 0 Then
			$bIsValid = UBound(StringRegExp($sPassword, '[A-Z]', $STR_REGEXPARRAYGLOBALMATCH)) >= $aPasswordValid[$PASSWORDVALID_UPPERCASE]
			If Not $bIsValid Then
				$iFlags = BitOR($iFlags, $PASSWORDVALID_FLAG_UPPERCASE)
			EndIf
		EndIf
	EndIf

	Return SetExtended($iFlags, $iFlags == $PASSWORDVALID_FLAG_VALID)
EndFunc   ;==>_PasswordValid_Validate

; Internal function for checking the opaque array is a valid API
Func __PasswordValid_IsAPI(ByRef $aPasswordValid)
	Return UBound($aPasswordValid) == $PASSWORDVALID_MAX And $aPasswordValid[$PASSWORDVALID_ID] == $PASSWORDVALID_GUID
EndFunc   ;==>__PasswordValid_IsAPI

; @extended parsing relating functions

; Error was related to consecutive values
Func _PasswordValid_Error_IsConsecutive($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_CONSECUTIVE)
EndFunc   ;==>_PasswordValid_Error_IsConsecutive

; Error was related to incorrect number of integers
Func _PasswordValid_Error_IsInts($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_INTS)
EndFunc   ;==>_PasswordValid_Error_IsInts

; Error was related to an invalid length
Func _PasswordValid_Error_IsLength($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_LENGTH)
EndFunc   ;==>_PasswordValid_Error_IsLength

; Error was related to incorrect number of lowercase characters
Func _PasswordValid_Error_IsLowercase($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_LOWERCASE)
EndFunc   ;==>_PasswordValid_Error_IsLowercase

; Error was related to containing spaces
Func _PasswordValid_Error_IsSpace($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_SPACE)
EndFunc   ;==>_PasswordValid_Error_IsSpace

; Error was related to incorrect number of uppercase characters
Func _PasswordValid_Error_IsSpecial($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_SPECIAL)
EndFunc   ;==>_PasswordValid_Error_IsSpecial

; Error was related to an unknown error
Func _PasswordValid_Error_IsUnknown($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_UNKNOWN)
EndFunc   ;==>_PasswordValid_Error_IsUnknown

; Error was related to incorrect number of uppercase characters
Func _PasswordValid_Error_IsUppercase($iFlags)
	Return __PasswordValid_Error_BitValidator($iFlags, $PASSWORDVALID_FLAG_UPPERCASE)
EndFunc   ;==>_PasswordValid_Error_IsUppercase

Func _PasswordValid_Error_IsValid($iFlags)
	Return $iFlags == $PASSWORDVALID_FLAG_VALID
EndFunc   ;==>_PasswordValid_Error_IsValid

; Internal function for the BitAND checking
Func __PasswordValid_Error_BitValidator($iFlags, $iFlag)
	Return BitAND($iFlags, $iFlag) == $iFlag
EndFunc   ;==>__PasswordValid_Error_BitValidator
#EndRegion PasswordValid UDF functions
