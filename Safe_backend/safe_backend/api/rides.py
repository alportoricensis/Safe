"""REST API for ride requests."""
import datetime
import flask
import safe_backend
from collections import deque

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
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
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


@safe_backend.app.route("/api/v1/rides/passengers/<int:ride_id>/", methods=["GET"])
# REQUIRES  - User is authenticated with passenger, driver, or dispatcher level permissions
#             If passenger, ride_id MUST have been booked by the currently authenticated user
# EFFECTS   - Returns the details for ride_id, including:
#               - Assigned vehicle
#               - Pickup location
#               - Dropoff location
#               - Estimated dropoff time
#               - Estimated pickup time
# MODIFIES  - Nothing
def get_passenger_ride(ride_id):
    """Return the queue for driver with driver_id."""
    # TODO: Authentication
    # TODO: Convert details to JSON
    context = {}
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/", methods=["POST"])
# REQUIRES - flask.request.args.user_id is a valid user_id and is currently authenticated
#            flask.request.args.pickup is a valid pickup location
#            flask.request.args.dropoff is a valid dropoff location
# EFFECTS  - Creates a RideRequest for user_id, and triggers a recalculation of driver itineraries
# MODIFIES - VEHICLE_QUEUES, RIDE_REQUESTS
def post_ride():
    """Add a RideRequest to the ride-share service."""
    # TODO: Authentication
    # TODO: Create object
    # TODO: Trigger recalculation
    # TODO: Return proper status
    context = {}
    return flask.jsonify(**context), 200