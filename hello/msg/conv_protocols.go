// conv_protocols.go : 通信协议(自动生成)
 // !!!该文件自动生成，请勿直接编辑!!!

package msg

import (
    "hello/pb3"
     
)
    // 协议码
const (
    Bail                             = 500	// 获取游戏版本信息
)


// 协议对照
var PROTOS map[int]interface{} = map[int]interface{} {
    Bail                         : new(pb3.Bail) ,
}

// 协议名称
var PROTONAMES map[int]string = map[int]string {
    Bail                         :  "Poster.Bail" ,
}

