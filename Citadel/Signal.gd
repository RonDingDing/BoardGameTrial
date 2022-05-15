extends Node

#warning-ignore:unused_signal
signal sgin_start_game(all_player_length)
#warning-ignore:unused_signal
signal sgin_draw_card(player_num, card_name, from_pos, face_is_up)
#warning-ignore:unused_signal
signal sgin_player_obj_draw_card(player_obj, card_info, from_pos, face_is_up)
#warning-ignore:unused_signal
signal sgin_player_obj_built_card(player_obj, card_info, from_pos)
#warning-ignore:unused_signal
#signal sgout_player_draw(card_info, from_pos)
#warning-ignore:unused_signal
signal player_info(data)
#warning-ignore:unused_signal
signal sgin_player_draw_ready(card)
#warning-ignore:unused_signal
signal sgin_player_draw_not_ready(card)
#warning-ignore:unused_signal
signal sgin_opponent_draw_ready(card)
#warning-ignore:unused_signal
signal sgin_opponent_draw_not_ready(card)
#warning-ignore:unused_signal
signal sgout_enlarge_enable
#warning-ignore:unused_signal
#signal sgout_enlarge_disable
#warning-ignore:unused_signal
signal sgin_card_focused(card_name)
signal sgin_card_unfocused
#warning-ignore:unused_signal
signal sgin_card_dealt
#warning-ignore:unused_signal
signal sgin_gold(player_num, from_pos)
#warning-ignore:unused_signal
signal sgin_draw_gold(player, from_pos)
#warning-ignore:unused_signal
#signal sgout_player_obj_gold(from_pos)
#warning-ignore:unused_signal
signal sgin_opponent_gold_ready
#warning-ignore:unused_signal
signal sgin_player_gold_ready
#warning-ignore:unused_signal
signal sgin_ready_game
#warning-ignore:unused_signal
signal hand_over(player_name)
#warning-ignore:unused_signal
signal uncover
#warning-ignore:unused_signal
signal sgin_char_focused(char_name)
signal sgin_char_unfocused
#warning-ignore:unused_signal
signal sgin_char_selected(char_num)
#warning-ignore:unused_signal
signal sgin_set_reminder(text)
#warning-ignore:unused_signal
signal sgin_move_char_to_discarded(char_info)
#warning-ignore:unused_signal
signal sgin_move_char_to_hidden(char_info)
#warning-ignore:unused_signal
signal sgin_move_char_to_selected(char_info)
#warning-ignore:unused_signal
signal sgin_discarded_once_finished(char_name)
#warning-ignore:unused_signal
signal sgin_discarded_all_finished
#warning-ignore:unused_signal
signal sgin_hidden_once_finished(char_name)
#warning-ignore:unused_signal
signal sgin_hidden_all_finished
#warning-ignore:unused_signal
signal sgin_character_selection
#warning-ignore:unused_signal
signal sgin_selected_char_once_finished(char_name)
#warning-ignore:unused_signal
signal sgin_selected_char_all_finished
#warning-ignore:unused_signal
signal sgin_char_ready(chara)
#warning-ignore:unused_signal
signal sgin_char_not_ready(chara)
#warning-ignore:unused_signal
signal phase(phase_string)
#warning-ignore:unused_signal
signal sgin_play
#warning-ignore:unused_signal
signal sgin_resource_need(what)
#warning-ignore:unused_signal
signal sgin_char_entered
#warning-ignore:unused_signal
signal sgin_end_turn

#warning-ignore:unused_signal
signal sgin_card_selected(card_name, from_pos)

# #warning-ignore:unused_signal
# signal sgin_selected_card_once_finished(card_name)
# #warning-ignore:unused_signal
# signal sgin_selected_card_all_finished

func on_sgin_draw_gold(player_obj: Node, from_pos: Vector2) -> void:
	player_obj.on_sgout_player_obj_gold(from_pos)


func on_sgin_player_obj_draw_card(
	player_obj: Node, card_info: Dictionary, from_pos: Vector2, face_is_up: bool
) -> void:
	player_obj.on_sgout_player_draw(card_info, from_pos, face_is_up)


func on_sgin_char_not_ready(chara: Node) -> void:
	chara.set_enlargeable(false)


func on_sgin_char_ready(chara: Node) -> void:
	chara.set_enlargeable(true)


func on_sgin_player_draw_ready(card: Node) -> void:
	pass
	# card.set_enlargeable(true)


func on_sgin_player_draw_not_ready(card: Node) -> void:
	card.set_mode(card.Mode.STATIC)
