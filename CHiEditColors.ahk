class CHiEditColors
{
	__New(hwnd)
	{
		this.Insert("_", { "colors" : CHiEditControl.CHiEditColors._default_colors.clone(), "update_ctrl" : true, "hwnd" : hwnd })
	}

	__Set(name, color)
	{
		SetFormat, Integer, Hex
		if color is not Integer
		{
			color := CHiEditControl.CHiEditColors._colors[color]
		}

		this._.colors[name] := color
		if (this._.update_ctrl)
			this._update()
	}

	__Get(name)
	{
		if (name != "_")
		{
			return this._.colors[name]
		}
	}

	_update()
	{
		static HEM_SETCOLORS := 2037

		VarSetCapacity(COLORS, 36, 0)
		, NumPut(this["Text"],				COLORS, 00)	;NormalTextColor
		, NumPut(this["Back"],				COLORS, 04) ;EditorBkColor
		, NumPut(this["SelText"],			COLORS, 08) ;SelectionForeColor
		, NumPut(this["ActSelBack"],		COLORS, 12)	;ActiveSelectionBkColor
		, NumPut(this["InSelBack"],			COLORS, 16)	;InactiveSelectionBkColor
		, NumPut(this["LineNumber"],		COLORS, 20)	;LineNumberColor
		, NumPut(this["SelBarBack"],		COLORS, 24)	;SelBarBkColor
		, NumPut(this["NonPrintableBack"],	COLORS, 28)	;NonPrintableBackColor
		, NumPut(this["Number"],			COLORS, 32)	;NumberColor

		SendMessage, HEM_SETCOLORS, &COLORS, true,,% "ahk_id " this._.hwnd
	}

	static _colors := { "black" : 0x000000, "silver" : 0xC0C0C0, "gray" : 0x808080, "white" : 0xFFFFFF
						, "maroon" : 0x000080, "red" : 0x0000FF, "purple" : 0x800080, "fuchsia" : 0xFF00FF
						, "green" : 0x008000, "lime" : 0x00FF00, "olive" : 0x008080, "yellow" : 0x00FFFF
						, "navy" : 0x800000, "blue" : 0xFF0000, "teal" : 0x808000, "aqua" : 0xFFFF00 }

	static _default_colors := { "Text" : 0x000000, "Back" : 0xFFFFFF, "SelText" : 0xFFFFFF
							, "ActSelBack" : 0x0000FF, "InSelBack" : 0xBBBBBB, "LineNumber" : 0x000000
							, "SelBarBack" : 0xFFFFFF, "NonPrintableBack" : 0xFFFFFF, "Number" : 0x000000 } ; TODO
}