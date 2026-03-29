class_name Transaction extends Resource

var id : int # Local id of trade offer for given merchant

@export var items_selling : Array[Item]
@export_range(0,99) var items_selling_amount : Array[int]

@export var items_buying : Array[Item]
@export_range(0,99) var items_buying_amount : Array[int]
