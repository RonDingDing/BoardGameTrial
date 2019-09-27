def go_inside(key, obj, lst, content, stack):
    if isinstance(obj, bool):
        content = handle_bool(key, obj, lst, content, stack)
    elif isinstance(obj, int):
        content = handle_int(key, obj, lst, content, stack)
    elif isinstance(obj, (str, bytes)):
        content = handle_str(key, obj, lst, content, stack)
    elif isinstance(obj, float):
        content = handle_float(key, obj, lst, content, stack)
    elif isinstance(obj, list):
        content = handle_list(key, obj, False, content, stack)
    elif isinstance(obj, dict):
        content = handle_dict(key, obj, False, content, stack)

    return content


def handle_bool(key, obj, lst, content, stack):
    content += "    %-10s %2s%-6s\n" % (capitalize(key),
                                        "" if not lst else "[]", "bool")
    return content


def handle_int(key, obj, lst, content, stack):
    content += "    %-10s %2s%-6s\n" % (capitalize(key),
                                        "" if not lst else "[]", "int")
    return content


def handle_str(key, obj, lst, content, stack):
    content += "    %-10s %2s%-6s\n" % (capitalize(key),
                                        "" if not lst else "[]", "string")
    return content


def handle_float(key, obj, lst, content, stack):
    content += "    %-10s %2s%-6s\n" % (capitalize(key),
                                        "" if not lst else "[]", "float")
    return content


def handle_list(key, obj, lst, content, stack):
    v = obj[0]
    if isinstance(v, (int, str, float)):
        content = go_inside(capitalize(key), v, True, content, stack)
    else:
        new_key = capitalize(key)
        content += "    %-10s []%-6s\n" % (capitalize(key),
                                           "*" + capitalize(key) + "S")
        string = ""
        string = go_inside(new_key + "S", v, lst, string, stack)
        stack.append(string)
    return content


def handle_dict(key, obj, lst, content, stack):
    content += "\ntype %s struct {\n" % capitalize(key)
    for k, v in obj.items():
        if isinstance(v, (int, str, float)):
            content = go_inside(capitalize(k), v, lst, content, stack)

        elif isinstance(v, list):
            content = go_inside(capitalize(k), v, lst, content, stack)

        else:
            new_key = capitalize(key) + capitalize(k)
            content += "    %-10s %-6s\n" % (capitalize(k),
                                             "*" + capitalize(new_key))
            string = ""
            string = go_inside(new_key, v, lst, string, stack)
            stack.append(string)
    content += "}\n"
    while stack:
        i = stack.pop()
        content = i + content

    return content


def capitalize(string):
    return (string[0].upper()) + (string[1:])


def make_proto_file(content, file_name):
    with open('protos/%s.proto' % file_name, 'w') as f:
        f.write(content)


def to_go(obj, file_name=None):
    if not file_name:
        file_name = 'default'

    key = file_name
    stack = []

    content = go_inside(key, obj, False, '', stack)
    content = 'package pb3\n' + content
    return content


dic_make = {
    "float": "0",
    "float64": "0",
    "float32": "0",
    "int32": "0",
    "int": "0",
    "int64": "0",
    "uint32": "0",
    "uint64": "0",
    "bool": "false",
    "string": "\"\"",
    "[]byte": "[]byte{'{', '}'}",

    "[]float": "make([]float, 0)",
    "[]float64": "make([]float64, 0)",
    "[]float32": "make([]float32, 0)",
    "[]int": "make([]int, 0)",
    "[]int32": "make([]int32, 0)",
    "[]int64": "make([]int64, 0)",
    "[]uint32": "make([]uint32, 0)",
    "[]uint64": "make([]uint64, 0)",
    "[]bool": "make([]bool, 0)",
    "[]string": "make([]string, 0)",
    "[][]byte": "make([][]byte, 0)",
}


def make_new(content):
    result = ""
    lst = content.split("type ")
    for e in lst:
        if "struct" in e:
            obj_name = e.split(" ")[0]
            new_str = e.split("struct")[1].replace("\n", ",").replace("{", "") \
                .replace("}", "").strip(",").strip(" ").strip(", ").replace("    ", " ").replace("   ", " ") \
                .replace("  ", " ").replace(" ,", ",")
            result += "func (self *%s) New() *%s {\n" % (obj_name, obj_name)
            for m in new_str.split(", "):
                param = m.split(" ")[0]
                typing = m.split(" ")[1]
                if typing in dic_make:
                    result += "    self.%s = %s\n" % (param, dic_make[typing])
                else:
                    result += "    self.%s =  new(%s).New()\n" % (
                        param, typing.replace("*", ""))

            result += "    return self\n}\n\n"
    return result


if __name__ == '__main__':
    BuyStockMsg = "009"
    false = False
    true = True
    obj = buystockmsg = {
        "Code": BuyStockMsg,
        "Req":
        {
            "Username": "",
            "Stock": 0,
        },
        "Ans":
        {
            "Username": "",
            "RemindOrOperated": false,
            "Bought": false
        },
        "Error": 0

    }
    content = to_go(obj, 'BuyStockMsg')

    print(content)
    new_content = make_new(content)
    print(new_content)
