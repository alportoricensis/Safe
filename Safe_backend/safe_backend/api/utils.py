"""Helper functions for REST API for ride requests."""
import datetime
import psycopg2
import flask
from geopy import distance as dist
from google.maps import routeoptimization_v1
import safe_backend.api.config as global_vars
from safe_backend.api.requests import RideRequests


# REQUIRES  -
# EFFECTS   -
# MODIFIES  -
def check_pickup(location_name = "", coordinates = (0.0, 0.0)) -> bool:
    """Check that name or coordinates is a valid pickup location."""
    # Connect to database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()

    # Check ranges first
    cur.execute("SELECT * FROM ranges WHERE isPickup = True")
    ranges = cur.fetchall()
    for range_center in ranges:
        if (calc_distance(location = coordinates, center = (range_center[1], range_center[2]))
            < range_center[3]):
            return True

    # Check locations second
    cur.execute("SELECT * FROM locations WHERE loc_name = %s", (location_name,))
    locations = cur.fetchall()
    if len(locations) != 0 and locations[4]:
        return True

    return False


# REQUIRES  -
# EFFECTS   -
# MODIFIES  -
def check_dropoff(location_name = "", coordinates = (0.0, 0.0)) -> bool:
    """Check that name or coordinates is a valid pickup location."""
    # Connect to database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()

    # Check ranges first
    cur.execute("SELECT * FROM ranges WHERE isDropoff = True")
    ranges = cur.fetchall()
    for range_center in ranges:
        if (calc_distance(location = coordinates, center = (range_center[1], range_center[2]))
            < range_center[3]):
            return True

    # Check locations second
    cur.execute("SELECT * FROM locations WHERE loc_name = %s", (location_name,))
    locations = cur.fetchall()
    if len(locations) != 0 and locations[5]:
        return True

    return False


# REQUIRES  -
# EFFECTS   -
# MODIFIES  -
def check_time(start_time, end_time, current_time) -> bool:
    """Verify currentTime is within start and end; return false otherwise."""
    if start_time < end_time:
        return start_time <= current_time <= end_time
    return start_time <= current_time or current_time <= end_time


# REQUIRES  -
# EFFECTS   -
# MODIFIES  -
def calc_distance(location, center) -> float:
    """Calculate distance between location and center."""
    return dist.distance(location, center).miles


# REQUIRES  -
# EFFECTS   -
# MODIFIES  -
def assign_rides():
    """Assign rides to vehicles."""
    # Create the shipment model
    shipment_model = bookings_to_model()

    # Instantiate the client to send and receive the request
    client = routeoptimization_v1.RouteOptimizationClient()

    # Initialize the arguments
    request = routeoptimization_v1.OptimizeToursRequest()
    request.model = shipment_model
    request.parent = "projects/eecs-441-safe"

    # Send and retrieve the request
    response = client.optimize_tours(
        request = request
    )

    # Transform the response into a queue, and update self's itinerary
    for vehicle in global_vars.VEHICLES:
        global_vars.VEHICLES[vehicle].response_to_queue(response)


# REQUIRES
# EFFECTS
# MODIFIES
def bookings_to_model() -> routeoptimization_v1.ShipmentModel:
    """Create the model needed by the Route Optimization API."""
    shipment_model = routeoptimization_v1.ShipmentModel()
    start_time = datetime.datetime.now().replace(microsecond = 0)
    end_time = datetime.datetime.now().replace(microsecond = 0) + datetime.timedelta(hours = 23)
    shipment_model.global_start_time = start_time
    shipment_model.global_end_time = end_time

    # For all of the currently active vehicles, set up the vehicle needed by the API
    for vehicle in global_vars.VEHICLES:
        model_vehicle = routeoptimization_v1.Vehicle()
        model_vehicle.label = vehicle
        model_vehicle.start_location = {
            "latitude": global_vars.VEHICLES[vehicle].lat,
            "longitude": global_vars.VEHICLES[vehicle].log
        }
        model_vehicle.travel_mode = routeoptimization_v1.Vehicle.TravelMode.DRIVING
        load_policy = routeoptimization_v1.Vehicle.UnloadingPolicy.UNLOADING_POLICY_UNSPECIFIED
        model_vehicle.unloading_policy = load_policy
        capacity_limit = routeoptimization_v1.Vehicle.LoadLimit()
        capacity_limit.max_load = global_vars.VEHICLES[vehicle].maxcapacity
        model_vehicle.load_limits = {
            "num_passengers": capacity_limit
        }
        model_vehicle.cost_per_kilometer = 1
        shipment_model.vehicles.append(model_vehicle)

    # Iterate through all active ride requests, and create a shipment for each one
    # that hasn't been assigned a vehicle
    for req_id in global_vars.REQUESTS:
        if global_vars.REQUESTS[req_id].status == "Requested":
            # Create Shipment object needed by the Route Optimization API
            shipment = routeoptimization_v1.Shipment()

            # Specify the load (in number of passengers)
            shipment.load_demands = {
                "num_passengers": {
                    "amount": global_vars.REQUESTS[req_id].numpass
                }
            }

            # Specify the pickup and dropoff locations in the format needed by the API
            pickup_req = shipment.VisitRequest()
            delivery_req = shipment.VisitRequest()

            pickup_req.arrival_location = {
                "latitude": global_vars.REQUESTS[req_id].pickupCoord[0],
                "longitude": global_vars.REQUESTS[req_id].pickupCoord[1]
            }
            delivery_req.arrival_location = {
                "latitude": float(global_vars.REQUESTS[req_id].dropoff[0]),
                "longitude": float(global_vars.REQUESTS[req_id].dropoff[1])
            }
            pickup_req.duration = "60s"
            delivery_req.duration = "60s"

            shipment.pickups.append(value=pickup_req)
            shipment.label = str(req_id)
            shipment.deliveries.append(value=delivery_req)

            shipment_model.shipments.append(value=shipment)
    return shipment_model


# REQUIRES
# EFFECTS
# MODIFIES
def book_passenger(first_name, last_name, contact, user_uid, pickup, location, req_id,
                   num_passengers, dropoff_coord, dropoff_name) -> RideRequests:
    """Book a ride coming from a passenger app."""
    request_time = datetime.datetime.now()
    # Check the user has been logged in/exists
    new_request = RideRequests(
        rider_id = user_uid,
        status = "Requested",
        vehicle_id = "Pending Assignment",
        pickup_name=pickup,
        pickup_coord=(location[2], location[3]),
        dropoff_coord=dropoff_coord,
        phone=contact,
        first_name=first_name,
        last_name=last_name,
        request_id=str(req_id[0]),
        request_time=str(request_time),
        numpass=num_passengers,
        dropoff_name=dropoff_name
    )

    # Add to mappings
    global_vars.REQUESTS[str(req_id[0])] = new_request

    # If there is a vehicle with no active rides, call its assignment function
    if global_vars.VEHICLES:
        assign_rides()
