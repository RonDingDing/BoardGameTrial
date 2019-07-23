// conv_protocols.go : 通信协议(自动生成)
 // !!!该文件自动生成，请勿直接编辑!!!

package msg

import (
    "hello/pb3"
     
)
    // 协议码
const (
    Mail                             = 100	// 获取游戏版本信息
    Bail                             = 500	// 获取游戏版本信息
)


// 协议对照
var PROTOS map[int]interface{} = map[int]interface{} {
    Mail                         : new(pb3.Mail) ,
    Bail                         : new(pb3.Bail) ,
}

// 协议名称
var PROTONAMES map[int]string = map[int]string {
    Mail                         :  "Poster.Mail" ,
    Bail                         :  "Poster.Bail" ,
}

