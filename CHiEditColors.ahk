class CHiEditColors
{
	__New(hwnd)
	{
		this.Insert("_", { "colors" : CHiEditControl.CHiEditColors._default_colors.clone(), "update_ctrl" : true, "hwnd" : hwnd })
	}

	__Set(name, color)
	{
		if color is not Integer
		{
			color := CHiEditControl.CHiEditColors._colors[color]
		}

		this._.colors[name] := color
		if (this._.update_ctrl)
			this._update()
		return color
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

		VarSetCapacity(COLORS, CHiEditControl.CHiEditColors._color_properties.maxIndex() * 4, 0)
		for i, property in CHiEditControl.CHiEditColors._color_properties
		{
			NumPut(this[property], COLORS, (i - 1) * 4, "UInt")
		}

		SendMessage, HEM_SETCOLORS, &COLORS, true,,% "ahk_id " this._.hwnd
	}

	static _colors := { "black" : 0x000000, "silver" : 0xC0C0C0, "gray" : 0x808080, "white" : 0xFFFFFF
						, "maroon" : 0x000080, "red" : 0x0000FF, "purple" : 0x800080, "fuchsia" : 0xFF00FF
						, "green" : 0x008000, "lime" : 0x00FF00, "olive" : 0x008080, "yellow" : 0x00FFFF
						, "navy" : 0x800000, "blue" : 0xFF0000, "teal" : 0x808000, "aqua" : 0xFFFF00 }

	static _color_properties := ["Text", "Back", "SelText", "ActSelBack", "InSelBack", "LineNumber", "SelBarBack", "NonPrintableBack", "Number"]

	static _default_colors := { "Text" : 0x000000, "Back" : 0xFFFFFF, "SelText" : 0xFFFFFF
							, "ActSelBack" : 0x0000FF, "InSelBack" : 0xBBBBBB, "LineNumber" : 0x000000
							, "SelBarBack" : 0xFFFFFF, "NonPrintableBack" : 0xFFFFFF, "Number" : 0x000000 } ; TODO
}