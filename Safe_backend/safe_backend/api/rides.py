"""REST API for ride requests."""
import datetime
import flask
import random
import safe_backend.api.config
import safe_backend.api.requests

# Routes
@safe_backend.app.route("/api/v1/rides/", methods=["GET"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Returns all currently active ride requests
# MODIFIES  - Nothing
def get_rides():
    """Return all currently active ride requests."""
    # TODO: Authentication
    context = {}
    for key, value in safe_backend.api.config.RIDE_REQUESTS.items():
        context[key] = {
            "passenger": value.passenger_name,
            "driver": value.driver,
            "pickup": value.pickup,
            "dropoff": value.dropoff,
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
            "pickup": ride_request.pickup,
            "dropoff": ride_request.dropoff,
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
        "pickup": safe_backend.api.config.RIDE_REQUESTS[ride_id].pickup,
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
    if driver_id != str(-1):
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
    # TODO: Authentication - can be either flask.request.args.user_id or an agency-level account

    # TODO: Check pickup validity

    # TODO: Check dropoff validity

    # TODO: Create object
    # Proper
    # rider_id = flask.request.args.user_id
    # request_id comes from the rownum of the database
    pickup = flask.request.form["pickup"]
    dropoff = flask.request.form["dropoff"]
    passenger_name = flask.request.form["passenger_name"]

    # Debug
    rider_id = random.randint(0, 100)
    request_id = random.randint(0, 100)
    #pickup = "EECS"
    #dropoff = "1687 Broadway St"
    #passenger_name = "Alexander Gabriel Nunez-Carrasquillo"
    passenger = safe_backend.api.requests.RideRequests(
        rider_id=rider_id, request_id=request_id, vehicle_id=-1,
        pickup=pickup, dropoff=dropoff, passname=passenger_name,
        status="requested"
    )
    
    if safe_backend.api.config.MODE == "ROUNDROBIN":
        safe_backend.api.config.ROUND_ROBIN_QUEUE[0].itinerary.append(passenger)
        safe_backend.api.config.ROUND_ROBIN_QUEUE.append(safe_backend.api.config.ROUND_ROBIN_QUEUE[0])
        safe_backend.api.config.ROUND_ROBIN_QUEUE.pop()
        safe_backend.api.config.RIDE_REQUESTS[str(request_id)] = passenger

    elif safe_backend.api.config.MODE == "GOOGLEMAPSROUTING":
        # TODO: Trigger recalculation
        safe_backend.api.config.RIDE_REQUESTS[str(request_id)] = passenger

    # TODO: Return proper status

    return flask.redirect(url)