#SingleInstance Force
#Include OCR.ahk

CoordMode, Mouse, Screen

^Rbutton::
Gui, Color, blue
Gui, +LastFound -caption +border +AlwaysOnTop
WinSet, Transparent, 50
MouseGetPos, Xpos1, Ypos1
loop {
	MouseGetPos, Xpos2, Ypos2
	Xpos3 := (Xpos2 > Xpos1) ? Xpos2 - Xpos1 : Xpos1 - Xpos2
	Ypos3 := (Ypos2 > Ypos1) ? Ypos2 - Ypos1 : Ypos1 - Ypos2
	XPos4 := (Xpos2 > Xpos1) ? Xpos1 : Xpos2
	YPos4 := (Ypos2 > Ypos1) ? Ypos1 : Ypos2
	Gui, Show, x%Xpos4% y%Ypos4% w%Xpos3% h%Ypos3%
	GetKeyState, Key, Rbutton, P
	If Key = U
		Break
}
Gui, Destroy
OCR := GetOCR(XPos4, Ypos4, Xpos3, Ypos3)
MsgBox, 4,, %OCR%
IfMsgBox, Yes
	clipboard := OCR
Return