class_name ConductorParams

var tempo: int
var sec_ber_beat: float
var measures: int


func _init(_tempo: int, _sec_ber_beat: float = 0, _measures: int = 4) -> void:
	tempo = _tempo
	sec_ber_beat = _sec_ber_beat
	measures = _measures
