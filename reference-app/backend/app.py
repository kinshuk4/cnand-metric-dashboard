from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import pymongo
from flask_pymongo import PyMongo

from os import getenv
import logging
from jaeger_client import Config
from jaeger_client.metrics.prometheus import PrometheusMetricsFactory

from flask_opentracing import FlaskTracing
from prometheus_flask_exporter.multiprocess import GunicornInternalPrometheusMetrics

app = Flask(__name__)
CORS(app)

app.config["MONGO_DBNAME"] = "example-mongodb"
app.config[
    "MONGO_URI"
] = "mongodb://example-mongodb-svc.default.svc.cluster.local:27017/example-mongodb"

mongo = PyMongo(app)

metrics = GunicornInternalPrometheusMetrics(app)
metrics.info("app_info", "Backend Service", version="1.0")


def init_logging():
    logging.getLogger("").handlers = []
    logging.basicConfig(format="%(message)s", level=logging.INFO)


def init_tracer(service):
    config = Config(
        config={
            "sampler": {
                "type": "const",
                "param": 1,
            },
            "logging": True,
            "reporter_batch_size": 1,
        },
        service_name=service,
        validate=True,
        metrics_factory=PrometheusMetricsFactory(service_name_label=service),
    )

    return config.initialize_tracer()


init_logging()
tracer = init_tracer("backend")
tracing = FlaskTracing(tracer, True, app)


@app.route("/")
@tracing.trace()
def homepage():
    return "Hello World"


@app.route("/api")
@tracing.trace()
def my_api():
    answer = "something"
    return jsonify(response=answer)


@app.route("/star", methods=["POST"])
@tracing.trace()
def add_star():
    star = mongo.db.stars
    name = request.json["name"]
    distance = request.json["distance"]
    star_id = star.insert({"name": name, "distance": distance})
    new_star = star.find_one({"_id": star_id})
    output = {"name": new_star["name"], "distance": new_star["distance"]}
    return jsonify({"result": output})


if __name__ == "__main__":
    app.run()
