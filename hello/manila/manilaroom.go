package manila

import "hello/baseroom"

type ManilaRoom struct {
	room baseroom.Room
	mapp map[string]ManilaSpot
}

func (self *ManilaRoom) New(roomNum int) *ManilaRoom {
	self.room = *(new(baseroom.Room).New(roomNum, 1, 3, 5))
	self.Reset()
	return self
}

func (self *ManilaRoom) Enter(player *ManilaPlayer) (*ManilaPlayer, bool) {
	baseplayer, entered := self.room.Enter(&player.Player)
	player.Player = *baseplayer
	return player, entered
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

func (self *ManilaRoom) GetRoom() baseroom.Room {
	return self.room
}

func (self *ManilaRoom) GetMap() map[string]ManilaSpot {
	return self.mapp
}
