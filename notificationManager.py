import json


with open('./notiAc.json') as f:
    notification_json = json.load(f)

def notiPrint():
    return json.dumps(notification_json, indent = 4, sort_keys=True)

def notiAdd(data):
    notification_json['notification'].append(data)

    with open('./notiAc.json', 'w') as f:
        json.dump(notification_json, f)