extends Node2D
onready var Data = get_node("/root/Main/Data")

#warning-ignore:unused_signal
signal sgin_gold_move(from_pnum, to_pnum, price, done_signal)
#warning-ignore:unused_signal
signal sgin_add_point(point)
#warning-ignore:unused_signal
signal sgin_draw_card(pnum, face_is_up, from_pos)
#warning-ignore:unused_signal
signal sgin_player_obj_built_card(player_obj, card_name, from_pos)
#warning-ignore:unused_signal
#warning-ignore:unused_signal
signal player_info(data)
#warning-ignore:unused_signal
#signal sgin_player_draw_ready(card)
#warning-ignore:unused_signal
#signal sgin_player_draw_not_ready(card)
#warning-ignore:unused_signal
signal sgin_player_built_not_ready(card)
#warning-ignore:unused_signal
signal sgin_player_built_ready(card)
#warning-ignore:unused_signal
signal sgin_opponent_draw_ready(card)
#warning-ignore:unused_signal
signal sgin_opponent_draw_not_ready(card)
#warning-ignore:unused_signal
signal sgout_enlarge_enable
#warning-ignore:unused_signal
signal sgin_card_focused(card_name)
#warning-ignore:unused_signal
signal sgin_card_unfocused
#warning-ignore:unused_signal
signal sgin_card_dealt
#warning-ignore:unused_signal
signal sgin_opponent_gold_ready
#warning-ignore:unused_signal
signal sgin_player_gold_ready
#warning-ignore:unused_signal
signal sgin_player_pay_ready
#warning-ignore:unused_signal
signal sgin_ready_game
#warning-ignore:unused_signal
signal hand_over(player_name)
#warning-ignore:unused_signal
signal uncover
#warning-ignore:unused_signal
signal sgin_char_focused(char_name)
#warning-ignore:unused_signal
signal sgin_char_unfocused
#warning-ignore:unused_signal
signal sgin_char_selected(char_num)
#warning-ignore:unused_signal
signal sgin_set_reminder(text)
#warning-ignore:unused_signal

#warning-ignore:unused_signal
signal sgin_discarded_once_finished(char_num, char_name)
#warning-ignore:unused_signal
signal sgin_discarded_all_finished
#warning-ignore:unused_signal
signal sgin_hidden_once_finished(char_num, char_name)
#warning-ignore:unused_signal
signal sgin_hidden_all_finished
#warning-ignore:unused_signal
signal sgin_character_selection
#warning-ignore:unused_signal
signal sgin_selected_char_once_finished(char_num, char_name)
#warning-ignore:unused_signal
signal sgin_selected_char_all_finished
#warning-ignore:unused_signal
signal sgin_char_ready(chara)
#warning-ignore:unused_signal
signal sgin_char_not_ready(chara)
#warning-ignore:unused_signal
signal phase(phase_string)
#warning-ignore:unused_signal
signal sgin_start_turn
#warning-ignore:unused_signal
signal sgin_resource_need(what)
#warning-ignore:unused_signal
signal sgin_resource_end
#warning-ignore:unused_signal
signal sgin_char_entered
#warning-ignore:unused_signal
signal sgin_end_turn
#warning-ignore:unused_signal
signal sgin_card_selected(card_name, from_pos)
#warning-ignore:unused_signal
signal sgin_card_played(card_name, from_pos)
#warning-ignore:unused_signal
signal sgin_card_played_finished(card_name)
#warning-ignore:unused_signal
signal sgin_one_round_finished

##warning-ignore:unused_signal
#signal sgin_assassin_wait
#warning-ignore:unused_signal
signal sgin_assassin_once_finished(char_num, char_name)
#warning-ignore:unused_signal
signal sgin_assassin_all_finished

#warning-ignore:unused_signal
#signal sgin_thief_wait
#warning-ignore:unused_signal
signal sgin_thief_once_finished(char_num, char_name)
#warning-ignore:unused_signal
signal sgin_thief_all_finished
#warning-ignore:unused_signal
#signal sgin_thief_stolen
#warning-ignore:unused_signal
#signal sgin_thief_done

