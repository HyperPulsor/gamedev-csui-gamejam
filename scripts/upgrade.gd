extends Node

const UPGRADES = {
	"icespear1": {
		"icon": "res://assets/ice_spear.png",
		"displayname": "Ice Spear",
		"details": "A spear of ice is thrown at a random enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"icespear2": {
		"icon": "res://assets/ice_spear.png",
		"displayname": "Ice Spear",
		"details": "An addition Ice Spear is thrown",
		"level": "Level: 2",
		"prerequisite": ["icespear1"],
		"type": "weapon"
	},
	"icespear3": {
		"icon": "res://assets/ice_spear.png",
		"displayname": "Ice Spear",
		"details": "Ice Spears now pass through another enemy and do + 3 damage",
		"level": "Level: 3",
		"prerequisite": ["icespear2"],
		"type": "weapon"
	},
	"icespear4": {
		"icon": "res://assets/ice_spear.png",
		"displayname": "Ice Spear",
		"details": "An additional 2 Ice Spears are thrown",
		"level": "Level: 4",
		"prerequisite": ["icespear3"],
		"type": "weapon"
	},
	"fireball1": {
		"icon": "res://assets/FB500-3.png",
		"displayname": "Fireball",
		"details": "A fireball is created and random heads somewhere in the players direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"fireball2": {
		"icon": "res://assets/FB500-3.png",
		"displayname": "Fireball",
		"details": "An additional fireball is created",
		"level": "Level: 2",
		"prerequisite": ["fireball1"],
		"type": "weapon"
	},
	"fireball3": {
		"icon": "res://assets/FB500-3.png",
		"displayname": "Fireball",
		"details": "The fireball cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisite": ["fireball2"],
		"type": "weapon"
	},
	"fireball4": {
		"icon": "res://assets/FB500-3.png",
		"displayname": "Fireball",
		"details": "An additional fireball is created and the knockback is increased by 25%",
		"level": "Level: 4",
		"prerequisite": ["fireball3"],
		"type": "weapon"
	},
	"food": {
		"icon": "res://assets/chunk.png",
		"displayname": "Food",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}
}
