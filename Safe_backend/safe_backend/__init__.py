"""Safe Backend package initializer."""
import flask
from flask_cors import CORS

app = flask.Flask(__name__)
CORS(app)
app.config.from_object("safe_backend.config")
app.config.from_envvar("SAFE_BACKEND_SETTINGS", silent=True)

import safe_backend.api
import safe_backend.views 