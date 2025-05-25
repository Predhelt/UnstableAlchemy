extends HBoxContainer

var item_icon : Texture2D:
	set(icon):
		$ItemIcon.texture = icon

var item_count : int:
	set(count):
		$ItemCount.text = "+" + str(count)
