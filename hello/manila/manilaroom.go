package manila

import "hello/baseroom"

type ManilaRoom struct {
	room baseroom.Room
	mapp map[string]ManilaSpot
}

func (self ManilaRoom) New(roomNum int, gameNum int, playerNumForStart int, playerNumMax int) ManilaRoom {
	self.room = baseroom.Room{}.New(roomNum, gameNum, playerNumForStart, playerNumMax)
	self.Reset()
	return self
}

func (self *ManilaRoom) Enter(player ManilaPlayer) bool {
	return self.room.Enter(baseroom.Player(player.Player))
}

func (self *ManilaRoom) Exit(name string) bool {
	return self.room.Exit(name)
}

func (self *ManilaRoom) StartGame() bool {
	return self.room.StartGame()
}

func (self *ManilaRoom) Reset() {
	self.mapp = DeepCopy(MappingOrigin)

}
