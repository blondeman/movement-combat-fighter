@tool
extends EditorScript

const ICONS_DIR := "res://icons"

func _run() -> void:
	var dir := DirAccess.open(ICONS_DIR)
	if not dir:
		push_error("SVGToWhite: Cannot open directory: " + ICONS_DIR)
		return

	var converted := 0
	var skipped := 0

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".svg"):
			var full_path := ICONS_DIR.path_join(file_name)
			if _process_svg(full_path):
				converted += 1
				print("Converting ", file_name)
			else:
				skipped += 1
		file_name = dir.get_next()

	dir.list_dir_end()
	print("\nConverted: %d | Skipped: %d" % [converted, skipped])


func _process_svg(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Cannot read: " + path)
		return false
	var content := file.get_as_text()
	file.close()

	var original := content

	var existing_fill := RegEx.new()
	existing_fill.compile(r'fill\s*=\s*"[^"]*"')
	content = existing_fill.sub(content, 'fill="#ffffff"', true)
	existing_fill.compile(r"fill\s*=\s*'[^']*'")
	content = existing_fill.sub(content, 'fill="#ffffff"', true)

	var style_fill := RegEx.new()
	style_fill.compile(r'fill\s*:\s*#?[a-zA-Z0-9]+')
	content = style_fill.sub(content, 'fill:#ffffff', true)

	var no_fill := RegEx.new()
	no_fill.compile(r'<(path|rect|circle|ellipse|polygon|polyline|line|text)(\s[^>]*?)?(\s*/?>)')
	var matches := no_fill.search_all(content)

	var i := matches.size() - 1
	while i >= 0:
		var m := matches[i]
		var full := m.get_string()
		if "fill" not in full:
			var close := m.get_string(3)
			var with_fill := full.left(full.length() - close.length()) + ' fill="#ffffff"' + close
			content = content.left(m.get_start()) + with_fill + content.substr(m.get_end())
		i -= 1

	if content == original:
		return false

	var out := FileAccess.open(path, FileAccess.WRITE)
	if not out:
		push_error("Cannot write: " + path)
		return false
	out.store_string(content)
	out.close()
	return true
