class CHiEditSelection
{
	__New(hwnd)
	{
		this.Insert("_", { "hwnd" : hwnd })
	}

	__Get(name)
	{
		static EM_GETSELTEXT := 1086, EM_GETSEL := 176

		if (name = "text")
		{
			VarSetCapacity(buf, this.end - this.start + 2, 0)
			SendMessage, EM_GETSELTEXT, 0, &buf,, % "ahk_id " this._.hwnd
			VarSetCapacity(buf, -1)
			return StrGet(&buf, "CP0")
		}
		else if (name = "start" || name = "end")
		{
			DllCall("SendMessage", "Ptr", this._.hwnd, "UInt", EM_GETSEL, "Int*", start, "Int*", end, "Ptr")
			result := %name%
			return result
		}
	}

	__Set(name, value)
	{
		static EM_SETSEL := 0x0B1
		if (name = "start" || name = "end")
		{
			SendMessage, EM_SETSEL, name = "start" ? value : this.start, name = "end" ? value : this.end,, % "ahk_id " this._.hwnd
			return ErrorLevel ? value : ""
		}
	}

	Replace(text)
	{
		static EM_REPLACESEL := 194
		SendMessage, EM_REPLACESEL, 0, &text,, % "ahk_id " this._.hwnd
		Return ErrorLevel
	}
}