; #SingleInstance, Force
; #KeyHistory, 0
; SetBatchLines, -1
; ListLines, Off
; SendMode Input ; Forces Send and SendRaw to use SendInput buffering for speed.
; SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
; SetWorkingDir, %A_ScriptDir%
; SplitPath, A_ScriptName, , , , thisscriptname
; #MaxThreadsPerHotkey, 1 ; no re-entrant hotkey handling
; ; DetectHiddenWindows, On
; ; SetWinDelay, -1 ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
; ; SetKeyDelay, -1, -1 ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
; ; SetMouseDelay, -1 ; Remove short delay done automatically after Click and MouseMove/Click/Drag


; ********************************
; Creates Graphic buttons based on images
; ********************************

;NOTE - To add more buttons 
;1)add button   --> addGraphicButton("button4", A_ScriptDir . "\button1_up.ico", "h30 w140 gbutton4", 30, 140)
;2)add function --> button4: 
;                   sleep,200 ; so that button can refesh states
;                   MsgBox, button4 :) 
;                   return 

;you will need to place images in the same folder as your script
;button1_up.ico
;button1_over.ico
;button1_down.ico
;
;button2_up.ico
;button2_over.ico
;button2_down.ico
;
;button3_up.ico
;button3_over.ico
;button3_down.ico


;EXAMPLE//////////////////////////////////////////////////////////////////////////////////////////
#singleInstance Force
clicked = 0 ; setting variable so that it knows mouse button isnt clicked
buttonsArray := Array() ; buttons get added to array as they are created

addGraphicButton("button1", A_ScriptDir . "\button1_up.ico", "h30 w140 gbutton1", 30, 140)
addGraphicButton("button2", A_ScriptDir . "\button2_up.ico", "h30 w140 gbutton2", 30, 140)
addGraphicButton("button3", A_ScriptDir . "\button3_up.ico", "h30 w140 gbutton3", 30, 140)
; Show the window 
Gui, Show,, Bitmap Buttons 

OnMessage(0x200, "mouseOver") ;WM_MOUSEFIRST     512
OnMessage(0x2A3, "mouseOver") ;WM_NCMOUSELEAVE   675
OnMessage(0x201, "mouseOver") ;WM_LBUTTONDOWN    513
OnMessage(0x202, "mouseOver") ;WM_LBUTTONUP      514
return


button1: 
sleep,200 ; so that button can refesh states
MsgBox, button1 :) 
return 

button2: 
sleep,200 ; so that button can refesh states
MsgBox, button2 :) 
return 

button3:
sleep,200 ; so that button can refesh states
MsgBox, button3 :) 
return 

^q::
GuiClose: 
ExitApp 
;/////////////////////////////////////////////////////////////////////////////////////////////


mouseOver(wParam, lParam, msg, hwnd)
{
Global

  For each, item in buttonsArray
  {
  buttonVariable = %item%
  button_hwnd := stringToVariable(buttonVariable)

  If (hwnd == button_hwnd)
  {
  button_over = %A_ScriptDir%\%buttonVariable%_over.ico
  button_up = %A_ScriptDir%\%buttonVariable%_up.ico
  button_down = %A_ScriptDir%\%buttonVariable%_down.ico
  options = h30 w140 g%buttonVariable%
  }

  ;WM_MOUSEFIRST/////////////////////////////////////////////////////////////////////////////////
  if(msg = 512)
    If (hwnd == button_hwnd)
    {
      if (clicked == 0)
      {
        addGraphicButton(buttonVariable, button_over, options, 30, 140) 
      }
    }
  ;WM_NCMOUSELEAVE///////////////////////////////////////////////////////////////////////////////
  if(msg = 675)
      If (hwnd == button_hwnd)
      {
      options = h30 w140 g%buttonVariable%
      addGraphicButton(buttonVariable, button_up, options, 30, 140) 
      }
  ;WM_LBUTTONDOWN////////////////////////////////////////////////////////////////////////////////
  if(msg = 513)
      If (hwnd == button_hwnd)
    {
      options = h30 w140 g%buttonVariable%
      addGraphicButton(buttonVariable, button_down, options, 30, 140) 
      clicked = 1
    }
  ;WM_LBUTTONUP///////////////////////////////////////////////////////////////////////////////////
  if(msg = 514)
      If (hwnd == button_hwnd)
    {
      options = h30 w140 g%buttonVariable%
      addGraphicButton(buttonVariable, button_up, options, 30, 140)
      clicked = 0
    }
  }
Return 
}

; ******************************************************************* 
; addGraphicButton.ahk 
; ******************************************************************* 
; Version: 2.2 Updated: May 20, 2007 
; by corrupt 
; UPDATED October29, 2015
; by blackshard
; ******************************************************************* 
; variableName = variable name for the button 
; ImgPath = Path to the image to be displayed 
; Options = AutoHotkey button options (g label, button size, etc...) 
; bHeight = Image height (default = 32) 
; bWidth = Image width (default = 32) 
; ******************************************************************* 
; note: 
; - calling the function again with the same variable name will 
; modify the image on the button 
; ******************************************************************* 
addGraphicButton(variableName, ImgPath, Options="", bHeight=32, bWidth=32) 
{ 
Global 
Local ImgType, ImgType1, ImgPath0, ImgPath1, ImgPath2, hwndmode 
; BS_BITMAP := 128, IMAGE_BITMAP := 0, BS_ICON := 64, IMAGE_ICON := 1 
Static LR_LOADFROMFILE := 16 
Static BM_SETIMAGE := 247 
Static NULL 
SplitPath, ImgPath,,, ImgType1 
If ImgPath is float 
{ 
  ImgType1 := (SubStr(ImgPath, 1, 1)  = "0") ? "bmp" : "ico" 
  StringSplit, ImgPath, ImgPath,`. 
  %variableName%_img := ImgPath2 
  hwndmode := true 
} 
ImgTYpe := (ImgType1 = "bmp") ? 128 : 64 
; if button doesnt exist add it to array
If (%variableName%_hwnd = "") 
  buttonsArray.insert(variableName)
; if button does exist delete it
If (%variableName%_img != "") AND !(hwndmode) 
  DllCall("DeleteObject", "UInt", %variableName%_img) 
; if button doesnt exist create it
If (%variableName%_hwnd = "") 
  Gui, Add, Button,  v%variableName% hwnd%variableName%_hwnd +%ImgTYpe% %Options% 
ImgType := (ImgType1 = "bmp") ? 0 : 1 
If !(hwndmode) 
  %variableName%_img := DllCall("LoadImage", "UInt", NULL, "Str", ImgPath, "UInt", ImgType, "Int", bWidth, "Int", bHeight, "UInt", LR_LOADFROMFILE, "UInt") 
DllCall("SendMessage", "UInt", %variableName%_hwnd, "UInt", BM_SETIMAGE, "UInt", ImgType,  "UInt", %variableName%_img) 
Return, %variableName% ; Return the handle to the image 
} 

stringToVariable(variableName)
{
 Return, %variableName%_hwnd ; Return the handle to the image 
}