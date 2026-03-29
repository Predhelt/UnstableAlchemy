extends HBoxContainer

var icon : Texture2D:
	set(i):
		$ItemIcon.texture = i

var count : int:
	set(c):
		$ItemCount.text = "+" + str(c)
