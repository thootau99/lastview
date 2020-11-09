import json

try:
    with open('./notiAc.json') as f:
            notification_json = json.load(f)
except IOError as e:
    notification_json = {'notification': []}
    with open('./notiAc.json', 'w') as f:
        json.dump(notification_json, f)


def notiPrint():
    return json.dumps(notification_json, indent = 4, sort_keys=True)

def notiAdd(data):
    notification_json['notification'].append(data)
    print(notification_json)
    with open('./notiAc.json', 'w') as f:
        json.dump(notification_json, f)