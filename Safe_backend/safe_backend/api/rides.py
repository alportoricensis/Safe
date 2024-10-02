"""REST API for ride requests."""
import datetime
import flask
import safe_backend
from collections import dequeue

# Globals
# VEHICLE_QUEUES maps a vehicle_id to the queue for that assigned vehicle.
VEHICLE_QUEUES = {}
# RIDE_REQUESTS is a list of all currenty active ride ride requests
RIDE_REQUESTS = []


# Routes
@safe_backend.app.route("/api/v1/rides/", methods=["GET"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Returns all currently active ride requests
# MODIFIES  - Nothing
def get_rides():
    """Return all currently active ride requests."""
    # TODO: Authentication
    # TODO: Convert list to JSON
    context = {}
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/drivers/<int:driver_id>/", methods=["GET"])
# REQUIRES  - User is authenticated with driver-level permissions
#             driver_id is current authenticated user
# EFFECTS   - Returns the queue for driver with driver_id
# MODIFIES  - Nothing
def get_driver_rides(driver_id):
    """Return the queue for driver with driver_id."""
    # TODO: Authentication
    # TODO: Convert queue to JSON
    context = {}
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/<int:ride_id>/", methods=["GET"])
# REQUIRES  - User is authenticated with passenger, driver, or dispatcher level permissions
#             If passenger, ride_id MUST have been booked by the currently authenticated user
# EFFECTS   - Returns the details for ride_id, including:
#               - Assigned vehicle
#               - Pickup location
#               - Dropoff location
#               - Estimated dropoff time
#               - Estimated pickup time
# MODIFIES  - Nothing
def get_driver_rides(ride_id):
    """Return the queue for driver with driver_id."""
    # TODO: Authentication
    # TODO: Convert details to JSON
    context = {}
    return flask.jsonify(**context), 200
