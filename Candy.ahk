;~~~~~~~~~~~~~~~~~~~~万年书妖~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~带两位小数的版本为群内测试版~~~~~~~~~~~~~~~~~~~~

; /*
#MaxThreadsPerHotkey 3
#NoTrayIcon
#NoEnv
#SingleInstance Ignore
#WinActivateForce
Process Priority,,High
SetWorkingDir,%A_ScriptDir%
coordmode,Mouse,screen
SetTitleMatchMode,2
config_iniFile=ini\candycfg.ini

; */

^F9::
	candy_inipath=ini\candy1
	Candy_IniFile=%candy_inipath%\Candy1.ini
	Goto Label_Candy_Start
	Return

^F10::
	candy_inipath=ini\candy2
	Candy_IniFile=%candy_inipath%\Candy2.ini
	Goto Label_Candy_Start
	Return

^F11::
	candy_inipath=ini\candy3
	Candy_IniFile=%candy_inipath%\Candy3.ini
	Goto Label_Candy_Start
	Return
^F12::
	candy_inipath=ini\candy4
	Candy_IniFile=%candy_inipath%\Candy4.ini
	Goto Label_Candy_Start
	Return


;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 用拷贝的方法提取内容 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Candy_Start:
    IniRead,程序路径_默认文本编辑器, %config_iniFile%,Configuration,default_texteditor   ;文本编辑器
    IniRead ,candy_UserdBrowsers, %config_iniFile%,Configuration,used_browser            ;你用到的浏览器
    IniRead,candy_DefaultBrowser, %config_iniFile%,Configuration,Default_browser        ;你默认的浏览器，注意不同于系统默认

    CandySelected:=
    Candy_IniFile1:=
    Candy_IniFile2:=
    i=0
    MouseGetPos,    Candy_CurrWin_x,Candy_CurrWin_y,Candy_CurrWin_id,Candy_CurrWin_ClassNN,             ;当前鼠标下的窗口
    WinGet,         Candy_CurrWin_pid,PID,Ahk_ID %Candy_CurrWin_id%                                     ;当前窗口的PID
    WinGet,         Candy_CurrWin_Fullpath,ProcessPath,Ahk_ID %Candy_CurrWin_id%                        ;当前窗口的进程路径
    SplitPath,      Candy_CurrWin_Fullpath,,,,Candy_CurrWin_ProcName                                    ;当前窗口的进程名称，不带后缀
    WinGetClass,    Candy_CurrWin_class, Ahk_ID %Candy_CurrWin_id%                                      ;当前窗口的class
    WinGetTitle,    Candy_CurrWin_Title, Ahk_ID %Candy_CurrWin_id%                                      ;当前窗口的Title
    ControlGet,     Candy_CurrWin_hwnd,HWND,,,Ahk_ID %Candy_CurrWin_id%                                 ;当前窗口的Hwnd


;   flag_menuClipboard_disabled:=1                                                                      ;配合windy的粘贴板语句，独立的时候，该句删除
    Candy_Saved_ClipBoard := ClipboardAll
    Clipboard =
    Send, ^c
    ClipWait,1
    If ErrorLevel                              ;如果粘贴板里面没有内容，则有窗口定义
    {
        Clipboard := Candy_Saved_ClipBoard     ;若不想进行Windy，屏蔽掉即可
        Return
    }
    Candy_ClipBoard_Rich:=ClipboardAll
    CandySelected=%Clipboard%
    Clipboard := Candy_Saved_ClipBoard
    Candy_Saved_ClipBoard =
