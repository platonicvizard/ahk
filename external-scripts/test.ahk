#SingleInstance, force

*^!v::	
MyVar := clipboard
;Sort, MyVar, u  ; Reverses the list so that it contains 4,3,2,1
;Sort, MyVar, F ReverseDirection u  ; Reverses the list so that it contains 4,3,2,1
;ReverseDirection(a1, a2, offset)
;{
;    return a1 - a2  ; Offset is positive if a2 came after a1 in the original list; negative otherwise.
;}
Array := [] 
Loop, parse, MyVar, `n, `r
{
isInArr := HasVal(Array, A_LoopField)
	Array.Push(A_LoopField)
	if(isInArr > 0) {
	Array.Pop()
	}
 ;Send  %A_Index% is %A_LoopField% %isInArr% `n
}
Loop % Array.Length()
{
	item = % Array[A_Index]
	Send %item% `n
}
;Send %MyVar%

HasVal(haystack, needle) {
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

;ExitApp