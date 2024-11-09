"""REST API for users."""
import datetime
import flask
import psycopg2
import safe_backend.api.config
from safe_backend.api.requests import RideRequests
from safe_backend.api.utils import *

# Routes
@safe_backend.app.route("/api/v1/users/login/", methods=["POST"])
def login_user():
    pass

@safe_backend.app.route("/api/v1/users/create/", methods=["POST"])
def create_acct():
    pass

@safe_backend.app.route("/api/v1/users/delete/", methods=["POST"])
def delete_acct():
    pass

@safe_backend.app.route("/api/v1/users/update/", methods=["POST"])
def update_acct():
    pass