;   flag_menuClipboard_disabled:=0            ;配合windy的，独立的时候，该句删除

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 根据内容判断或者设定后缀 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    CandySelected_FileExtension=
    IniRead,Candy_ShortText_length,%Candy_IniFile%,Candy_Settings,ShortText_length,80          ;短文本的长度
    IfExist,%CandySelected%                                                                    ;如果是电脑里面存在的文件
    {
        Flag_isFile:=1
        FileGetAttrib, CandySelected_FileAttrib, %CandySelected%                               ;是文件的情况下，区分是否文件夹
        IfInString, CandySelected_FileAttrib, D                                                ;Attrib= D ,则是文件夹
        {
            If(RegExMatch(CandySelected,"^.:\\$"))
            {
                CandySelected_FileExtension:="Driver"            ;盘符
            }
            Else
            {
                CandySelected_FileExtension:="Folder"            ;文件夹
            }
            SplitPath,CandySelected,,CandySelected_FilePathOnly,,CandySelected_FileNamenoExt,CandySelected_FileDriver
            SplitPath,CandySelected_FilePathOnly,,,,CandySelected_FileFolderName_Uplevel,
        }
        Else        ;若不是文件夹的话，则只能是文件了
        {
            SplitPath,CandySelected,,CandySelected_FilePathOnly,CandySelected_FileExtension,CandySelected_FileNamenoExt,CandySelected_FileDriver
            SplitPath,CandySelected_FilePathOnly,,,,CandySelected_FileFolderName_Uplevel,
            IfEqual CandySelected_FileExtension,lnk
            {
                FileGetShortcut, %CandySelected%, Candy_linkTarget,
            }
            Else If !CandySelected_FileExtension                ;没有后缀的文件
            {
                CandySelected_FileExtension:="NoExt"
            }
        }
    }
    Else             ;如果不是文件，也不是文件夹，那么就是文本或者是“多个文件”
    {
        Flag_isFile:=0
        CandySelected:=RegExReplace(CandySelected,"^\s*|\s*$","")    ;去除前后的空格
        ;-----------特殊文字串辨析-------------------
        If(RegExMatch(CandySelected,"^(0x|#)?([a-fA-F0-9]){6}$"))
        {
            CandySelected_FileExtension:="ColorCode"   ;颜色的十六进制编码
        }
        Else If(RegExMatch(CandySelected,"^([a-zA-Z0-9]){20,50}$"))
        {
            CandySelected_FileExtension:="MagnetLink"   ;磁力链接
        }
        Else if(RegExMatch(CandySelected,"^(\(*\d+([.,]\d+)*\)*\s*(\+|-|/|\*)\s*)+\d+([.,]\d+)*\)*$"))
        {
            CandySelected_FileExtension:="Math"   ;数学表达式
        }
        Else if(RegExMatch(CandySelected,"i)^(HKCU|HKCR|HKCC|HKU|HKLM|Hkey_)"))
        {
            CandySelected_FileExtension:="RegPath"   ;注册表项
        }
        Else if(RegExMatch(CandySelected,"^\{[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}\}$"))
        {
            CandySelected_FileExtension:="CLSID"   ;Clsid
        }
        Else If(RegExMatch(CandySelected,"i)^(https://|http://)?([A-Za-z0-9]+(-[A-Za-z0-9]+)*\.)+[A-Za-z]{2,}?"))
        {
            CandySelected_FileExtension:="WebUrl"   ;网址
        }
        Else If(RegExMatch(CandySelected, "^[\w-_.]+@(?:\w+(?::\d+)?\.){1,3}(?:\w+\.?){1,2}$"))
        {
            CandySelected_FileExtension:="Email"    ;email地址
        }
        ;-----------长短文字串辨析-------------------
        If CandySelected_FileExtension!=
        {
            CandySelected_FileExtension_Regex=i)(^|\|)%CandySelected_FileExtension%($|\|)      ;正则
            CandySelected_FileExtension_Group:=SksSub_Ini_RegexFindKey(Candy_IniFile, "Texttype", CandySelected_FileExtension_Regex)
            IniRead,Candy_Value,%Candy_IniFile%,Texttype,%CandySelected_FileExtension_Group%,No_CandyValue_0
            IfNotEqual Candy_Value,No_CandyValue_0            ;如果有相应后缀组的定义
            {
                Goto Label_Candy_Find_Value
            }
        }
        If (StrLen(CandySelected)<Candy_ShortText_length)
        {
            CandySelected_FileExtension:="ShortText" ;短文本
        }
        Else
        {
            CandySelected_FileExtension:="LongText"  ;长文本
        }
        IfInString,CandySelected,`n
        {
            Candy_filelist:=
            Loop,Parse,CandySelected,`n,`r
            {
                IfNotExist,%A_LoopField%
                {
                    Goto Label_Candy_Find_Value
                    Break
                }
                Candy_filelist=%Candy_FileList%%A_Space%"%A_LoopField%"
            }
            CandySelected_FileExtension:="MultiFiles" ;是多文件
            Flag_isFile:=2
        }
    }


;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 查找后缀的定义 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Candy_Find_Value:
    If Flag_isFile>0   ;如果是文件类型
    {
        CandySelected_FileExtension_Regex=i)(^|\|)%CandySelected_FileExtension%($|\|)      ;正则成群组
        CandySelected_FileExtension_Group:=SksSub_Ini_RegexFindKey(Candy_IniFile, "filetype", CandySelected_FileExtension_Regex)
        IniRead,Candy_Value,%Candy_IniFile%,filetype,%CandySelected_FileExtension_Group%,No_CandyValue_1
        IfEqual Candy_Value,No_CandyValue_1            ;如果没有相应后缀组的定
        {
            IniRead,Candy_Value, %Candy_IniFile%,filetype,AnyFile,No_CandyValue_2
            IfEqual Candy_Value,No_CandyValue_2   ;没有定义的话，直接运行
            {
                Run,%CandySelected%, ,UseErrorLevel
                Return
            }
        }
    }
    Else ;如果是文本类型
    {
        CandySelected_FileExtension_Regex=i)(^|\|)%CandySelected_FileExtension%($|\|)      ;正则成群组
        CandySelected_FileExtension_Group:=SksSub_Ini_RegexFindKey(Candy_IniFile, "texttype", CandySelected_FileExtension_Regex)
        IniRead,Candy_Value,%Candy_IniFile%,texttype,%CandySelected_FileExtension_Group%,No_CandyValue_1
        IfEqual Candy_Value,No_CandyValue_1            ;如果没有相应后缀组的定
        {
            IniRead,Candy_Value, %Candy_IniFile%,texttype,AnyText,No_CandyValue_2
            IfEqual Candy_Value,No_CandyValue_2        ;没有定义的话，直接运行
            {
                Return
            }
        }
    }


;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 直接运行还是菜单 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    If(RegExMatch(Candy_Value,"i)^((file|Menu)\|)"))
        Goto Label_Candy_DrawMenu              ;如果是以Menu|或者file|开头,先去画菜单
    Else
        Goto Label_Candy_RunCommand            ;否则直接运行应用程序

Label_Candy_DrawMenu:
    Menu,CandyMenu,Add
    Menu,CandyMenu,Delete

    CandySelected_StrLen:=StrLen(CandySelected)
    IfGreater,CandySelected_StrLen,20         ;菜单第一行，限制字数在20个字
    {
        StringLeft,Candy_Menu_Title_left,CandySelected,5
        StringRight,Candy_Menu_Title_Right,CandySelected,10
        Menu CandyMenu,Add,%Candy_Menu_Title_left% ... %Candy_Menu_Title_Right%,Label_CopyFullpath     ;加第一行菜单，显示选中的内容，该菜单让你拷贝其内容
    }
    Else
    {
        Menu CandyMenu,Add,%CandySelected%,Label_CopyFullpath     ;加第一行菜单，显示选中的内容，该菜单让你直接打开配置文件
    }
    Menu,CandyMenu,Add

    Loop,parse,Candy_Value,+  ;Menu可能存在于两个ini(字段)中
    {
        Splitted_Candy_Value_File2:=
        Splitted_Candy_Value_File3:=
        i++
        If (i=3)
        {
            Break
        }
        If(RegExMatch(A_LoopField,"i)^(Menu\|)"))                              ;如果是menu|开头的话，则必定是在原ini文件里定义
        {
            StringReplace,CandyMenu_Ini_Sec_Name,A_LoopField,Menu|,             ;menu|字段名
            CandyMenu_Ini_Sec_Name%i%=%CandyMenu_Ini_Sec_Name%                  ;得到真正的Section的名称
            Candy_IniFile%i%=%Candy_IniFile%                                    ;用于下面的menu处理
        }
        Else If(RegExMatch(A_LoopField,"i)^(file\|)"))                          ;如果是file|开头，则必定是其他ini文件里面
        {
            StringSplit,Splitted_Candy_Value_File,A_LoopField,|                   ;file|文件名|字段名
            Candy_IniFile%i%=%Candy_inipath%\%Splitted_Candy_Value_File2%            ;用哪个文件？这样的写法，限定了ini必须在Candy_inipath文件夹里面
            If Splitted_Candy_Value_File3!=
            {
                CandyMenu_Ini_Sec_Name%i%:=Splitted_Candy_Value_File3                 ;如果定义了，则得到真正的Section的名称
            }
            Else
            {
                CandyMenu_Ini_Sec_Name%i%:="Configuration"                         ;这种写法是固定了段名
            }
        }
        Else  ;只支持menu file 混杂组合叠加，其它写法都是错误的，将被抛弃
        {
            Continue
        }
        ;================根据各类型画出菜单================================
        IniRead,CandyMenu_Ini_AllItem,% Candy_IniFile%i%,% CandyMenu_Ini_Sec_Name%i%,    ;读取全部字段的内容

        Loop, Parse, CandyMenu_Ini_AllItem,`n  ;首先做子菜单的清理
        {
            CandyMenu_Ini_ItemLeft:=trim(substr(A_LoopField,1,instr(A_LoopField,"=",1,1)-1))
            IfInString,CandyMenu_Ini_ItemLeft,`\
            {
                CandyMenu_Ini_ItemLeft_SubMenuName:=trim(substr(CandyMenu_Ini_ItemLeft,1,instr(CandyMenu_Ini_ItemLeft,"\",1,1)-1))
                Menu,%CandyMenu_Ini_ItemLeft_SubMenuName%,Add
                Menu,%CandyMenu_Ini_ItemLeft_SubMenuName%,Delete
            }
        }
        Loop, Parse, CandyMenu_Ini_AllItem,`n  ;再来刻画菜单
        {
            If(RegExMatch(A_LoopField,"^\s?-"))                                         ;如果第一个字符是 -
            {
                Menu,CandyMenu,Add
            }
            Else
            {
                CandyMenu_Ini_ItemLeft:=trim(substr(A_LoopField,1,instr(A_LoopField,"=",1,1)-1))
                IfInString,CandyMenu_Ini_ItemLeft,`\    ;包含\则是子菜单
                {
                    CandyMenu_Ini_ItemLeft_SubMenuName:=trim(substr(CandyMenu_Ini_ItemLeft,1,instr(CandyMenu_Ini_ItemLeft,"\",1,1)-1))
                    CandyMenu_Ini_ItemLeft_SubMenuItem:=trim(substr(CandyMenu_Ini_ItemLeft,instr(CandyMenu_Ini_ItemLeft,"\",1,1)+1))
                    If(RegExMatch(CandyMenu_Ini_ItemLeft_SubMenuItem,"^\s?-"))    ;如果子菜单第一个字符是 -
                    {
                        Menu,%CandyMenu_Ini_ItemLeft_SubMenuName%,Add
                    }
                    Else
                    {
                        Menu,%CandyMenu_Ini_ItemLeft_SubMenuName%,Add,%CandyMenu_Ini_ItemLeft_SubMenuItem%,Label_Candy_HandelMenu%i%
                        Menu,CandyMenu,Add,%CandyMenu_Ini_ItemLeft_SubMenuName%,:%CandyMenu_Ini_ItemLeft_SubMenuName%
                    }
                }
                Else   ;否则是根菜单
                {
                    Menu,CandyMenu,Add,%CandyMenu_Ini_ItemLeft%,Label_Candy_HandelMenu%i%
                }
            }
        }
    }
    Menu,CandyMenu,Show
    Return
;================菜单处理================================
    Label_Candy_HandelMenu1:
        If A_ThisMenu=CandyMenu    ;如果是根菜单
        {
            IniRead,Candy_Value,%Candy_IniFile1%,%CandyMenu_Ini_Sec_Name1%,%A_ThisMenuItem%
        }
        Else                        ;如果不是根菜单
        {
            IniRead,Candy_Value,%Candy_IniFile1%,%CandyMenu_Ini_Sec_Name1%,%A_ThisMenu%\%A_ThisMenuItem%
        }
        Goto Label_Candy_RunCommand
        Return
    Label_Candy_HandelMenu2:
        If A_ThisMenu=CandyMenu   ;如果是根菜单
        {
            IniRead,Candy_Value,%Candy_IniFile2%,%CandyMenu_Ini_Sec_Name2%,%A_ThisMenuItem%
        }
        Else                       ;如果不是根菜单
        {
            IniRead,Candy_Value,%Candy_IniFile2%,%CandyMenu_Ini_Sec_Name2%,%A_ThisMenu%\%A_ThisMenuItem%
        }
        Goto Label_Candy_RunCommand
        Return
    Label_CopyFullpath:
        Clipboard:=CandySelected
        Return


;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 终极运行 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Candy_RunCommand:
    Splitted_Candy_Value1:=
    Splitted_Candy_Value2:=
    Splitted_Candy_Value3:=
    Splitted_Candy_Value4:=

    ;置粘贴板开关,这是两个开关变量，所以先要剔除
    IfInString,Candy_Value,{setclipboard:pure}                           ;这个指令会预先修改系统粘贴板，而不会对命令行本身起作用
    {
        Clipboard:=CandySelected
        StringReplace,Candy_Value,Candy_Value,{setclipboard:pure},,All
    }
    IfInString,Candy_Value,{setclipboard:rich}                           ;同上
    {
        Clipboard:=Candy_ClipBoard_Rich
        StringReplace,Candy_Value,Candy_Value,{setclipboard:rich},,All
    }
    If Candy_Value=
        Return

    ;一些时间参数
    IfInString Candy_value,{date:    ;新的时间参数定义方法为:{date|yyyy_MM_dd} |后面的部分可以随意定义
    {
        candy_temp1:=RegExReplace(Candy_value,".*\{date\:(.*?)\}.*","$1")
        FormatTime,candy_temp2,%A_now%,%candy_temp1%
        StringReplace,Candy_value,Candy_value,{date:%candy_temp1%},%candy_temp2%
    }

    ;特别的参数Box
    IfInString,Candy_value,{box:input}
    {
        Gui +LastFound +OwnDialogs +AlwaysOnTop
        InputBox, f_input,Candy InputBox,`n`n     Please Input your parameter: ,, 285, 175,,,,,
        If ErrorLevel
            Return
        Else
            StringReplace,Candy_value,Candy_value,{box:input},%f_input%,All
    }
    IfInString,Candy_value,{box:password}
    {
        Gui +LastFound +OwnDialogs +AlwaysOnTop
        InputBox, f_password,Candy PasswordInputBox,`n`n     Please Input your Password: ,Hide, 285, 175,,,,,
        If ErrorLevel
            Return
        Else
            StringReplace,Candy_value,Candy_value,{box:password},%f_password%,All
    }
    IfInString,Candy_value,{box:filebrowser}
    {
        FileSelectFile, f_File ,  , , Select a File,
        If f_File <>
            StringReplace,Candy_value,Candy_value,{box:filebrowser},%f_File%,All
        Else
            Return
    }
    IfInString,Candy_value,{box:folderbrowser}
    {
        FileSelectFolder, f_Folder ,  , , Select a folder,
        If f_Folder <>
            StringReplace,Candy_value,Candy_value,{box:folderbrowser},%f_Folder%,All
        Else
            Return
    }

    If (CandySelected_FileExtension="MultiFiles")
    {
        Goto Label_Multifiles
        Return
    }
    If(RegExMatch(Candy_Value,"i)^(web\|)"))   ;web|p1|p2
    {
        StringSplit,Splitted_Candy_Value,Candy_Value,|
        CandySelected_FileExtension_Enc := SksSub_UrlEncode(CandySelected_FileExtension,Splitted_Candy_Value3)
        CandySelected_FileNamenoExt_Enc := SksSub_UrlEncode(CandySelected_FileNamenoExt,Splitted_Candy_Value3)
        CandySelected_Enc               := SksSub_UrlEncode(CandySelected,Splitted_Candy_Value3)
        StringReplace,Candy_Http,Splitted_Candy_Value2,{file:ext},%CandySelected_FileExtension_Enc%
        StringReplace,Candy_Http,Candy_Http,{file:namenoext},%CandySelected_FileNamenoExt_Enc%
        StringReplace,Candy_Http,Candy_Http,{text:selected},%CandySelected_Enc%  ;因为前面两个替换都是针对文件路径的，有了冒号的限制，不会产生二次替换
        Candy_Http="%Candy_Http%"
        SksSub_WebSearch(Candy_CurrWin_Fullpath,Candy_Http,candy_UserdBrowsers,candy_DefaultBrowser)
        Return
    }

    If Flag_isFile=1
    {
        StringReplace,Candy_value,Candy_value,{file:ext}              ,%CandySelected_FileExtension%,All                 ;后缀
        StringReplace,Candy_value,Candy_value,{file:pathonly}         ,%CandySelected_FilePathOnly%,All                  ;不带文件名的路径
        StringReplace,Candy_value,Candy_value,{file:namenoext}        ,%CandySelected_FileNamenoExt%,All                 ;纯粹的文件名，无后缀，无路径
        StringReplace,Candy_value,Candy_value,{file:foldername}       ,%CandySelected_FileFolderName_Uplevel%,All        ;上级文件夹名
        StringReplace,Candy_value,Candy_value,{file:linktarget}       ,%Candy_linkTarget%,All                            ;lnk的目标
        StringReplace,Candy_value,Candy_value,{file:pathfull}         ,%CandySelected%,All                               ;全部选中的
    }
    Else If Flag_isFile=0
    {
        StringReplace,Candy_value,Candy_value,{text:selected}         ,%CandySelected%,All                                ;全部选中的
    }


    ;----------------------------------------------------------------------------------------------------------
    ;以上替换工作结束，就是运行了
    ;----------------------------------------------------------------------------------------------------------
    StringSplit,Splitted_Candy_Value,Candy_Value,|    ;对指令进行|分割，分割出的第一个一般来说是指令，除非默认的run

    If(RegExMatch(Candy_Value,"i)^(config\|)"))       ;如果是以config|开头，则是编辑配置文件，直接运行结束
    {
        Goto Label_Candy_Editconfig
    }
    Else If (RegExMatch(Candy_Value,"i)^(Cando\|)")) ;如果是以Cando|开头，则是运行一些内部程序，方便与你的其它脚本进行挂接
    {
        Label_Cando=Cando_%Splitted_Candy_Value2%
        If IsLabel(Label_Cando)                       ;程序内置的别名
            Goto %Label_Cando%
        Else
            Goto Label_Candy_ErrorHandle
    }
    Else If (RegExMatch(Candy_Value,"i)^(Ahk\|)"))
    {
        IfExist,%Candy_action_p1%                    ;外部的ahk代码段，你的ahk一般而言可以带参数
            Run %程序路径_Autohotkey% %Splitted_Candy_Value2%
        Else
            Goto Label_Candy_ErrorHandle
    }
    Else If (RegExMatch(Candy_Value,"i)^(Keys\|)"))  ;如果是以keys|开头，则是发热键
    {
        SendInput {ctrl up}{shift up}{alt up}
        SendInput %Splitted_Candy_Value2%
    }
    Else If (RegExMatch(Candy_Value,"i)^(SetClipBoard\|)"))    ;纯粹的置粘贴板动作，这个与前面的{setclipboard:pure}{setclipboard:rich}不一样
    {
        Clipboard:=Splitted_Candy_Value2
    }
    Else If (RegExMatch(Candy_Value,"i)^(Run\|)"))   ;是运行
    {
        Run,%Splitted_Candy_Value2% ,%Splitted_Candy_Value3%,%Splitted_Candy_Value4% UseErrorLevel,Candy_PidA             ;1:程序  2:工作目录 3:状态
        If ErrorLevel = Error               ;如果运行出错的话
            Goto Label_Candy_ErrorHandle
    }
    Else                                    ;如果没有以上的指令，说明指令被省略，默认是运行
    {
        Run,%Splitted_Candy_Value1% ,%Splitted_Candy_Value2%,%Splitted_Candy_Value3% UseErrorLevel,Candy_PidA             ;1:程序  2:工作目录 3:状态
        If ErrorLevel = Error               ;如果运行出错的话
            Goto Label_Candy_ErrorHandle
    }
    Return


;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Candy_Editconfig:
	IfnotExist %程序路径_默认文本编辑器%
		程序路径_默认文本编辑器=
    If i=0
	{
		cmd=%程序路径_默认文本编辑器%%A_Space%%Candy_IniFile%
; 		MsgBox %cmd%
		Run,% trim(cmd),,useerrorlevel
	}
    Else Loop %i%
	{
		cmd:=程序路径_默认文本编辑器 A_Space Candy_IniFile%A_index%
		Run,% trim(cmd),,useerrorlevel
	}
	Return

Label_Candy_ErrorHandle:
	IniRead,Flag_ShowCandyError,%Candy_IniFile%,Candy_Settings,ShowError,0
	If Flag_ShowCandyError=1      ;看看出错提示开关打开了没有，打开了的话，就显示出错信息
	{
		MsgBox, 4116,, "Config Error,Check it now?"
		IfMsgBox Yes
			Goto Label_Candy_Editconfig
	}
	Return
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#Include Candy_include.ahk
#Include Candy_multifiles.ahk