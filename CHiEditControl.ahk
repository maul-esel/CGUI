/*
Class: CHiEditControl
An implementation of the HiEdit control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CHiEditControl extends CControl
{
	TextChanged := new EventHandler()

	static MODULEID := 0
	static DllPath := "C:\Dokumente und Einstellungen\___\Desktop\CGUI\HiEdit.dll"

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

		; ======= copied from CEditControl =======
		this._.Insert("ControlStyles", {Center : 0x1, LowerCase : 0x10, Number : 0x2000, Multi : 0x4, Password : 0x20, ReadOnly : 0x800, Right : 0x2, Uppercase : 0x8, WantReturn : 0x1000})
		this._.Insert("ControlMessageStyles", {ReadOnly: {Message: 0xCF, On: {W: 1}, Off: {W: 0}}})
		this._.Insert("Events", ["TextChanged"])
		this._.Insert("Messages", {0x200 : "KillFocus", 0x100 : "SetFocus" }) ;Used for automatically registering message callbacks
		; ========================================

		this.hwnd := hCtrl
		this.Text := Text
		return hCtrl
	}

	__Set(name, value)
	{
		static WM_SETTEXT := 0x000C

		if (name = "text")
		{
			SendMessage, WM_SETTEXT, 0, &value,, % "ahk_id " this.hwnd
		}
	}
}
/*
Group: About

- HiEdit control is copyright of Antonis Kyprianou (aka akyprian).  See http://www.winasm.net.
- Available for NON commercial purposes provided you have previous line in your about box.  You need author’s written permission to use HiEdit in commercial applications.
- AHK wrapper version 4.0.0.4-5 by majkinetor.
- Additonal functions and fixes by jballi.
- Implementation for CGUI by maul.esel
*/