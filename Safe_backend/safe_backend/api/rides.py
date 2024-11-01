"""REST API for ride requests."""
import datetime
import random
import flask
import psycopg2
import safe_backend.config
import safe_backend.api.config
from safe_backend.api.requests import RideRequests
from safe_backend.api.utils import check_pickup, check_time, check_dropoff

# Routes
@safe_backend.app.route("/api/v1/rides/", methods=["GET", "OPTIONS"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Returns all currently active ride requests
# MODIFIES  - Nothing
def get_rides():
    """Return all currently active ride requests."""
    # TODO: Authentication
    context = {}
    for key, value in safe_backend.api.config.RIDE_REQUESTS.items():
        context[key] = {
            "passenger": value.firstName + " " + value.lastName,
            "driver": value.driver,
            "pickup": value.pickupName,
            "dropoff": value.dropoffName,
            "ETA": value.eta,
            "ETP": value.etp,
            "reqid": value.request_id
        }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/drivers/<vehicle_id>/", methods=["GET"])
# REQUIRES  - User is authenticated with driver-level permissions
#             vehicle_id is a valid vehicle
# EFFECTS   - Returns the queue for driver with vehicle_id
# MODIFIES  - Nothing
def get_driver_rides(vehicle_id):
    """Return the queue for driver with driver_id."""
    # TODO: Authentication

    # If vehicle_id is not currently receiving rides, return a 404
    if vehicle_id not in safe_backend.api.config.VEHICLE_QUEUES:
        context = {
            "msg": "Vehicle not found in active queues. Is the vehicle logged in?"
        }
        return flask.jsonify(**context), 404

    # If vehicle_id is receiving rides, return its current active queue
    context = {}
    for ride_request in safe_backend.api.config.VEHICLE_QUEUES[vehicle_id].itinerary:
        context[str(ride_request.request_id)] = {
            "passenger": ride_request.passenger_name,
            "driver": ride_request.driver,
            "pickup": ride_request.pickupName,
            "dropoff": ride_request.dropoffName,
            "ETA": ride_request.eta,
            "ETP": ride_request.etp,
            "reqid": ride_request.request_id
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
    # TODO: Authentication

    # Check if ride_id is a currently active one
    if ride_id not in safe_backend.api.config.RIDE_REQUESTS:
        context = {
            "msg": "ride_id is not an active ride."
        }
        return flask.jsonify(**context), 404

    context = {}
    context[ride_id] = {
        "passenger": safe_backend.api.config.RIDE_REQUESTS[ride_id].passenger_name,
        "driver": safe_backend.api.config.RIDE_REQUESTS[ride_id].driver,
        "pickup": safe_backend.api.config.RIDE_REQUESTS[ride_id].pickupName,
        "dropoff": safe_backend.api.config.RIDE_REQUESTS[ride_id].dropoff,
        "ETA": safe_backend.api.config.RIDE_REQUESTS[ride_id].eta,
        "ETP": safe_backend.api.config.RIDE_REQUESTS[ride_id].etp,
        "reqid": ride_id
    }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/passengers/<ride_id>/", methods=["DELETE"])
# REQUIRES  - User is authenticated with passenger, driver, or dispatcher level permissions
#             If passenger, ride_id MUST have been booked by the currently authenticated user
# EFFECTS   - Deletes this RideRequest from the active ones, and mark as Cancelled on the database
# MODIFIES  - VEHICLE_QUEUES, RIDE_REQUESTS
def delete_ride_request(ride_id):
    """Delete the ride request with ride_id."""
    # TODO: Authentication

    # Check if ride_id is a currently active ride_request
    if ride_id not in safe_backend.api.config.RIDE_REQUESTS:
        context = {
            "msg": "Ride not found in active queues. Is the ride active?"
        }
        return flask.jsonify(**context), 404
    
    # If the ride is active, check what driver it has been assigned to, and remove it
    # from that drivers queue
    driver_id = str(safe_backend.api.config.RIDE_REQUESTS[ride_id].driver)
    if driver_id != "Pending Assignment":
        # Find the specific driver, and remove this passenger request from the driver's list
        safe_backend.api.config.VEHICLE_QUEUES[driver_id].itinerary.remove(safe_backend.api.config.RIDE_REQUESTS[ride_id])

    # Remove from the passenger requests
    del safe_backend.api.config.RIDE_REQUESTS[ride_id]

    # TODO: Mark as incomplete on database

    context = {
        "msg": "Successfully deleted ride_id: " + ride_id
    }
    return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/rides/", methods=["POST"])
# REQUIRES - flask.request.args.user_id is a valid user_id and is currently authenticated
#            flask.request.args.pickup is a valid pickup location
#            flask.request.args.dropoff is a valid dropoff location
# EFFECTS  - Creates a RideRequest for user_id, and triggers a recalculation of driver itineraries
# MODIFIES - VEHICLE_QUEUES, RIDE_REQUESTS
def post_ride():
    """Add a RideRequest to the ride-share service."""
    url = flask.request.args.get('target')
    rideOrigin = flask.request.form["rideOrigin"]

    # Three options exist for booking a ride: through a call-in (dispatcher), through a walk-on (driver),
    # or through the passenger app. These follow slightly different paths.

    # TODO: Authentication - can be either flask.request.args.user_id or an agency-level account

    if rideOrigin == "callIn":
        # Check the service the user is booking for, and the service times
        serviceName = flask.request.form["services"]
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM services WHERE service_name = %s;", (serviceName, ))
        services = cur.fetchall()

        # If service is not valid,
        if services is None:
            context = {
                "msg": f"Service {serviceName} not found!"
            }
            return flask.jsonify(**context), 404

        # If the current time is not in the service's time range, do not allow the booking
        currTime = datetime.datetime.now().time()
        startTime = services[0][2]
        endTime = services[0][3]
        if not check_time(startTime, endTime, currTime):
            context = {
                "msg": f"Service {serviceName} is not currently active."
            }
            return flask.jsonify(**context), 400
        
        # Check the pickup and dropoff validity
        pickup = flask.request.form["pickupLocation"]
        dropoffName = flask.request.form["dropoffLocation"]
        dropoffCoord = (flask.request.form["dropoffLat"], flask.request.form["dropoffLong"])
        cur.execute("SELECT * FROM locations WHERE loc_name = %s", (pickup, ))
        location = cur.fetchone()
        if location is None:
            context = {
                "msg": f"Service {serviceName} does not service {location}."
            }
            return flask.jsonify(**context), 400

        if not check_dropoff(dropoffName, dropoffCoord):
            context = {
                "msg": f"Service {serviceName} does not service {dropoffName}."
            }
            return flask.jsonify(**context), 400
        
        # Insert the booking into the database, and retrieve their ID
        firstName = flask.request.form["passengerFirstName"]
        lastName = flask.request.form["passengerLastName"]
        phone = flask.request.form["passengerPhoneNumber"]
        numPass = flask.request.form["numPassengers"]

        # TODO - database integration
        cur.execute(
            "INSERT INTO ride_requests (pickup_lat, pickup_long, dropoff_lat, dropoff_long, status, service_id) VALUES \
                (%s, %s, %s, %s, %s, %s) RETURNING ride_id", (location[2], location[3], dropoffCoord[0], dropoffCoord[1], "requested",
                                            services[0][0])
        )
        req_id = cur.fetchone()

        # Create ride request object
        rider_id = -1
        newRequest = RideRequests(
            rider_id=rider_id, status="requested", vehicle_id="Pending Assignment", pickupName=pickup, pickupCoord=(location[2], location[3]),
            dropoff=dropoffCoord, phone=phone, firstName=firstName, lastName=lastName, request_id=req_id[0], numpass=numPass, dropoffName=dropoffName
        )

        # Add to mappings
        safe_backend.api.config.RIDE_REQUESTS[str(req_id[0])] = newRequest

        # If there is a vehicle with no active rides, call its assignment function
        for vehicle in safe_backend.api.config.VEHICLE_QUEUES:
            if safe_backend.api.config.VEHICLE_QUEUES[vehicle].empty():
                safe_backend.api.config.VEHICLE_QUEUES[vehicle].assign_rides()

        # Return success
        context = {
            "msg": "Successfully created booking!"
        }
        flask.flash(f"Successfully booked passenger! {firstName} {lastName}")
        return flask.jsonify(**context), 200
    
    # If the ride came from a passenger app,
    elif rideOrigin == "passenger":

        return flask.redirect(url)

    elif rideOrigin == "walkOn":

        return flask.redirect(url)

    else:

        return flask.redirect(url)
        