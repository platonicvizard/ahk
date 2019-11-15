/**
	 *   OCR library by camerb
	 *   v0.93 - 2011-09-06
	 *
	 * This OCR lib provides an easy way to check a part of the screen for
	 * machine-readable text. You should note that OCR isn't a perfect technology,
	 * and will frequently make mistakes, but it can give you a general idea of
	 * what text is in a given area. For example, a common mistake that this OCR
	 * function makes is that it frequently interprets slashes, lowercase L,
	 * lowercase I, and the number 1 interchangably. Results can also vary
	 * greatly based upon where the outer bounds of the area to scan are placed.
	 *
	 * Future plans include a function that will check if a given string is
	 * displayed within the given coordinates on the screen.
	 *
	 * Home thread: http://www.autohotkey.com/forum/viewtopic.php?t=74227
	 * With inspiration from: http://www.autohotkey.com/forum/viewtopic.php?p=93526#93526
	*/


	#Include GDIp.ahk
	#Include CMDret.ahk


	; the options parameter is a string and can contain any combination of the following:
	;   debug - for use to show errors that GOCR spits out (not helpful for daily use)
	;   numeric (or numeral, or number) - the text being scanned should be limited to
	;            numbers only (no letters or special characters)
	GetOCR(topLeftX="", topLeftY="", widthToScan="", heightToScan="", options="")
	{
	   ;TODO validate to ensure that the coords are numbers

	   prevBatchLines := A_BatchLines
	   SetBatchlines, -1 ;cuts the average time down from 140ms to 115ms for small areas

	   ;process options from the options param, if they are there
	   if options
	   {
		  if InStr(options, "debug")
			 isDebugMode:=true
		  if InStr(options, "numeral")
			 isNumericMode:=true
		  if InStr(options, "numeric")
			 isNumericMode:=true
		  if InStr(options, "number")
			 isNumericMode:=true
	   }

	   if (heightToScan == "")
	   {
		  ;TODO throw error if not in the right coordmode
		  ;CoordMode, Mouse, Window
		  WinGetActiveStats, no, winWidth, winHeight, no, no
		  topLeftX := 0
		  topLeftY := 0
		  widthToScan  := winWidth
		  heightToScan := winHeight
	   }

	   fileNameDestJ = ResultImage.jpg
	   jpegQuality = 100

	   pToken:=Gdip_Startup()
	   pBitmap:=Gdip_BitmapFromScreen(topLeftX "|" topLeftY "|" widthToScan "|" heightToScan)
	   Gdip_SaveBitmapToFile(pBitmap, fileNameDestJ, 100)
	   Gdip_Shutdown(pToken)

	   ; Wait for jpg file to exist
	   while NOT FileExist(fileNameDestJ)
		  Sleep, 10

		  ;msgbox check
	   ;convert the jpg file to pnm
	   convertCmd=djpeg.exe -pnm -grayscale %fileNameDestJ% in.pnm
		
	   ;run the OCR
	   ;runCmd=gocr.exe -i in.pnm
	   if isNumericMode
		  additionalParams .= "-C 0-9 "
	   runCmd=gocr.exe %additionalParams% in.pnm

	   ;run both commands using my mixed cmdret hack
	   CmdRet(convertCmd)
	   
	   while NOT FileExist("in.pnm")
		  Sleep, 10
		  
	   result := CmdRet(runCmd)
	  

	   ;suppress warnings from GOCR (we don't care, give us nothing)
	   if InStr(result, "NOT NORMAL")
		  gocrError:=true
	   if InStr(result, "strong rotation angle detected")
		  gocrError:=true
	   if InStr(result, "# no boxes found - stopped") ;multiple warnings show up with this in the string
		  gocrError:=true

	   if gocrError
	   {
		  if NOT isDebugMode
			 result=
			
	   }

	   ; Cleanup
	   
	
	   FileDelete, in.pnm
	   while FileExist("in.pnm")
		  Sleep, 10
	   FileDelete, %fileNameDestJ%	
	   while FileExist(fileNameDestJ)
		  Sleep, 10
		SetBatchlines, %prevBatchLines%

	   return result
	}

	;RunWaitEx(CMD, CMDdir, CMDin, ByRef CMDout, ByRef CMDerr)
	;{
	   ;VarSetCapacity(CMDOut, 100000)
	   ;VarSetCapacity(CMDerr, 100000)
	   ;RetVal := DllCall("cmdret.dll\RunWEx", "AStr", CMD, "AStr", CMDdir, "AStr", CMDin, "AStr", CMDout, "AStr", CMDerr)
	   ;Return, %RetVal%
	;}

	;GhettoCmdRet_RunReturn(command)
	;{
	   ;file := "joe.txt"
	   ;command .= " > " . file
	   ;Run %comspec% /c "%command%"
	   ;FileRead, returned, %file%
	   ;return returned
	;}

	CMDret(CMD)
	{
	   if RegExMatch(A_AHKversion, "^\Q1.0\E")
	   {
		  StrOut:=CMDret_RunReturn(cmd)
	   }
	   else
	   {
		  VarSetCapacity(StrOut, 20000)
		  RetVal := DllCall("cmdret.dll\RunReturn", "astr", CMD, "ptr", &StrOut)
		  strget:="strget"
		  StrOut:=%StrGet%(&StrOut, 20000, CP0)
	   }
	   Return, %StrOut%
	}