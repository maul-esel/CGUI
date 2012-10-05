class CHiEditColors
{
	__New(hwnd)
	{
		this.Insert("_", { "pending" : {}, "hwnd" : hwnd })
	}

	__Set(params*)
	{
		static _colors := { "black" : 0x000000, "silver" : 0xC0C0C0, "gray" : 0x808080, "white" : 0xFFFFFF
						, "maroon" : 0x000080, "red" : 0x0000FF, "purple" : 0x800080, "fuchsia" : 0xFF00FF
						, "green" : 0x008000, "lime" : 0x00FF00, "olive" : 0x008080, "yellow" : 0x00FFFF
						, "navy" : 0x800000, "blue" : 0xFF0000, "teal" : 0x808000, "aqua" : 0xFFFF00 }

		names := params, colors := names.Remove()
		if (!IsObject(colors))
			colors:= [colors]

		for i, name in names
		{
			color := colors[i]
			if color is not Integer
				color := _colors[color]
			this._.pending[name] := color
		}

		this._update()
		return params.MaxIndex() == 2 ? color : colors
	}

	__Get(params*)
	{
		static HEM_GETCOLORS := 2038

		VarSetCapacity(COLORS, 48, 0)
		if (params[1] != "_")
		{
			VarSetCapacity(COLORS, CHiEditControl.CHiEditColors._color_properties.maxIndex() * 4, 0)
			SendMessage, HEM_GETCOLORS, 0, &COLORS,, % "ahk_id " this._.hwnd
			if (ErrorLevel = "FAIL")
				return ""

			fmt := A_FormatInteger
			SetFormat, integer, hex

			param_count := (p := params.maxIndex()) ? p : 0
			, name := params[1] ; for param_count = 1
			, result := {}

			for i, property in CHiEditControl.CHiEditColors._color_properties
			{
				if (param_count == 0)
					result[property] := NumGet(COLORS, (i - 1) * 4, "UInt")
				else if (param_count == 1)
				{
					if (property = name)
					{
						result := NumGet(COLORS, (i - 1) * 4, "UInt")
						break
					}
				}
			}

			SetFormat,  integer, %fmt%
			return result
		}
	}

	_update()
	{
		static HEM_SETCOLORS := 2037

		current_colors := this[]
		, VarSetCapacity(COLORS, CHiEditControl.CHiEditColors._color_properties.maxIndex() * 4, 0)

		for i, property in CHiEditControl.CHiEditColors._color_properties
		{
			if (this._.pending.HasKey(property))
				NumPut(this._.pending[property], COLORS, (i - 1) * 4, "UInt"), this._.pending.Remove(property)
			else
				NumPut(current_colors[property], COLORS, (i - 1) * 4, "UInt")
		}

		SendMessage, HEM_SETCOLORS, &COLORS, true,,% "ahk_id " this._.hwnd
	}

	static _color_properties := ["Text", "Back", "SelText", "ActSelBack", "InSelBack", "LineNumber", "SelBarBack", "NonPrintableBack", "Number"]
}