"""REST API for ride requests."""
import datetime
import flask
import safe_backend
from collections import deque

# Globals


# Routes
@safe_backend.app.route("/api/v1/vehicles/login/<vehicle_id>/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as able to receive requests
# MODIFIES  - VEHICLE_QUEUES
def login_vehicle():
    """Marks <vehicle_id> as ready to receive requests."""
    # TODO: Authentication
    # TODO: Convert list to JSON
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }


@safe_backend.app.route("/api/v1/vehicles/pause/<vehicle_id>/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as not receiving ride requests
# MODIFIES  - VEHICLE_QUEUES
def pause_vehicle():
    """Marks <vehicle_id> as not receiving requests."""
    # TODO: Authentication
    # TODO: Convert list to JSON
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/vehicles/logout/<vehicle_id>/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as logged out
# MODIFIES  - VEHICLE_QUEUES
def logout_vehicle():
    """Marks <vehicle_id> as logged out."""
    # TODO: Authentication
    # TODO: Convert list to JSON
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
    return flask.jsonify(**context), 200