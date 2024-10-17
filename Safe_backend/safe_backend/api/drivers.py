"""REST API for ride requests."""
import datetime
import flask
import safe_backend
from collections import deque
import safe_backend.api.vehicles
import safe_backend.api.config


# Routes
@safe_backend.app.route("/api/v1/vehicles/login/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as able to receive requests
# MODIFIES  - VEHICLE_QUEUES
def login_vehicle():
    """Marks <vehicle_id> as ready to receive requests."""
    # TODO: Authentication -  must have agency or driver level permissions

    # Check vehicle is not already logged in
    vehicle_id = flask.request.json["vehicle_id"]
    lat = flask.request.json["latitude"]
    log = flask.request.json["longitude"]
    if vehicle_id in safe_backend.api.config.VEHICLE_QUEUES:
        context = {
            "msg": "Vehicle " + vehicle_id + " is already logged in"
        }
        return flask.jsonify(**context), 400

    # TODO: Check vehicle is registered and in database

    # TODO: Query database for vehicle capacity and range

    # TODO: Get location from login request
    
    # Create vehicle
    new_vehicle = safe_backend.api.vehicles.Vehicle(vehicle_id=vehicle_id, status="active",capacity=10, range=200, latin=lat, longin=log)

    # Add vehicle to mappings
    safe_backend.api.config.VEHICLE_QUEUES[vehicle_id] = new_vehicle
    if safe_backend.api.config.MODE == "ROUNDROBIN":
        safe_backend.api.config.ROUND_ROBIN_QUEUE.append(new_vehicle)

    # Return success
    context = {
        "msg": "Successfully logged in vehicle: " + vehicle_id
    }

    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/vehicles/pause/<vehicle_id>/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as not receiving ride requests
# MODIFIES  - VEHICLE_QUEUES
def pause_vehicle(vehicle_id):
    """Marks <vehicle_id> as not receiving requests."""
    # TODO: Authentication

    # If vehicle is not active, return a 404
    if vehicle_id not in safe_backend.api.config.VEHICLE_QUEUES:
        context = {
            "msg": "Vehicle " + vehicle_id + " is not active."
        }
        return flask.jsonify(**context), 404
        
    # Grab vehicle from mapping and change its status
    safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].status = "paused"

    # Return success
    context = {
        "msg": "Successfully paused vehicle: " + vehicle_id
    }

    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/vehicles/logout/<vehicle_id>/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as logged out
# MODIFIES  - VEHICLE_QUEUES
def logout_vehicle(vehicle_id):
    """Marks <vehicle_id> as logged out."""
    # TODO: Authentication

    # If vehicle is not active, return a 404
    if vehicle_id not in safe_backend.api.config.VEHICLE_QUEUES:
        context = {
            "msg": "Vehicle " + vehicle_id + " is not active."
        }
        return flask.jsonify(**context), 404
        
    # Grab vehicle from mapping and remove it
    del safe_backend.api.config.VEHICLE_QUEUES[vehicle_id]

    # Return success
    context = {
        "msg": "Successfully logged out vehicle: " + vehicle_id
    }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/vehicles/", methods=["GET", "OPTIONS"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Returns all active vehicles
# MODIFIES  - Nothing
def get_vehicles():
    """Marks <vehicle_id> as logged out."""
    # TODO: Authentication

    
    # Grab vehicle from active list and return, along with their URL
    context = {}
    for vehicle_id in safe_backend.api.config.VEHICLE_QUEUES:
        context[vehicle_id] = {
            "vehicle_id": vehicle_id,
            "lat": safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].lat,
            "long": safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].log,
            "queue_url": "/api/v1/rides/drivers/" + vehicle_id + "/",
            "itinerary": []
        }
        for ride_request in safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].itinerary:
            context[vehicle_id]["itinerary"].append({
                "passenger": ride_request.passenger_name,
                "driver": ride_request.driver,
                "pickup": ride_request.pickup,
                "dropoff": ride_request.dropoff,
                "ETA": ride_request.eta,
                "ETP": ride_request.etp,
                "reqid": ride_request.request_id
            })

    # Return success
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/vehicles/location/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Posts the location of <vehicle_id>
# MODIFIES  - Nothing
def post_loc():
    """Marks <vehicle_id> as logged out."""
    # TODO: Authentication

    # Get locations from request and update
    vehicle_id = flask.request.json["vehicle_id"]
    if vehicle_id not in safe_backend.api.config.VEHICLE_QUEUES:
        context = {
            "msg": "Vehicle not logged in."
        }
        return flask.jsonify(**context), 404
    
    safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].lat = flask.request.json["latitude"]
    safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].log = flask.request.json["longitude"]

    context = {
        "msg": "Success"
    }

    # Return success
    return flask.jsonify(**context), 200