extends Node

## Data : {"player_num": 1, "username": "username", "money": 0, "charater": "unknown", "hand": ["<建筑名>"), "built": ["<建筑名>")}

# BuildingData:  {"<建筑名>" : {"name": "<建筑名>"， "star": 0, "kind": "blue", "description"： "<特殊效果描述>", special_effect": <带int的signal>}}

const up_offset = {
	"en":
	{
		"Quarry": -20,
		"Library": 15,
		"Keep": -25,
		"Ivory Tower": 31,
		"Observatory": 15,
		"Factory": -17,
		"Smithy": -15,
		"Laboratory": -20,
		"Basilica": 35,
		"Wishing Well": 33,
		"Statue": -15,
		"Imperial Treasury": 3,
		"Great Wall": 17,
		"Gold Mine": 15,
		"Poor House": 3,
		"Haunted Quarter": 16,
		"Framework": 33,
		"Necropolis": 33,
		"Monument": 75,
		"Secret Vault": 55,
		"School of Magic": 33,
		"Thieves' Den": 55,
		"Capitol": 20,
		"Theater": 33,
		"Museum": 72,
	},
	"zh_CN":
	{
		"Park": -15,
		"Quarry": -43,
		"Armory": -15,
		"Library": -5,
		"Keep": -40,
		"Factory": -15,
		"Smithy": -15,
		"Laboratory": -20,
		"Wishing Well": 10,
		"Statue": -20,
		"Imperial Treasury": -20,
		"Poor House": -15,
		"Map Room": -25,
		"Monument": 30,
		"Secret Vault": 20,
		"Thieves' Den": 35,
		"Theater": -5,
		"Stables": -20,
		"Museum": 35,
	}
}

const card_data = {
	# Purple
	"Library": {"star": 6, "kind": "purple"},
	"Park": {"star": 6, "kind": "purple"},
	"Quarry": {"star": 5, "kind": "purple"},
	"Armory": {"star": 3, "kind": "purple"},
	"Keep": {"star": 3, "kind": "purple"},
	"Ivory Tower": {"star": 5, "kind": "purple"},
	"Observatory": {"star": 4, "kind": "purple"},
	"Factory": {"star": 5, "kind": "purple"},
	"Smithy": {"star": 5, "kind": "purple"},
	"Laboratory": {"star": 5, "kind": "purple"},
	"Basilica": {"star": 4, "kind": "purple"},
	"Wishing Well": {"star": 5, "kind": "purple"},
	"Statue": {"star": 3, "kind": "purple"},
	"Imperial Treasury": {"star": 5, "kind": "purple"},
	"Great Wall": {"star": 6, "kind": "purple"},
	"Gold Mine": {"star": 6, "kind": "purple"},
	"Poor House": {"star": 4, "kind": "purple"},
	"Haunted Quarter": {"star": 2, "kind": "purple"},
	"Framework": {"star": 3, "kind": "purple"},
	"Necropolis": {"star": 5, "kind": "purple"},
	"Map Room": {"star": 5, "kind": "purple"},
	"Monument": {"star": 4, "kind": "purple"},
	"Secret Vault": {"star": 99, "kind": "purple"},
	"School of Magic": {"star": 6, "kind": "purple"},
	"Thieves' Den": {"star": 6, "kind": "purple"},
	"Capitol": {"star": 5, "kind": "purple"},
	"Theater": {"star": 6, "kind": "purple"},
	"Stables": {"star": 2, "kind": "purple"},
	"Museum": {"star": 4, "kind": "purple"},
	"Dragon Gate": {"star": 6, "kind": "purple"},
	# Green
	"Tavern": {"star": 1, "kind": "green"},
	"Market": {"star": 2, "kind": "green"},
	"Harbor": {"star": 4, "kind": "green"},
	"Docks": {"star": 3, "kind": "green"},
	"Trading Post": {"star": 2, "kind": "green"},
	"Town Hall": {"star": 5, "kind": "green"},
	# Red
	"Barracks": {"star": 3, "kind": "red"},
	"Watchtower": {"star": 1, "kind": "red"},
	"Fortress": {"star": 5, "kind": "red"},
	"Prison": {"star": 2, "kind": "red"},
	# Yellow
	"Palace": {"star": 5, "kind": "yellow"},
	"Castle": {"star": 4, "kind": "yellow"},
	"Manor": {"star": 3, "kind": "yellow"},
	# Blue
	"Church": {"star": 2, "kind": "blue"},
	"Cathedral": {"star": 5, "kind": "blue"},
	"Monastery": {"star": 3, "kind": "blue"},
	"Temple": {"star": 1, "kind": "blue"},
}

