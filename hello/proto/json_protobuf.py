def proto_inside(obj, content, key, level, num):
    if isinstance(obj, int):
        content = handle_int(obj, content, key, level, num)
    elif isinstance(obj, (str, bytes)):
        content = handle_str(obj, content, key, level, num)
    elif isinstance(obj, float):
        content = handle_float(obj, content, key, level, num)
    elif isinstance(obj, list):
        content = handle_list(obj, content, key, level, num)
    elif isinstance(obj, dict):
        content = handle_dict(obj, content, key, level)

    return content


def handle_int(obj, content, key, level, num):
    content += level * '    '
    content += 'int32    %10s = %3s;' % (key, num)
    content += '\n'
    return content


def handle_str(obj, content, key, level, num):
    content += level * '    '
    content += 'string   %10s = %3s;' % (key, num)
    content += '\n'
    return content


def handle_float(obj, content, key, level, num):
    content += level * '    '
    content += 'double   %10s = %3s;' % (key, num)
    content += '\n'
    return content


def handle_list(obj, content, key, level, num):
    if obj:
        first_element = obj[0]
        if isinstance(first_element, (int, str, float, bytes)):
            content += level * '    '
            content += 'repeated '
            content = proto_inside(first_element, content, key, level, num)
        else:
            content += level * '    '
            content += 'repeated %-4s %5s = %3s;\n\n' % (key.upper(), key, num)
            content += level * '    '
            content += 'message %s {\n' % key.upper()
            level += 1
            content = proto_inside(first_element, content, key, level, num)
            level -= 1
            content += level * '    '
            content += '}\n'
        num += 1
    return content


def handle_dict(obj, content, key, level):
    num = 1
    for k, v in obj.items():
        if not isinstance(v, dict):
            content = proto_inside(v, content, k, level, num)
        else:
            content += level * '    '
            content += '%-8s %10s = %3s;\n\n' % (k.upper(), k, num)
            content += level * '    '
            level += 1
            content += 'message %s {\n' % k.upper()

            content = proto_inside(v, content, k, level, num)
            level -= 1
            content += level * '    '
            content += '}\n'
        num += 1
    content += '\n'

    return content


def make_proto_file(content, file_name):
    with open('protos/%s.proto' % file_name, 'w') as f:
        f.write(content)


def to_protobuf_file(obj, file_name=None):
    if not file_name:
        file_name = 'default'

    content = 'syntax = "proto3"; \npackage %s;\n\n' % file_name
    key = file_name
    content += 'message %s {\n' % key
    content = proto_inside(obj, content, key, 1, 1)
    content += '}\n'

    return content





if __name__ == '__main__':
    obj = {
        "Code": 1,
        "Req":
            {
                "Username": "",
                "Password": ""
            },
        "Ans":
            {
                "Username": "",
                "Gold": 0,
                "Mobile": "",
                "Email": "",
            },
        "Error": 0
    }
    content = to_protobuf_file(obj, 'sample')
    print(content)