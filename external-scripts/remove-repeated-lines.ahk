; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; ; #Warn  ; Enable warnings to assist with detecting common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


RemoveRepeatedLines(data) 
{

	Array := [] 
	Loop, parse, data, `n, `r
	{
		isInArr := HasVal(Array, A_LoopField)
		Array.Push(A_LoopField)
		if(isInArr > 0)
		{
			Array.Pop()
		}
	}

	return Join(Array, "`n")
}

Join(Array, Sep)
{
	for k, v in Array
		out .= Sep . v
	return SubStr(Out, 1+StrLen(Sep))
}

HasVal(haystack, needle) 
{
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	
	StringReplace , needle, needle, %A_Space%,,All
	
	for index, value in haystack
	{
		StringReplace , value, value, %A_Space%,,All
		
		if (value = needle)
			return index
	}
	return 0
}