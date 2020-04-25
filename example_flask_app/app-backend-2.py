from flask import Flask, jsonify, request
import os

ASSETS_DIR = os.path.dirname(os.path.abspath(__file__))
app = Flask(__name__)


@app.route('/')
def index():
    return 'Flask is running!'


@app.route('/data')
def names():
    data = {"data-backend-2": ["X", "Y", "Z"]}
    return jsonify(data)


@app.route('/users/<user_id>', methods=['GET', 'POST'])
def user(user_id):
    if request.method == 'GET':
        """return <user_id> information"""
        data = {"data-backend-2": ["GET"]}
        return jsonify(data)
    if request.method == 'POST':
        """modify/update <user_id> information"""
        data = {"data-backend-2": ["POST"]}
        return jsonify(data)


if __name__ == '__main__':
    context = ('backend-2.local.app.crt', 'backend-2.local.app.key')
    app.run(host='backend-2.local.app', debug=True, ssl_context=context)
