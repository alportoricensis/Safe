"""REST API for settings."""
import datetime
import flask
import safe_backend
from collections import deque


# Routes
@safe_backend.app.route("/api/v1/settings/vehicles/", methods=["GET", "POST", "DELETE"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Creates a new vehicle with capacity and range
# MODIFIES  - database
def vehicles():
    """Create a new vehicle with given parameters."""
    # TODO: Authentication
    # TODO: Convert list to JSON
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/settings/pickups/", methods=["GET", "POST"])
# REQUIRES  - User is authenticated with agency-level permissions (for POST)
#             User is authenticated with passenger-level permissions (for GET)
# EFFECTS   - CREATE new pickup/dropoff location
#             GET all pickup/dropoff locations
# MODIFIES  - database
def locations():
    """Create a new vehicle with given parameters."""
    # TODO: Authentication
    # TODO: Convert list to JSON
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/settings/range/", methods=["GET", "POST"])
# REQUIRES  - User is authenticated with agency-level permissions (for POST)
#             User is authenticated with passenger-level permissions (for GET)
# EFFECTS   - CREATE new pickup/dropoff ranges
#             GET all pickup/dropoff ranges
# MODIFIES  - database
def range():
    """Create a new vehicle with given parameters."""
    # TODO: Authentication
    # TODO: Convert list to JSON
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
    return flask.jsonify(**context), 200