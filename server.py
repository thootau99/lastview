from flask import Flask
from flask import request
from flask import render_template
from flask import jsonify

import os
import notificationManager as nm
app = Flask(__name__)


distance = 0
waitingInstruction = {'instruction': '0', 'executed': '0'}
facename = []
followname = ''
@app.route('/')
def hello_world():
    return "test"
@app.route('/stopwork')
def stopwork():
    global waitingInstruction
    waitingInstruction = {'instruction': 'stop', 'executed': '0'}

@app.route('/startwork')
def startwork():
    global waitingInstruction
    waitingInstruction = {'instruction': 'start', 'executed': '0'}

@app.route('/mask')
def mask():
    global waitingInstruction
    waitingInstruction = {'instruction': 'mask', 'executed': '0'}

@app.route('/normal')
def normal():
    global waitingInstruction
    waitingInstruction = {'instruction': 'normal', 'executed': '0'}


@app.route('/new_data')
def new_data():
    data = {'instruction': request.args.get('ins'), 'executed': '0'}    
    global waitingInstruction
    waitingInstruction = data
    print(waitingInstruction)

    return '0'


@app.route('/update_data')
def update_data():
    global waitingInstruction
    if waitingInstruction['executed'] is '0':
        waitingInstruction['executed'] = '1'
        return jsonify(waitingInstruction)
    else:
        return jsonify({'instruction': 'no'})

@app.route('/set_face')
def set_face():
    global facename
    facename = request.args.get('facename')
    return  jsonify(facename)

@app.route('/get_face')
def get_face():
    global facename
    return jsonify(facename)

@app.route('/set_face_from_app')
def set_face_from_app():
    global followname
    global waitingInstruction
    followname = request.args.get('facename')

    waitingInstruction = {'instruction': 'setname', 'name': followname, 'executed': '0'}

@app.route('/get_face_from_app')
def get_face_from_app():    
    return jsonify(followname)
@app.route('/see_data')
def see_data():
    print(waitingInstruction)
    return jsonify(waitingInstruction)
@app.route('/land')
def land():
    os.system("echo land success?")
    return "0"

@app.route('/new_noti')
def new_noti():
    typeOfNoti = request.args.get('type')
    timeOfNoti = request.args.get('time')
    contentOfNoti = request.args.get('content')
    imageURLOfNoti = request.args.get('imageURL')
    idOfNoti = request.args.get('id')
    NOTIFICATION_OFFICAL = {'id':idOfNoti,'type': typeOfNoti, 'time': timeOfNoti, 'content': contentOfNoti, 'imageURL': imageURLOfNoti}
    nm.notiAdd(NOTIFICATION_OFFICAL)

@app.route('/show_noti')
def show_noti():
    return nm.notiPrint()

app.run(host="0.0.0.0")