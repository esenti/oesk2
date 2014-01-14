from flask import Flask, jsonify, render_template, request
from google.appengine.ext import ndb
from datetime import datetime

app = Flask(__name__)


class Result(ndb.Model):
    score = ndb.IntegerProperty()
    browser_name = ndb.StringProperty()
    browser_version = ndb.StringProperty()
    os = ndb.StringProperty()
    date = ndb.DateTimeProperty()

@app.route('/test')
def test():
    return render_template('test.html')

@app.route('/')
def index():
    query = Result.query().order(-Result.date)
    return render_template('index.html', results=[item.to_dict() for item in query])


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

if __name__ == "__main__":
    app.run()