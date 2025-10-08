from flask import Flask, request, jsonify
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)

@app.route("/")
def main():
    return jsonify({'message': 'Main'})

@app.route("/download")
def download():
    path = ""

@app.route("Games/scores/Zoey")
def getZoeyScores():
    json.load