#include <StringConstants.au3>

#cs
	Links that were useful in understanding Base62:
	http://stackoverflow.com/questions/742013/how-to-code-a-url-shortener
	https://www.flickr.com/groups/api/discuss/72157616713786392/
	http://www.purplemath.com/modules/numbbase3.htm
#ce

; Global constants for the decoding and encoding functions.
Global Const $g_sChars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', _
		$g_aChars = StringSplit($g_sChars, '', $STR_NOCOUNT), _
		$g_iBase = StringLen($g_sChars)

Example()

Func Example()
	Local $iNumber = Random(0, 10000, 1) ; Create a random integer.

	; Encode the integer.
	ConsoleWrite('Encode ' & $iNumber & ' to a string id.' & @CRLF)
	Local $sId = UrlShorten_Encode($iNumber)
	ConsoleWrite($iNumber & ' >> ' & $sId & @CRLF)

	; Decode the string.
	ConsoleWrite('Decode ' & $sId & ' to a numerical id.' & @CRLF)
	ConsoleWrite($sId & ' >> ' & UrlShorten_Decode($sId) & @CRLF)
EndFunc   ;==>Example

; Decode a string id to a numerical value.
Func UrlShorten_Decode($sId)
	If Not IsString($sId) Or StringStripWS($sId, $STR_STRIPALL) == '' Then Return -1
	Local $aDigits = StringSplit($sId, '', $STR_NOCOUNT)
	If @error Then Return -1

	Local $iId = 0
	Local $iPower = 0
	For $i = 0 To UBound($aDigits) - 1
		$iId += ((StringInStr($g_sChars, $aDigits[$i], $STR_CASESENSE) - 1) * ($g_iBase ^ $iPower)) ; Find the position and multiply by the base (62) ^ n.
		$iPower += 1 ; Increase the power. Normally this would be decreasing, but the string wasn't reversed by the encoding function.
	Next
	Return $iId ; Return the id. -1 equals a fatal error occurred.
EndFunc   ;==>UrlShorten_Decode

; Encode a numerical id to a string value.
Func UrlShorten_Encode($iId)
	If Not IsInt($iId) Or $iId <= -1 Then Return '-1'
	If $iId = 0 Then Return $g_aChars[0]

	Local $sId = ''
	While $iId > 0
		$sId &= $g_aChars[Mod($iId, $g_iBase)]
		$iId = Int($iId / $g_iBase)
	WEnd
	Return $sId ; Return the id. '-1' equals a fatal error occurred.
	; Normally the chars would be reversed, but as this is a cosmetic feature it's not really required.
EndFunc   ;==>UrlShorten_Encode
