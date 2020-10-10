local PLUGIN = PLUGIN

function PLUGIN:LoadFonts(font, genericFont)
surface.CreateFont("ix3D2DSmallFontStatic", {
		font = font,
		size = 24,
		extended = true,
		antialias = true,
		blurSize = 0.5,
		scanlines = 3,
		weight = 400
	})

	surface.CreateFont("ix3D2DSmallishFontStatic", {
		font = font,
		size = 32,
		extended = true,
		antialias = true,
		blurSize = 0.5,
		scanlines = 3,
		weight = 1000
	})

	surface.CreateFont("ix3D2DSmallerFontStatic", {
		font = font,
		size = 15,
		extended = true,
		antialias = true,
		blurSize = 0.5,
		scanlines = 3,
		weight = 400
	})
end