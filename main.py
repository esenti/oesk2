from flask import Flask, jsonify, render_template, request
from google.appengine.ext import ndb
from datetime import datetime
from itertools import groupby

app = Flask(__name__)


class Result(ndb.Model):
    score = ndb.IntegerProperty()
    browser_name = ndb.StringProperty()
    browser_version = ndb.StringProperty()
    os = ndb.StringProperty()
    date = ndb.DateTimeProperty()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/results', methods=['GET', 'POST'])
def results():
    if request.method == 'POST':
        data = request.get_json()

        result = Result(date=datetime.now(), **data)
        result.put()

        query = Result.query(Result.browser_name == data['browser_name'], Result.browser_version == data['browser_version'], Result.os == data['os'])

        scores = [item.score for item in query]

        return jsonify({'average_score': sum(scores) / len(scores) if len(scores) > 0 else 0})
    else:
        query = Result.query().order(-Result.date)

        return jsonify({'items': [item.to_dict() for item in query]})


@app.route('/api/stats/browsers')
def browsers():
        query = Result.query().order(Result.browser_name)

        return jsonify({'items': [{'browser': k, 'count': len([_ for _ in g])} for k, g in groupby(query, lambda (item): item.browser_name)]})

@app.route('/api/stats/os')
def os():
        query = Result.query().order(Result.os)

        return jsonify({'items': [{'os': k, 'count': len([_ for _ in g])} for k, g in groupby(query, lambda (item): item.os)]})

def avg(l):
    return sum(l) / len(l)

@app.route('/api/stats/results')
def average_results():
        query = Result.query().order(Result.os, Result.browser_name)

        return jsonify({'items': [{'platform': k, 'value': avg([item.score for item in g])} for k, g in groupby(query, lambda (item): (item.os, item.browser_name))]})


if __name__ == "__main__":
    app.run()