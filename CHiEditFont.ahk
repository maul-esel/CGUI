class CHiEditFont
{
	__New(hwnd)
	{
		this.Insert("_", {})
		this._.hwnd := GUINum
	}

	__Set(Name, Value)
	{
		static WM_SETFONT := 0x30

		if (Name = "Options" || Name = "Font")
		{
			if (this._[Name] != Value)
				this._[Name] := Value
			else
				return
		}
		else
			return

		; code below only slightly modified from majkinetors's HE_SetFont() function
		; parse font options
		opt := this._.Options
		, italic	:= !!InStr(opt, "italic")
		, underline := !!InStr(opt, "underline")
		, strikeout	:= !!InStr(opt, "strikeout")
		, weight	:= InStr(opt, "bold") ? 700 : 400

		; height
		RegExMatch(opt, "(?<=[S|s])(\d{1,2})(?=([ ,]|$))", height)
		if (height = "")
			height := 10
		RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels
		height := -DllCall("MulDiv", "Int", height, "Int", LogPixels, "Int", 72, "Int")

		;create font
		hFont := DllCall("CreateFont", "Int", height, "Int", 0, "Int", 0, "Int", 0
										, "Int", weight,  "UInt", italic,   "UInt", underline
										, "UInt", strikeOut, "UInt", nCharSet, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "Str", this._.Font, "Ptr")
		SendMessage, WM_SETFONT, hFont, TRUE,, % "ahk_id " this._.hwnd
		return ErrorLevel
	}
}