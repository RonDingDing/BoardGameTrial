

function NewBail_REQ(){
    var self = {};
    self.Username = "";
    self.Password = "";
    self.Able = [];
    return self;
}

function NewBail_ANS(){
    var self = {};
    self.Password = "";
    return self;
}

function NewBail(){
    var self = {};
    self.Code = 0;
    self.Exdata = new Uint8Array([]);
    self.Req = NewBail_REQ();
    self.Ans = NewBail_ANS();
    self.Error = 0;
    return self;
}
module.exports = {
    Bail : NewBail(), 

}