#warning-ignore:unused_signal
#signal sgin_magician_wait
#warning-ignore:unused_signal
signal sgin_magician_switch(switch)
#warning-ignore:unused_signal
signal sgin_magician_opponent_selected(player_num)
#warning-ignore:unused_signal
#signal sgin_king_move_crown(player_num)
#warning-ignore:unused_signal
#signal sgin_4_done

#warning-ignore:unused_signal
#signal sgin_ask_built_num(color)
#warning-ignore:unused_signal
#signal sgin_ans_built_num(color, num)

#warning-ignore:unused_signal
#signal sgin_merchant_wait
#warning-ignore:unused_signal
signal sgin_merchant_gold(mode)

#warning-ignore:unused_signal
signal sgin_show_built(player_num)
#warning-ignore:unused_signal
signal sgin_hide_built

#warning-ignore:unused_signal
signal sgin_warlord_choice(mode)

#warning-ignore:unused_signal
signal sgin_warlord_opponent_selected(player_num, player_employee, opponent_name, built)

#warning-ignore:unused_signal
signal sgin_card_warlord_selected(card_name, global_position)

#warning-ignore:unused_signal
signal sgin_skill(skill_name)

#warning-ignore:unused_signal
signal sgin_cancel_skill(components, activate_key, activate_mode, phase)
#warning-ignore:unused_signal
signal sgin_reveal_done
#warning-ignore:unused_signal
signal sgin_check_skill_end_turn_done
#warning-ignore:unused_signal
signal sgin_card_clickable_clicked(card_name, global_position)
#warning-ignore:unused_signal
signal sgin_armory_opponent_selected(player_num, employee, username, built)
#warning-ignore:unused_signal
signal sgin_card_armory_selected(card_name, global_position)
#warning-ignore:unused_signal
signal sgin_card_laboratory_selected(card_name, global_position)
#warning-ignore:unused_signal
signal sgin_card_necropolis_selected(card_name, global_position)
#warning-ignore:unused_signal
signal sgin_disable_player_play
#warning-ignore:unused_signal
signal sgin_card_move_done
#warning-ignore:unused_signal
signal sgin_haunted_quarter_color_selected(color)
#warning-ignore:unused_signal
signal sgin_framework_choice(yes_no)
#warning-ignore:unused_signal
signal sgin_necropolis_choice(yes_no)
#warning-ignore:unused_signal
signal sgin_thieves_den_choice(card_names, cancel)
#warning-ignore:unused_signal
signal sgin_framework_reaction_completed(price)
#warning-ignore:unused_signal
signal sgin_necropolis_reaction_completed(price)
#warning-ignore:unused_signal
signal sgin_all_play_reaction_completed(price)
#warning-ignore:unused_signal
signal sgin_school_of_magic_reaction_completed(gained)
#warning-ignore:unused_signal
signal sgin_all_resource_skill_reaction_completed(gained)
#warning-ignore:unused_signal
signal sgin_school_of_magic_color_selected(color)
#warning-ignore:unused_signal
signal sgin_card_thieves_den_selected(card_name, global_pos)
#warning-ignore:unused_signal
signal sgin_thieves_den_reaction_completed(hand_remove_num)
#warning-ignore:unused_signal
signal sgin_theater_choice(yes_no)
#warning-ignore:unused_signal
signal sgin_theater_opponent_selected(player_num)
#warning-ignore:unused_signal
signal sgin_theater_reaction_completed
#warning-ignore:unused_signal
signal sgin_all_selection_skill_reaction_completed
#warning-ignore:unused_signal
signal sgin_card_museum_selected(card_name, global_position)
#warning-ignore:unused_signal
signal all_ani_completed




func on_sgin_char_not_ready(chara: Node) -> void:
	chara.set_char_mode(Data.CharMode.STATIC)


func on_sgin_char_ready(chara: Node) -> void:
	chara.set_char_mode(Data.CharMode.ENLARGE)


func on_sgin_player_draw_ready(_card: Node) -> void:
	pass
	# card.set_enlargeable(true)


func on_sgin_player_draw_not_ready(card: Node) -> void:
	card.set_card_mode(Data.CardMode.STATIC)




