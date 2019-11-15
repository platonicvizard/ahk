#include <log4ahk.ahk>

; Initialize the logger
logger := new log4ahk()

; Set the appenders to be logged to: STDOUT 
logger.appenders.push(new logger.appenderstdout())

;#x::ExitApp  ; Assign a hotkey to terminate this script.


MsgBox % KeyWaitAny()

; Same again, but don't block the key.
MsgBox % KeyWaitAny("V")

KeyWaitAny(Options:="")
{  
    ih := InputHook(Options)
    ih.KeyOpt("{All}", "ES")  ; End and Suppress
    ih.Start()
    ErrorLevel := ih.Wait()  ; Store EndReason in ErrorLevel
	DllCall("LockWorkStation")
	ExitApp
    return ih.EndKey  ; Return the key name
}


MouseGetPos, StartVarX, StartVarY
loop
{
sleep, 100
MouseGetPos, CheckVarX, CheckVarY
If (StartVarX != CheckVarX) or (StartVarY != CheckVarY) 
{

	DllCall("LockWorkStation")
	ExitApp
	
}
     
}


#Persistent
SetTimer,Timer,300
Return

Timer:
     MouseGetPos,x1,y1
     Sleep,500
     MouseGetPos,x2,y2
     If ((x1<>x2) or (y1<>y2))             ;-- Checking to see if the mouse has moved.
         {
         
		 DllCall("LockWorkStation")
	ExitApp
		 
         Return
         }
return
esc::exitapp
