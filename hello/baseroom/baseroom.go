package baseroom

type Room struct {
	RoomNum int
	GameNum int
	Started bool
	Players map[string]Player
}
