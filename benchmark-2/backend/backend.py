import flask
import datetime

app = flask.Flask(__name__)

@app.route("/what-date-is-it", methods=["GET"])
def dateHandler():
	date = datetime.date.today()

	result_object = {
		"year": date.year,
		"month": date.month,
		"day": date.day
	}

	# Можно кешировать на прокси, в течение одного дня
	#   дата точно не поменяется!
	# Очень хорошо про cache-control.
	#   https://stackoverflow.com/a/70970543
	# Создано сегодня в нашем часовом поясе. Переводим после
	#   этого в UTC, обычно в http передают utc время..
	created_datetime = datetime.datetime(date.year, date.month, date.day).astimezone(datetime.UTC)
	HTTP_TIME_FORMAT = "%a, %d %b %Y %H:%M:%S %Z"
	http_time = created_datetime.strftime(HTTP_TIME_FORMAT)
	headers = {
		"Last-Modified": http_time,
		"Date": http_time,
		"Cache-Control": "public, max-age=%d" % (24 * 60 * 60)
	}

	response = flask.jsonify([result_object] * 10_000)
	for header_name, header_value in headers.items():
		response.headers[header_name] = header_value
	return response


@app.route("/what-is-my-name", methods=["POST"])
def nameHandler():
	name = flask.request.form.get("name", "")

	result_object = {
		"name": name
	}

	response = flask.jsonify([result_object] * 10_000)
	return response