const char_data = {
	"Magistrate": 1,
	"Witch": 1,
	"Assassin": 1,
	"Thief": 2,
	"Spy": 2,
	"Blackmailer": 2,
	"Magician": 3,
	"Wizard": 3,
	"Seer": 3,
	"Patrician": 4,
	"King": 4,
	"Emperor": 4,
	"Bishop": 5,
	"Abbot": 5,
	"Cardinal": 5,
	"Alchemist": 6,
	"Merchant": 6,
	"Trader": 6,
	"Navigator": 7,
	"Scholar": 7,
	"Architect": 7,
	"Marshal": 8,
	"Diplomat": 8,
	"Warlord": 8,
	"Artist": 9,
	"Queen": 9,
	"Tax Collector": 9
}

const up_offset_char = {
	"en":
	{
		"Magistrate": 0,
		"Witch": 0,
		"Assassin": -45,
		"Thief": -50,
		"Spy": -30,
		"Blackmailer": 0,
		"Magician": -35,
		"Wizard": -15,
		"Seer": -15,
		"Patrician": -45,
		"King": -40,
		"Emperor": -15,
		"Bishop": -40,
		"Abbot": -30,
		"Cardinal": -15,
		"Alchemist": -30,
		"Merchant": -50,
		"Trader": -40,
		"Navigator": -55,
		"Scholar": -40,
		"Architect": -70,
		"Marshal": -15,
		"Diplomat": -20,
		"Warlord": -35,
		"Artist": -40,
		"Queen": -55,
		"Tax Collector": -20
	},
	"zh_CN":
	{
		"Magistrate": -20,
		"Witch": -30,
		"Assassin": -65,
		"Thief": -45,
		"Spy": -30,
		"Blackmailer": 0,
		"Magician": -65,
		"Wizard": -45,
		"Seer": -65,
		"Patrician": -70,
		"King": -70,
		"Emperor": -45,
		"Bishop": -55,
		"Abbot": -55,
		"Cardinal": -35,
		"Alchemist": -45,
		"Merchant": -70,
		"Trader": -50,
		"Navigator": -70,
		"Scholar": -55,
		"Architect": -100,
		"Marshal": -10,
		"Diplomat": -5,
		"Warlord": -55,
		"Artist": -35,
		"Queen": -75,
		"Tax Collector": -60
	}
}

func rid_num(name: String) -> String:
	var regex = RegEx.new()
	regex.compile("[0-9]")
	var result = regex.search(name)
	var new_name = name
	if result != null:
		new_name = name.replace(result.get_string(0), "")
	return new_name



func get_up_offset(name: String) -> float:
	var new_name = rid_num(name)
	return up_offset[TranslationServer.get_locale()].get(new_name, 0)
	

func get_card_info(name: String) -> Dictionary:
	var new_name = rid_num(name)
	var info_dic = card_data[new_name]
	var dic = {
		"card_name": new_name,
		"up_offset": get_up_offset(new_name),
		"star": info_dic["star"],
		"kind": info_dic["kind"],
	}
	return dic


func get_up_offset_char(animation_name: String) -> int:
	return up_offset_char[TranslationServer.get_locale()][animation_name]


func get_char_info(char_name: String) -> Dictionary:
	return {
		"char_name": char_name,
		"char_num": char_data[char_name],
		"char_up_offset": get_up_offset_char(char_name),
	}
