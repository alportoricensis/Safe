"""REST API for ride requests."""
import datetime
import flask
import safe_backend
import psycopg2
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
    if vehicle_id in safe_backend.api.config.VEHICLE_QUEUES:
        context = {
            "msg": f"Vehicle {vehicle_id} is already logged in"
        }
        return flask.jsonify(**context), 400

    # Check vehicle is registered and in database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()
    cur.execute("SELECT * FROM vehicles WHERE vehicle_name = %s;", (vehicle_id, ))
    vehicle = cur.fetchone()
    if vehicle is None:
        context = {
            "msg": f"Vehicle {vehicle_id} is not registered in this agency"
        }
        return flask.jsonify(**context), 404

    # Query database for vehicle capacity and range
    capacity = vehicle[2]
    range = vehicle[3]

    # Get location from login request
    lat = flask.request.json["latitude"]
    log = flask.request.json["longitude"]
    
    # Create vehicle
    new_vehicle = safe_backend.api.vehicles.Vehicle(vehicle_id=vehicle_id, status="active",capacity=capacity, range=range, latin=lat, longin=log)

    # Add vehicle to mappings
    safe_backend.api.config.VEHICLE_QUEUES[vehicle_id] = new_vehicle

    # Since vehicles are empty on logins, call the assign_rides() if there are active rides
    if len(safe_backend.api.config.RIDE_REQUESTS) != 0:
        safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].assign_rides()

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


@safe_backend.app.route("/api/v1/vehicles/logout/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as logged out
# MODIFIES  - VEHICLE_QUEUES
def logout_vehicle():
    """Marks <vehicle_id> as logged out."""
    # TODO: Authentication

    # If vehicle is not active, return a 404
    vehicle_id = flask.request.json["vehicle_id"]
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
    """Return all active vehicles."""
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
                "passenger": ride_request.firstName + " " + ride_request.lastName,
                "driver": ride_request.driver,
                "pickup": ride_request.pickupName,
                "dropoff": ride_request.dropoffName,
                "ETA": ride_request.eta,
                "ETP": ride_request.etp,
                "reqid": ride_request.request_id,
                "isPickup": ride_request.isPickup
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


@safe_backend.app.route("/api/v1/vehicles/load_unload/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - If load, mark <ride_id> as onboard <vehicle_id> and reduce capacity
#           - If unload, mark <ride_id> as offboarded from <vehicle_id> and increase capacity
#           - If vehicle is empty after unloading, let vehicle get active rides into queue
# MODIFIES  - VEHICLE_QUEUES, RIDE_REQUESTS
def load_unload():
    """Onboard <ride_id> to this vehicle."""
    # TODO: Authentication

    # Get ride_id, vehicle_id and request type from the request json
    ride_id = flask.request.json["ride_id"]
    vehicle_id = flask.request.json["vehicle_id"]
    type = flask.request.json["type"]

    # Check that vehicle_id is logged in, and ride_id is an active ride
    if vehicle_id not in safe_backend.api.config.VEHICLE_QUEUES or ride_id not in safe_backend.api.config.RIDE_REQUESTS:
        context = {
            "msg": f"Vehicle {vehicle_id} or ride-request {ride_id} not found!"
        }
        return flask.jsonify(**context), 404

    # If boarding,
    if type == "boarding":
        # Update ride_id's status
        safe_backend.api.config.RIDE_REQUESTS[ride_id].status = "onboard"

        # Update vehicle_id capacity and itinerary
        safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].capacity -= safe_backend.api.config.RIDE_REQUESTS[ride_id].numpass
        safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].queue.pop(0)

        # Return success
        context = {
            "msg": f"Sucessfully onboarded {ride_id} to {vehicle_id}!"
        }
        return flask.jsonify(**context), 200

    # If unloading,
    elif type == "unloading":
        # Update ride_id's status
        safe_backend.api.config.RIDE_REQUESTS[ride_id].status = "complete"

        # Update vehicle_id capacity and itinerary
        safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].capacity += safe_backend.api.config.RIDE_REQUESTS[ride_id].numpass
        safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].queue.pop(0)
        del safe_backend.api.config.RIDE_REQUESTS[ride_id]

        # If empty, get more rides assigned
        if safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].capacity == safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].maxcapacity:
            safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].assign_rides()

        # Return success
        context = {
            "msg": f"Sucessfully offboarded {ride_id} from {vehicle_id}!"
        }
        return flask.jsonify(**context), 200

    else:
        context = {
            "msg": f"Command not recognized!"
        }
        return flask.jsonify(**context), 400
