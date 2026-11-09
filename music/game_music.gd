extends AudioStreamPlayer


func _ready() -> void:
	var ogg_stream := stream as AudioStreamOggVorbis
	if ogg_stream != null:
		ogg_stream.loop = true
