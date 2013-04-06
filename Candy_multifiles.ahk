;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Multifiles:
	multifiles_list:=
	Array_Mulitfiles_Value1:=
	Array_Mulitfiles_Value2:=
	Array_Mulitfiles_Value3:=

	Loop,Parse,candyselected,`n,`r
	{
		IfInString, CandySelected_FileAttrib, D                            ;Attrib= D ,则是文件夹
		{
			SplitPath,A_loopfield,,multifiles_filepath,,multifiles_filename,
			SplitPath,multifiles_filepath,,,,multifiles_FileFolderName_Uplevel,
		}
		Else
		{
			SplitPath ,A_loopfield,,multifiles_filepath,multifiles_ext,multifiles_filename
			SplitPath,multifiles_filepath,,,,multifiles_FileFolderName_Uplevel,
		}
		Break  ;只取第一个文件(夹)，作为多文件的文件路径 multifiles_filepath，以及其所在的文件夹名称multifiles_FileFolderName_Uplevel
	}
	If(RegExMatch(Candy_Value,"i)^(run\|)"))  ;可以加run|前冠，也可以不加
	{
		StringReplace  ,Candy_Value,Candy_Value,run|,,
	}
	StringSplit,Array_Mulitfiles_Value,Candy_Value,|

	If(RegExMatch(Array_Mulitfiles_Value2,"i)^(ex:)"))
	{
		StringReplace ,Array_Mulitfiles_Value2,Array_Mulitfiles_Value2,ex:,,
		Loop,Parse,candyselected,`n,`r
		{
			SplitPath,A_loopfield,,,_ext
			If _ext In %Array_Mulitfiles_Value2%   ;如果在过滤列表里面，就pass掉
				Continue
			multifiles_list=%multifiles_list%%A_space%"%A_LoopField%"
		}
	}

	Else If(RegExMatch(Array_Mulitfiles_Value2,"i)^(in:)"))
	{
		StringReplace ,Array_Mulitfiles_Value2,Array_Mulitfiles_Value2,in:,,
		Loop,Parse,candyselected,`n,`r
		{
			SplitPath,A_loopfield,,,_ext
			If _ext Not In %Array_Mulitfiles_Value2%      ;如果不在包含列表里面，就pass
					Continue
			multifiles_list=%multifiles_list%%A_space%"%A_LoopField%"
		}
	}
	Else
	{
		Loop,Parse,candyselected,`n,`r
			multifiles_list=%multifiles_list%%A_space%"%A_LoopField%"
	}

; 	MsgBox %multifiles_list%
	StringReplace   multifiles_run_str ,Array_Mulitfiles_Value1,{mfile:list},%multifiles_list%
	StringReplace   multifiles_run_str ,multifiles_run_str,{mfile:pathonly},%multifiles_filepath%
	StringReplace   multifiles_run_str ,multifiles_run_str,{mfile:foldername},%multifiles_FileFolderName_Uplevel%
	Sleep 50
; 	MsgBox %multifiles_run_str%
	Run,%multifiles_run_str%
	Return
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━