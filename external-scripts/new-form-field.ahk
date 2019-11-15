; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; ; #Warn  ; Enable warnings to assist with detecting common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


WriteFormField(data) {

ClipSaved := data   ; Save the entire data.
	ReplacedStr := RegExReplace(data, "[\.,\?!""]")
	;MsgBox %ReplacedStr%
	NewStr := ;
	Loop, parse, data
	{
		curVar := A_LoopField
		
		
		if (A_Index = 1)
		{
			;MsgBox, 4, , Testing 123
			StringUpper, curVar, A_LoopField
		}
		else
		{
			if curVar is upper
			{
				NewStr .= A_Space
				;MsgBox, 4, , %EmptyStr%		
				;IfMsgBox, No, break
				
			}
		}
		
		NewStr .= curVar
		
	}


return "<mat-form-field>`n`t<mat-label>" NewStr "</mat-label>`n`t<input matInput`n`t`tformControlName=""" data """>`n`t<mat-error *ngIf=""form.get('" data "').invalid"">" NewStr " is required.</mat-error>`n</mat-form-field>`n`n"


;"<mat-form-field>`n`t<mat-label>%NewStr%</mat-label>`n`t<input matInput`n`t`tformControlName=`"%data%`">`n`t<mat-error *ngIf=`"form.get('%data%').invalid`">%NewStr% is required.</mat-error>`n</mat-form-field>`n`n"

}