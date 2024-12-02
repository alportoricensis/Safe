"""REST API for ride requests."""
import datetime
import flask
import psycopg2
import safe_backend
from safe_backend.api.utils import calc_distance
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
    capacity = vehicle[1]
    vehicle_range = vehicle[2]

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
                "passenger": ride_request.first_name + " " + ride_request.last_name,
                "driver": ride_request.driver,
                "pickup": ride_request.pickup_name,
                "dropoff": ride_request.dropoff_name,
                "ETA": ride_request.eta,
                "ETP": ride_request.etp,
                "reqid": ride_request.request_id,
                "isPickup": ride_request.is_pickup
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

    old_loc = (global_vars.VEHICLES[vehicle_id].lat, global_vars.VEHICLES[vehicle_id].log)
    new_loc = (flask.request.json["latitude"], flask.request.json["longitude"])
    global_vars.VEHICLES[vehicle_id].lat = new_loc[0]
    global_vars.VEHICLES[vehicle_id].log = new_loc[1]
    global_vars.VEHICLES[vehicle_id].miles_travelled += calc_distance(old_loc, new_loc)

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
            "UPDATE ride_requests SET pickup_time = %s WHERE ride_id = %s;",
            (datetime.datetime.now() ,global_vars.REQUESTS[ride_id].request_id,)
        )
        conn.commit()
        cur.close()
        conn.close()

        # Update vehicle_id capacity and itinerary
        global_vars.VEHICLES[vehicle_id].capacity -= global_vars.REQUESTS[ride_id].numpass
        global_vars.VEHICLES[vehicle_id].itinerary = [
            ride for ride in global_vars.VEHICLES[vehicle_id].itinerary
            if (ride.request_id != ride_id and not ride.is_pickup)
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
            "UPDATE ride_requests SET status = %s, dropoff_time = %s WHERE ride_id = %s;",
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


@safe_backend.app.route("/api/v1/vehicles/statistics/", methods=["GET"])
# REQUIRES  - User is authenticated with driver-level permissions
# EFFECTS   - Get the usage statistics for this vehicle 
# MODIFIES  - Nothing
def get_statistics():
    """Return usage statistics for a vehicle."""
    # TODO: Authentication

    # Get vehicle_id from the request
    vehicle_id = flask.request.json["vehicle_id"]

    # Get the start time and end time for the usage statistics
    start_time = datetime.datetime.fromtimestamp(flask.request.json["start_time"])
    end_time = datetime.datetime.fromtimestamp(flask.request.json["end_time"])

    # Check that the vehicle has been logged in
    if vehicle_id not in global_vars.VEHICLES:
        return flask.jsonify(**{"msg": f"Vehicle {vehicle_id} not logged in."}), 404

    # Query the database for all rides completed in this timeframe
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
    cur = conn.cursor()
    cur.execute(
        "SELECT * FROM ride_requests \
        WHERE vehicle_name = %s AND pickup_time > %s AND dropoff_time < %s",
        (vehicle_id, start_time, end_time,)
    )
    context = {"rides": []}
    sel = cur.fetchall()
    num_passengers = 0
    if sel is not None:
        for ride in sel:
            context["rides"].append({
                "pickupLat": ride[1],
                "pickupLong": ride[2],
                "dropoffLat": ride[3],
                "dropoffLong": ride[4],
                "pickupTime": ride[8],
                "dropoffTime": ride[9],
                "serviceName": ride[10],
            })
            num_passengers += 1
    context["numPassengers"] = num_passengers
    context["milesTravelled"] = global_vars.VEHICLES[vehicle_id].miles_travelled
    cur.close()
    conn.close()
    return flask.jsonify(**context), 200
