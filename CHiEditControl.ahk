/*
Class: CHiEditControl
An implementation of the HiEdit control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CHiEditControl extends CControl
{
	TextChanged := new EventHandler()

	static MODULEID := 0
	static DllPath := "HiEdit.dll"

	__New(Name, Options, Text, GUINum)
	{
		static WS_CLIPCHILDREN := 0x2000000, WS_VISIBLE := 0x10000000, WS_CHILD := 0x40000000, WS_EX_CLIENTEDGE := 0x200
		static styles := { "HSCROLL" : 0x8, "VSCROLL" : 0x10, "TABBED" : 0x4, "HILIGHT" : 0x20, "TABBEDBTOP" : 0x1, "TABBEDHRZSB" : 0x2, "TABBEDBOTTOM" : 0x4, "SINGLELINE" : 0x40, "FILECHANGEALERT" : 0x80 }

		if (!CHiEditControl.MODULEID)
		{
			CHiEditControl.MODULEID := 230909, DllCall("LoadLibrary", "Str", CHiEditControl.DllPath, "Ptr")
		}

		Gui, %GUINum%: +HwndhParent

		RegExMatch(Options, "i)\bx(?P<x>[\d\.]+)\b", pos_)
		, RegExMatch(Options, "i)\by(?P<y>[\d\.]+)\b", pos_)
		, RegExMatch(Options, "i)\bw(?P<w>[\d\.]+)\b", pos_)
		, RegExMatch(Options, "i)\bh(?P<h>[\d\.]+)\b", pos_)

		Base.__New(Name, Options, Text, GUINum)
		, this.Type := "HiEdit"

		hStyle := 0
		loop, parse, Options, %A_Tab%%A_Space%
			if (styles.HasKey(A_LoopField))
				hStyle |= styles[A_LoopField]

		hCtrl := DllCall("CreateWindowEx"
						, "UInt",	WS_EX_CLIENTEDGE	; ExStyle
						, "Str",	"HiEdit"			; ClassName
						, "Str",	""					; WindowName
						, "UInt",	WS_CLIPCHILDREN | WS_CHILD | WS_VISIBLE | hStyle
						, "Int",	pos_x				; Left
						, "Int",	pos_y				; Top
						, "Int",	pos_w				; Width
						, "Int",	pos_h				; Height
						, "Ptr",	hParent				; hWndParent
						, "Ptr",	MODULEID			; hMenu
						, "Ptr",	0					; hInstance
						, "Ptr",	0, "Ptr")

		this._.Insert("ControlStyles", { "hilight" : 0x20, "hscroll" : 0x8, "vscroll" : 0x10, "tabbed" : 0x4, "tabbedtop" : 0x1, "tabbedhrzsb" : 0x2, "tabbedbottom" : 0x4, "singleline" : 0x40, "filechangealert" : 0x80 })
		this._.Insert("ControlMessageStyles", { "AutoIndent" : { "Message" : 2042, "On" : { "L" : true }, "Off" : { "L" : false }}})

		; ======= copied from CEditControl =======
		this._.Insert("Events", ["TextChanged"])
		this._.Insert("Messages", {0x200 : "KillFocus", 0x100 : "SetFocus" }) ;Used for automatically registering message callbacks
		; ========================================

		this.Insert("Colors", new CHiEditControl.CHiEditColors(hCtrl))

		this.hwnd := hCtrl
		, this.Text := Text
		return hCtrl
	}

	__Get(params*)
	{
		static WM_GETTEXT := 0x000D, HEM_GETCURRENTFILE := 2032, HEM_GETFILECOUNT := 2029, EM_GETTEXTRANGE := 1099, WM_GETTEXTLENGTH := 14

		name := params[1], param_count := params.maxIndex()
		if (param_count == 1)
		{
			if (name = "text")
			{
				VarSetCapacity(buffer, (char_count := 1024) * (A_IsUnicode ? 2 : 1), 0)
				SendMessage, WM_GETTEXT, char_count, &buffer,, % "ahk_id " this.hwnd
				VarSetCapacity(buffer, -1)
				return buffer
			}
			else if (name = "currentfile")
			{
				SendMessage, HEM_GETCURRENTFILE,,,, % "ahk_id " this.hwnd
				return Errorlevel
			}
			else if (name = "filecount")
			{
				SendMessage, HEM_GETFILECOUNT,,,, % "ahk_id " this.hwnd
				return Errorlevel
			}
			else if (name = "currentfilename")
			{
				return this.GetFileName()
			}
			else if (name = "textlength")
			{
				SendMessage, WM_GETTEXTLENGTH, 0, 0,, % "ahk_id " this.hwnd
				return ErrorLevel
			}
		}
		else if (param_count == 3)
		{
			if (name = "textrange")
			{
				lower := params[2], upper := params[3]
				, VarSetCapacity(buf, upper-lower+2)
				, VarSetCapacity(RNG, 12), NumPut(lower, RNG), NumPut(upper, RNG, 4), NumPut(&buf, RNG, 8)
				SendMessage, EM_GETTEXTRANGE, 0, &RNG,, % "ahk_id " this.hwnd
				VarSetCapacity(buf, -1)
				Return A_IsUnicode ? StrGet(&buf, "CP0") : buf
			}
		}
	}

	__Set(name, value)
	{
		static WM_SETTEXT := 0x000C, HEM_SETCURRENTFILE := 2033

		if (name = "text")
		{
			SendMessage, WM_SETTEXT, 0, &value,, % "ahk_id " this.hwnd
		}
		else if (name = "keywordfile")
		{
			DllCall("HiEdit\SetKeywordFile", "astr", value)
		}
		else if (name = "currentfile")
		{
			SendMessage, HEM_SETCURRENTFILE, 0, value,, % "ahk_id " this.hwnd
		}
		else if (name = "colors")
		{
			this.colors._.update_ctrl := false
			for clr_name, clr in value
				this.colors[clr_name] := clr
			this.colors._.update_ctrl := true
			, this.colors._update()
		}
	}

	NewFile()
	{
		static HEM_NEWFILE := 2024
		SendMessage, HEM_NEWFILE, 0, 0,, % "ahk_id " this.hwnd
	}

	OpenFile(path, create = false)
	{
		static HEM_OPENFILE := 2025
		return DllCall("SendMessage", "Ptr", this.hwnd, "UInt", HEM_OPENFILE, "Ptr", create, "AStr", path, "Ptr")
	}

	CloseFile(index = -1)
	{
		static HEM_CLOSEFILE := 2026
		SendMessage, HEM_CLOSEFILE, 0, index,, % "ahk_id " this.hwnd
		return errorlevel
	}

	ShowFileList(x = 0, y = 0)
	{
		static HEM_SHOWFILELIST := 2044
		SendMessage, HEM_SHOWFILELIST, x, y,, % "ahk_id " this.hwnd
	}

	ReloadFile(index = -1)
	{
		static HEM_RELOADFILE := 2027
		SendMessage, HEM_RELOADFILE, 0, index,, % "ahk_id " this.hwnd
		Return ErrorLevel
	}

	SaveFile(path, index = -1)
	{
		static HEM_SAVEFILE := 2028
		return DllCall("SendMessage", "Ptr", this.hwnd, "UInt", HEM_SAVEFILE, "AStr", path, "Ptr", index, "Ptr")
	}

	GetFileName(index = -1)
	{
		static HEM_GETFILENAME := 2030
		VarSetCapacity(fileName, 512)
		SendMessage, HEM_GETFILENAME, &fileName, index,, % "ahk_id " this.hwnd
		return A_IsUnicode ? StrGet(&fileName, "CP0") : fileName
	}


	#include CHiEditColors.ahk
}
/*
Group: About

- HiEdit control is copyright of Antonis Kyprianou (aka akyprian).  See http://www.winasm.net.
- Available for NON commercial purposes provided you have previous line in your about box.  You need author’s written permission to use HiEdit in commercial applications.
- AHK wrapper version 4.0.0.4-5 by majkinetor.
- Additonal functions and fixes by jballi.
- Implementation for CGUI by maul.esel
*/