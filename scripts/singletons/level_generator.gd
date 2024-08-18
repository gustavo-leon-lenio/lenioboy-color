class_name LevelGenerator extends Node

enum PoolType { NONE, FLAG, NORMAL, BIRD, GOODIE }

@onready var final_beat: int = 173
@onready var total_beats: int = 177
@onready var initial_beat: int = 11


static func select_note_positions(max_notes: int) -> Array:
    var positions := []
    while positions.size() < max_notes:
        var pos := randi() % 4
        if not positions.has(pos):
            positions.append(pos)
    return positions


static func generate_measure(
    previous_last_note: int, max_notes: int = 1, enemy_types: int = 2, measure_length: int = 4
) -> Array:
    var measure := []
    for _i in range(measure_length):
        measure.append(0)
    var note_positions := select_note_positions(max_notes)

    for pos: int in note_positions:
        if pos == 0 and previous_last_note:
            continue
        measure[pos] = randi() % enemy_types + 2  # just birds and normals

    return measure


# gdlint: disable=max-line-length
static func generate_rhythm(
    max_notes: int = 1,
    enemy_types: int = 2,
    n_notes: int = 177,
    start_note: int = 11,
    final_note: int = 173
) -> Array:
    var rhythm := []
    var last_note := 0

    var n_measures := calculate_number_of_measures(n_notes)

    for m_index in range(n_measures):
        var measure := generate_measure(last_note, max_notes, enemy_types)
        if m_index < n_measures and m_index >= final_note:
            rhythm += [0, 0, 0, 0]
        else:
            rhythm += (measure)
        last_note = measure[3]

    for i in range(start_note + 1):
        rhythm[i] = 0

    for i in range(rhythm.size() - 1, final_note - 3, -1):
        rhythm[i] = 0

    rhythm[final_note - 1] = PoolType.FLAG
    rhythm[start_note - 1] = PoolType.NORMAL

    if Global.player_health < Global.MAX_HEALTH:
        rhythm[0] = PoolType.GOODIE

    return rhythm


static func calculate_number_of_measures(num_black_notes: int) -> int:
    # Calculate the number of measures by dividing the total number of notes by 4
    # and rounding up
    return int(ceil(num_black_notes / 4.0))
