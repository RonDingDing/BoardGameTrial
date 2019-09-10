package models

import (
	"github.com/astaxie/beego/orm"
	_ "github.com/lib/pq"
)

type PlayerUser struct {
	Id       int64
	Name     string
	Password string
	Mobile   string
	Email    string
	Gold     int
}

func init() {
	// PostgreSQL 配置
	orm.RegisterDriver("postgres", orm.DRPostgres) // 注册驱动
	orm.RegisterDataBase("default", "postgres", "user=ron password=qwe dbname=manila host=127.0.0.1 port=5432 sslmode=disable")
	orm.RegisterModel(new(PlayerUser))
	orm.RunSyncdb("default", false, true)

}
