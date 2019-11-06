;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
varshow1 := 0
varshow2 := 0
varshow3 := 0

^1::testFunc()
^2::varshow2=1
^3::varshow3=1

testFunc() {
if(varshow1 != 0) {
	MsgBox, tesssssst
	ExitApp
}
}




