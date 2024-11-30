"""REST API for ride requests."""
import datetime
import flask
import psycopg2
import safe_backend
import safe_backend.api.vehicles
import safe_backend.api.config as global_vars
from safe_backend.api.utils import assign_rides


# Routes
@safe_backend.app.route("/api/v1/vehicles/login/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as able to receive requests
# MODIFIES  - VEHICLES
def login_vehicle():
    """Marks <vehicle_id> as ready to receive requests."""
    # TODO: Authentication -  must have agency or driver level permissions

    # Check vehicle is not already logged in
    vehicle_id = flask.request.json["vehicle_id"]
    if vehicle_id in global_vars.VEHICLES:
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
    vehicle_range = vehicle[3]

    # Get location from login request
    lat = flask.request.json["latitude"]
    log = flask.request.json["longitude"]

    # Create vehicle
    new_vehicle = safe_backend.api.vehicles.Vehicle(vehicle_id=vehicle_id, status="active",
        capacity=capacity, vrange=vehicle_range, latin=lat, longin=log)

    # Add vehicle to mappings
    global_vars.VEHICLES[vehicle_id] = new_vehicle

    # Since vehicles are empty on logins, call the assign_rides() if there are active rides
    if len(global_vars.REQUESTS) != 0:
        assign_rides()

    # Return success
    context = {
        "msg": f"Successfully logged in vehicle: {vehicle_id}",
        "vehicle_id": vehicle_id  # Add vehicle_id to context
    }

    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/vehicles/pause/<vehicle_id>/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as not receiving ride requests
# MODIFIES  - VEHICLES
def pause_vehicle(vehicle_id):
    """Marks <vehicle_id> as not receiving requests."""
    # TODO: Authentication

    # If vehicle is not active, return a 404
    if vehicle_id not in global_vars.VEHICLES:
        context = {
            "msg": "Vehicle " + vehicle_id + " is not active."
        }
        return flask.jsonify(**context), 404

    # Grab vehicle from mapping and change its status
    global_vars.VEHICLES[vehicle_id].status = "paused"

    # Return success
    context = {
        "msg": "Successfully paused vehicle: " + vehicle_id
    }

    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/vehicles/logout/<vehicle_id>/", methods=["POST"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Marks <vehicle_id> as logged out
# MODIFIES  - VEHICLES
def logout_vehicle(vehicle_id):
    """Marks <vehicle_id> as logged out."""
    # TODO: Authentication

    # If vehicle is not active, return a 404
    if vehicle_id not in global_vars.VEHICLES:
        context = {
            "msg": "Vehicle " + vehicle_id + " is not active."
        }
        return flask.jsonify(**context), 404

    # Grab vehicle from mapping and remove it
    for ride_request in global_vars.VEHICLES[vehicle_id].itinerary:
        ride_request.status = "Requested"
        ride_request.driver = "Pending Assignment"
    del global_vars.VEHICLES[vehicle_id]

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
    for vehicle_id in global_vars.VEHICLES.items():
        context[vehicle_id] = {
            "vehicle_id": vehicle_id,
            "lat": global_vars.VEHICLES[vehicle_id].lat,
            "long": global_vars.VEHICLES[vehicle_id].log,
            "queue_url": "/api/v1/rides/drivers/" + vehicle_id + "/",
            "itinerary": []
        }
        for ride_request in global_vars.VEHICLES[vehicle_id].itinerary:
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
    if vehicle_id not in global_vars.VEHICLES:
        context = {
            "msg": "Vehicle not logged in."
        }
        return flask.jsonify(**context), 404

    global_vars.VEHICLES[vehicle_id].lat = flask.request.json["latitude"]
    global_vars.VEHICLES[vehicle_id].log = flask.request.json["longitude"]

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
# MODIFIES  - VEHICLES, REQUESTS
def load_unload():
    """Onboard <ride_id> to this vehicle."""
    # TODO: Authentication

    # Get ride_id, vehicle_id and request type from the request json
    ride_id = flask.request.json["ride_id"]
    vehicle_id = flask.request.json["vehicle_id"]
    req_type = flask.request.json["type"]

    # Check that vehicle_id is logged in, and ride_id is an active ride
    if (vehicle_id not in global_vars.VEHICLES or
            ride_id not in global_vars.REQUESTS):
        context = {
            "msg": f"Vehicle {vehicle_id} or ride-request {ride_id} not found!"
        }
        return flask.jsonify(**context), 404

    # If boarding,
    if req_type == "boarding":
        # Update ride_id's status
        global_vars.REQUESTS[ride_id].status = "In-Progress"

        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
        cur = conn.cursor()
        cur.execute(
            "UPDATE REQUESTS SET pickup_time = %s WHERE ride_id = %s;",
            (datetime.datetime.now() ,global_vars.REQUESTS[ride_id].request_id,)
        )
        conn.commit()
        cur.close()
        conn.close()

        # Update vehicle_id capacity and itinerary
        global_vars.VEHICLES[vehicle_id].capacity -= global_vars.REQUESTS[ride_id].numpass
        global_vars.VEHICLES[vehicle_id].itinerary = [
            ride for ride in global_vars.VEHICLES[vehicle_id].itinerary
            if (ride.request_id != ride_id and not ride.isPickup)
        ]

        # Return success
        context = {
            "msg": f"Sucessfully onboarded {ride_id} to {vehicle_id}!"
        }
        return flask.jsonify(**context), 200

    # If unloading,
    if req_type == "unloading":
        # Update ride_id's status
        global_vars.REQUESTS[ride_id].status = "Completed"

        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
        cur = conn.cursor()
        cur.execute(
            "UPDATE REQUESTS SET status = %s, dropoff_time = %s WHERE ride_id = %s;",
            ("Complete",datetime.datetime.now() ,global_vars.REQUESTS[ride_id].request_id, )
        )
        conn.commit()
        cur.close()
        conn.close()

        # Update vehicle_id capacity and itinerary
        global_vars.VEHICLES[vehicle_id].capacity += global_vars.REQUESTS[ride_id].numpass
        global_vars.VEHICLES[vehicle_id].itinerary = [
            ride for ride in global_vars.VEHICLES[vehicle_id].itinerary
            if ride.request_id != ride_id
        ]
        del global_vars.REQUESTS[ride_id]

        # Return success
        context = {
            "msg": f"Sucessfully offboarded {ride_id} from {vehicle_id}!"
        }
        return flask.jsonify(**context), 200

    context = {
        "msg": "Command not recognized!"
    }
    return flask.jsonify(**context), 400
