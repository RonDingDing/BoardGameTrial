let ProtoBuf = require('protobufjs');
ProtoBuf.Util.IS_NODE = cc.sys.isNative;


ProtoBuf.loadJsonFile = function (filename, callback, builder) {
    if (callback && typeof callback === 'object')
        builder = callback,
            callback = null;
    else if (!callback || typeof callback !== 'function')
        callback = null;
    if (callback)
        return cc.loader.load(typeof filename === 'string' ? filename : filename["root"] + "/" + filename["file"], function (error, contents) {
            if (contents === null) {
                callback(Error("Failed to fetch file"));
                return;
            }
            try {
                callback(null, ProtoBuf.loadJson(JSON.parse(contents), builder, filename));
            } catch (e) {
                callback(e);
            }
        });
    var contents = ProtoBuf.Util.fetch(typeof filename === 'object' ? filename["root"] + "/" + filename["file"] : filename);
    return contents === null ? null : ProtoBuf.loadJson(contents, builder, filename);
};

module.exports = {
    root: 'pb',

    preload(cb) {
        ProtoBuf.Util.fetch = cc.loader.getRes.bind(cc.loader);
        cc.loader.loadResDir(this.root, (error, data) => {            
            cb();
        });
    },
    /**
     * 加载文件proto文件，支持json、proto格式
     * @param {String|Array} files 
     */
    loadFromFile(fileNames, packageName) {
        if (typeof fileNames === 'string') {
            fileNames = [fileNames];            
        }

        let builder = ProtoBuf.newBuilder();
        builder.importRoot = 'pb';                      //此处修改 2.0版本及其以上可用
        // builder.importRoot = cc.url.raw(`resources/${this.root}`);           // 此处修改2.0版本一下可用
        
        fileNames.forEach((fileName) => {
            let extname = cc.path.extname(fileName);
            let fullPath = `${builder.importRoot}/${fileName}`;
            if (extname === '.proto') {
                ProtoBuf.loadProtoFile(fullPath,builder);                
            } else if (extname === '.json') {
                ProtoBuf.loadJsonFile(fullPath, builder);
            } else {
                cc.log(`nonsupport file extname, only support 'proto' or 'json'`);
            }
        });

        return builder.build(packageName);
    },

    /**
     * 加载所有proto文件
     * @param {String} extname 
     * @param {String} packageName 
     */
    loadAll(extname = 'proto', packageName = '') {
        let files = [];
        if (this.root.endsWith('/') || this.root.endsWith('\\')) {
            this.root = this.root.substr(0, this.root.length - 1);
        }

        //获取this.root下的所有文件名
        // cc.loader._resources.getUuidArray(this.root, null, files);
        cc.loader._assetTables.assets.getUuidArray(this.root, null, files);
        files = files.map((filePath) => {
            let str = filePath.substr(this.root.length + 1);
            return `${str}.${extname}`;
        });        
        return this.loadFromFile(files, packageName);
    },

    loadData(url, callback) {
        if (cc.sys.isNative) {
            let data = jsb.fileUtils.getDataFromFile(url);
            setTimeout(() => {
                callback(data);
            }, 0);
        } else {
            var xhr = ProtoBuf.Util.XHR();
            xhr.open('GET', url, true);
            xhr.setRequestHeader('Accept', 'text/plain');
            xhr.responseType = 'arraybuffer';
            if (typeof xhr.overrideMimeType === 'function') xhr.overrideMimeType('text/plain');
            if (callback) {
                xhr.onreadystatechange = function () {
                    if (xhr.readyState != 4) return;
                    if (/* remote */ xhr.status == 200 || /* local */ (xhr.status == 0))
                        callback(xhr.response);
                    else
                        callback(null);
                };
                if (xhr.readyState == 4)
                    return;
                xhr.send(null);
            }
        }
    }

}