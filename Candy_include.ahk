SksSub_WebSearch(s_CurrWin_Fullpath,s_Http,s_UserdBrowsers,s_DefaultBrowser)
{
	If s_CurrWin_Fullpath Contains %s_UserdBrowsers%                     ;第①步，如果当前激活的窗口是浏览器，则就在本浏览器里面打开
	{
		Run,%s_CurrWin_Fullpath%%A_Space%%s_Http%
		Return
	}
	Else
	{
		Loop,Parse,s_UserdBrowsers,`,                       ;第②步，看进程里面有没有浏览器
		{
			If A_LoopField=
				Continue
			Process,exist,%A_LoopField%
			If ErrorLevel!=0
			{
				WinGet, Running_Browser_Fullpath,ProcessPath,Ahk_PID %ErrorLevel%
				If Running_Browser_Fullpath=
				{
					Run iexplore.exe %s_Http%
				}
				Else
				{
					Run, %Running_Browser_Fullpath%%A_Space%%s_Http%
					IfInString Running_Browser_Fullpath,firefox.exe
						WinActivate,Ahk_Class MozillaWindowClass
					Else
						WinActivate Ahk_PID %ErrorLevel%
				}
				Return
			}
		}
		s_DefaultBrowser_test:= RegExReplace(s_DefaultBrowser, "exe[^!]*[^>]*", "exe")    ;第③，都没有则启用默认浏览器了
		IfExist %s_DefaultBrowser_test%
		{

; 			MsgBox,%s_DefaultBrowser%%A_Space%%s_Http%
			Run,%s_DefaultBrowser%%A_Space%%s_Http%
			Return
		}
		Else                                      ;第④步，如果默认浏览器没有定义，则用系统的默认浏览器
		{
			Run,%s_Http%
			Return
		}
	}
}


;============================================================================================================
SksSub_UrlEncode(str, enc)
{
	If enc=
		Return %str%
	Else
	{
		hex := "00", func := "msvcrt\" . (A_IsUnicode ? "swprintf" : "sprintf")
		VarSetCapacity(buff, size:=StrPut(str, enc)), StrPut(str, &buff, enc)
		While (code := NumGet(buff, A_Index - 1, "UChar")) && DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", code, "Cdecl")
		encoded .= hex
		Return encoded
	}
}
;============================================================================================================


/* 正则方式在ini文件的某个字段内查找，某Sks_Key，如果找到，则返回这个字段
   找不到，则返回原值
*/
SksSub_Ini_RegexFindKey(Sks_IniFile,Sks_Section,Sks_Key)
{
	IniRead,Sks_All_keys,%Sks_IniFile%,%Sks_Section%,               ;提取[associations]段里面所有的群组
	Loop,Parse,Sks_All_keys,`n
	{
		StringSplit,line,A_LoopField,=
		If(RegExMatch(line1, Sks_Key))
		{
			Return,%line1%
			Break
		}
	}
	Return %Sks_Key%
	/*返回原值，纯粹是为了迎合Candy、Windy的需求
	*/
}


