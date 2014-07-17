#AutoIt3Wrapper_Run_Au3Check=N
Local $aAnswers = [Int(InputBox("Paper, Rock, Scissors by guinness (c) 2014", "1 = Rock, 2 = Paper, 3 = Scissors")), _ ; On one line, though split for easy reading.
		"Rock", "Paper", "Scissors", Int(Random(1, 3, 1)), _
		MsgBox(4096, "Paper, Rock, Scissors by guinness (c) 2014", _
		((StringRegExp($aAnswers[0], "^[123]{1}$") = 0) ? "Please enter a valid value next time." : _
		"You chose " & $aAnswers[$aAnswers[0]] & " and the computer chose " & $aAnswers[$aAnswers[4]] & " with an outcome of " & (($aAnswers[0] = $aAnswers[4]) ? "the same" : _
		((($aAnswers[0] = 1 And $aAnswers[4] = 3) Or ($aAnswers[0] = 2 And $aAnswers[4] = 1) Or ($aAnswers[0] = 3 And $aAnswers[4] = 2)) ? "winning" : "losing"))) & @CRLF)]
