local cairo = { textcentre = {} }
function cairo.textcentre.full(cr, coord, text)
	local ext = cr:text_extents(text)
	cr:move_to(coord[1] - (ext.width/2 + ext.x_bearing), coord[2] - (ext.height/2 + ext.y_bearing))
	cr:show_text(text)
end
function cairo.textcentre.horizontal(cr, coord, text)
	local ext = cr:text_extents(text)
	cr:move_to(coord[1] - (ext.width/2 + ext.x_bearing), coord[2])
	cr:show_text(text)
end
function cairo.set_font(cr, font)
	cr:set_font_size(font.size)
	cr:select_font_face(font.font, font.slant, font.face)
end
return cairo
