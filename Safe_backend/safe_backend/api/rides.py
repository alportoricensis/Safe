"""REST API for ride requests."""
import datetime
import flask
import psycopg2
import safe_backend.config
import safe_backend.api.config as global_vars
from safe_backend.api.requests import RideRequests
from safe_backend.api.utils import check_time, check_dropoff, assign_rides, book_passenger

# Routes
@safe_backend.app.route("/api/v1/rides/", methods=["GET", "OPTIONS"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Returns all currently active ride requests
# MODIFIES  - Nothing
def get_rides():
    """Return all currently active ride requests."""
    context = {}
    for key, value in global_vars.REQUESTS.items():
        context[key] = {
            "passenger": value.first_name + " " + value.last_name,
            "driver": value.driver,
            "pickup": value.pickup_name,
            "dropoff": value.dropoff_name,
            "phone": value.phone,
            "status": value.status,
            "ETA": value.eta,
            "ETP": value.etp,
            "reqid": value.request_id,
            "numPassengers": value.numpass
        }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/passengers/<ride_id>/", methods=["GET"])
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
    """Return the details for ride_id."""
    # Check if ride_id is a currently active one
    if ride_id not in global_vars.REQUESTS:
        context = {
            "msg": "ride_id is not an active ride."
        }
        return flask.jsonify(**context), 404
    passenger_name = f"{global_vars.REQUESTS[ride_id].first_name} \
        {global_vars.REQUESTS[ride_id].last_name}"
    context = {}
    context[ride_id] = {
        "passenger": passenger_name,
        "driver": global_vars.REQUESTS[ride_id].driver,
        "pickup": global_vars.REQUESTS[ride_id].pickup_name,
        "dropoff": global_vars.REQUESTS[ride_id].dropoff_name,
        "ETA": global_vars.REQUESTS[ride_id].eta,
        "ETP": global_vars.REQUESTS[ride_id].etp,
        "reqid": ride_id
    }
    if global_vars.REQUESTS[ride_id].driver != "Pending Assignment":
        context[ride_id]["driverLat"] = global_vars.VEHICLES[
            global_vars.REQUESTS[ride_id].driver
        ].lat
        context[ride_id]["driverLong"] = global_vars.VEHICLES[
            global_vars.REQUESTS[ride_id].driver
        ].log
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/drivers/<vehicle_id>/", methods=["GET"])
# REQUIRES  - User is authenticated with driver-level permissions
#             vehicle_id is a valid vehicle
# EFFECTS   - Returns the queue for driver with vehicle_id
# MODIFIES  - Nothing
def get_driver_rides(vehicle_id):
    """Return the queue for driver with driver_id."""
    # If vehicle_id is not currently receiving rides, return a 404
    if vehicle_id not in global_vars.VEHICLES:
        context = {
            "msg": "Vehicle not found in active queues. Is the vehicle logged in?"
        }
        return flask.jsonify(**context), 404

    # If vehicle_id is receiving rides, return its current active queue
    context = {}
    context["rideOrder"] = []
    for label in global_vars.VEHICLES[vehicle_id].queue:
        context["rideOrder"].append(label)
    for ride_request in global_vars.VEHICLES[vehicle_id].itinerary:
        context[str(ride_request.request_id)] = {
            "passenger": ride_request.first_name + " " + ride_request.last_name,
            "driver": ride_request.driver,
            "pickup": ride_request.pickup_name,
            "pickupLatitude": ride_request.pickup_coord[0],
            "pickupLongitude": ride_request.pickup_coord[1],
            "dropoffLatitude": ride_request.dropoff_coord[0],
            "dropoffLongitude": ride_request.dropoff_coord[1],
            "dropoff": ride_request.dropoff_name,
            "ETA": ride_request.eta,
            "ETP": ride_request.etp,
            "reqid": ride_request.request_id
        }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/passengers/<ride_id>/", methods=["DELETE"])
# REQUIRES  - User is authenticated with passenger, driver, or dispatcher level permissions
#             If passenger, ride_id MUST have been booked by the currently authenticated user
# EFFECTS   - Deletes this RideRequest from the active ones, and mark as Cancelled on the database
# MODIFIES  - VEHICLES, REQUESTS
def delete_ride_request(ride_id):
    """Delete the ride request with ride_id."""
    # Check if ride_id is a currently active ride_request
    if ride_id not in global_vars.REQUESTS:
        context = {
            "msg": "Ride not found in active queues. Is the ride active?"
        }
        return flask.jsonify(**context), 404

    # If the ride is active, check what driver it has been assigned to, and remove it
    # from that drivers queue
    driver_id = global_vars.REQUESTS[ride_id].driver
    if driver_id != "Pending Assignment":
        # Find the specific driver, and remove this passenger request from the driver's list
        global_vars.VEHICLES[driver_id].itinerary = [
            ride for ride in global_vars.VEHICLES[driver_id].itinerary
            if ride.request_id != ride_id
        ]

    # Remove from the passenger requests
    del global_vars.REQUESTS[ride_id]

    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
    cur = conn.cursor()
    cur.execute("UPDATE REQUESTS SET status = %s WHERE ride_id = %s;", ("Cancelled", ride_id, ))
    conn.commit()
    cur.close()
    conn.close()

    context = {
        "msg": "Successfully deleted ride_id: " + ride_id
    }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/", methods=["POST"])
# REQUIRES - flask.request.args.user_id is a valid user_id and is currently authenticated
#            flask.request.args.pickup is a valid pickup location
#            flask.request.args.dropoff is a valid dropoff location
# EFFECTS  - Creates a RideRequest for user_id, and triggers a recalculation of driver itineraries
# MODIFIES - VEHICLES, REQUESTS
def post_ride():
    """Add a RideRequest to the ride-share service."""
    ride_origin = ""
    service_name = ""
    pickup = ""
    dropoff_name = ""
    dropoff_coord = (0.0, 0.0)
    if "rideOrigin" in flask.request.form:
        ride_origin = flask.request.form["rideOrigin"]
        service_name = flask.request.form["serviceName"]
        pickup = flask.request.form["pickupLocation"]
        dropoff_name = flask.request.form["dropoffLocation"]
        dropoff_coord = (flask.request.form["dropoffLat"], flask.request.form["dropoffLong"])
    else:
        ride_origin = flask.request.json["rideOrigin"]
        service_name = flask.request.json["serviceName"]
        pickup = flask.request.json["pickupLocation"]
        dropoff_name = flask.request.json["dropoffLocation"]
        dropoff_coord = (flask.request.json["dropoffLat"], flask.request.json["dropoffLong"])

    # Three options exist for booking a ride: through a call-in (dispatcher), through a
    # walk-on (driver), or through the passenger app. These follow slightly different paths.

    # Check the service the user is booking for, and the service times
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()
    cur.execute("SELECT * FROM services WHERE service_name = %s;", (service_name, ))
    services = cur.fetchall()

    # If service is not valid,
    if services is None:
        context = {
            "msg": f"Service {service_name} not found!"
        }
        return flask.jsonify(**context), 404

    # If the current time is not in the service's time range, do not allow the booking
    curr_time = datetime.datetime.now().time()
    start_time = services[0][1]
    end_time = services[0][2]
    if not check_time(start_time, end_time, curr_time):
        context = {
            "msg": f"Service {service_name} is not currently active."
        }
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 400

    # Check the pickup and dropoff validity
    cur.execute("SELECT * FROM locations WHERE loc_name = %s", (pickup, ))
    location = cur.fetchone()
    req_id = -1
    if location is None:
        context = {
            "msg": f"Service {service_name} does not service {location}."
        }
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 400

    if not check_dropoff(dropoff_name, dropoff_coord):
        context = {
            "msg": f"Service {service_name} does not service {dropoff_name}."
        }
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 400

    if ride_origin == "callIn":
        # Insert the booking into the database, and retrieve their ID
        first_name = flask.request.form["passengerFirstName"]
        last_name = flask.request.form["passengerLastName"]
        phone = flask.request.form["passengerPhoneNumber"]
        num_passengers = flask.request.form["numPassengers"]
        request_time = datetime.datetime.now()

        cur.execute(
            "INSERT INTO ride_requests (pickup_lat, pickup_long, dropoff_lat, dropoff_long, status, \
            request_time, service_name) VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING ride_id",
            (location[2], location[3], dropoff_coord[0], dropoff_coord[1], "requested",
             request_time, services[0][0])
        )
        req_id = cur.fetchone()

        # Create ride request object
        rider_id = -1
        new_request = RideRequests(
            rider_id=rider_id, status="Requested", vehicle_id="Pending Assignment",
            pickup_name=pickup, pickup_coord=(location[2], location[3]),
            dropoff_coord=dropoff_coord, request_time=str(request_time), phone=phone,
            first_name=first_name, last_name=last_name, request_id=str(req_id[0]),
            numpass=num_passengers, dropoff_name=dropoff_name
        )

    # If the ride came from a passenger app,
    elif ride_origin == "passenger":
        user_uid = flask.request.json["uuid"]
        num_passengers = flask.request.json["numPassengers"]
        request_time = datetime.datetime.now()

        # Check the user has been logged in/exists
        cur.execute("SELECT * FROM users WHERE uuid = %s", (user_uid, ))
        sel = cur.fetchone()
        if sel is None:
            return flask.jsonify(**{"msg":"Unknown UUID"}), 404
        first_name = sel[1].split(" ")[0]
        last_name = sel[1].split(" ")[1]
        phone = sel[3]

        cur.execute(
            "INSERT INTO ride_requests (pickup_lat, pickup_long, dropoff_lat, dropoff_long, status, \
            request_time, service_name, user_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s) \
            RETURNING ride_id",
            (location[2], location[3], dropoff_coord[0], dropoff_coord[1], "requested",
                request_time, services[0][0], user_uid)
        )
        req_id = cur.fetchone()

        new_request = RideRequests(
            rider_id = user_uid,
            status = "Requested",
            vehicle_id = "Pending Assignment",
            pickup_name=pickup,
            pickup_coord=(location[2], location[3]),
            dropoff_coord=dropoff_coord,
            phone=phone,
            first_name=first_name,
            last_name=last_name,
            request_id=str(req_id[0]),
            request_time=str(request_time),
            numpass=num_passengers,
            dropoff_name=dropoff_name
        )
    elif ride_origin == "future":
        user_uid = flask.request.json["uuid"]
        num_passengers = flask.request.json["numPassengers"]
        req_time = datetime.datetime.fromtimestamp(flask.request.json["requestedTime"])
        minute = req_time.minute
        hour = req_time.hour
        day = req_time.day
        month = req_time.month
        cur.execute("SELECT * FROM users WHERE uuid = %s", (user_uid, ))
        sel = cur.fetchone()
        if sel is None:
            return flask.jsonify(**{"msg": "Unknown UUID."}), 404
        first_name = sel[1].split(" ")[0]
        last_name = sel[1].split(" ")[1]
        request_time = datetime.datetime.now()
        phone = sel[3]
        cur.execute(
            "INSERT INTO ride_requests (pickup_lat, pickup_long, dropoff_lat, dropoff_long, status, \
            request_time, service_name, user_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s) \
            RETURNING ride_id",
            (location[2], location[3], dropoff_coord[0], dropoff_coord[1], "scheduled",
                request_time, services[0][0], user_uid)
        )
        req_id = cur.fetchone()
        global_vars.scheduler.add_job(
            book_passenger,
            'cron',
            minute=minute,
            hour=hour,
            day=day,
            month=month,
            args=[first_name, last_name, phone, user_uid, pickup, location, req_id,
                  num_passengers, dropoff_coord, dropoff_name],
            id=f"ride_{req_id}"
        )
        context = {
            "msg": "Successfully scheduled ride."
        }
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 200
    else:
        context = {
            "msg": "Unrecognized rideOrigin"
        }
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 400

    # Add to mappings
    global_vars.REQUESTS[str(req_id[0])] = new_request

    # If there is a vehicle with no active rides, call its assignment function
    if global_vars.VEHICLES:
        assign_rides()

    # Return success
    conn.commit()
    cur.close()
    conn.close()
    context = {
        "msg": "Successfully created booking!",
        "ride_id": req_id
    }
    return flask.jsonify(**context), 200
