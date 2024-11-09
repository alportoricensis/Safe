"""Helper functions for REST API for ride requests."""
import datetime
import flask
from geopy import distance as dist
from google.maps import routeoptimization_v1
import safe_backend.api.config
import psycopg2


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
    for range in ranges:
        if calc_distance(location = coordinates, center = (range[1], range[2])) < range[3]:
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
    for range in ranges:
        if calc_distance(location = coordinates, center = (range[1], range[2])) < range[3]:
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
def check_time(startTime, endTime, currentTime) -> bool:
    """Verify currentTime is within start and end; return false otherwise."""
    if startTime < endTime:
        return startTime <= currentTime <= endTime
    else:
        return startTime <= currentTime or currentTime <= endTime
    

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
    ShipmentModel = bookings_to_model()

    # Instantiate the client to send and receive the request
    client = routeoptimization_v1.RouteOptimizationClient()
    
    # Initialize the arguments
    request = routeoptimization_v1.OptimizeToursRequest()
    request.model = ShipmentModel
    request.parent = "projects/eecs-441-safe"

    # Send and retrieve the request
    response = client.optimize_tours(
        request = request
    )
    
    # Transform the response into a queue, and update self's itinerary
    for vehicle in safe_backend.api.config.VEHICLE_QUEUES:
        safe_backend.api.config.VEHICLE_QUEUES[vehicle].response_to_queue(response)


# REQUIRES
# EFFECTS
# MODIFIES
def bookings_to_model() -> routeoptimization_v1.ShipmentModel:
    """Create the model needed by the Route Optimization API."""
    ShipmentModel = routeoptimization_v1.ShipmentModel()

    # For all of the currently active vehicles, set up the vehicle needed by the API
    for vehicle in safe_backend.api.config.VEHICLE_QUEUES:
        Vehicle = routeoptimization_v1.Vehicle()
        Vehicle.label = vehicle
        Vehicle.start_location = {
            "latitude": safe_backend.api.config.VEHICLE_QUEUES[vehicle].lat, "longitude": safe_backend.api.config.VEHICLE_QUEUES[vehicle].log
        }
        Vehicle.travel_mode = routeoptimization_v1.Vehicle.TravelMode.DRIVING
        Vehicle.unloading_policy = routeoptimization_v1.Vehicle.UnloadingPolicy.UNLOADING_POLICY_UNSPECIFIED
        capacity_limit = routeoptimization_v1.Vehicle.LoadLimit()
        capacity_limit.max_load = safe_backend.api.config.VEHICLE_QUEUES[vehicle].maxcapacity
        Vehicle.load_limits = {
            "num_passengers": capacity_limit
        }
        Vehicle.cost_per_kilometer = 1
        ShipmentModel.vehicles.append(Vehicle)
    
    # Iterate through all active ride requests, and create a shipment for each one
    # that hasn't been assigned a vehicle
    for req_id in safe_backend.api.config.RIDE_REQUESTS:
        if safe_backend.api.config.RIDE_REQUESTS[req_id].status == "requested":
            # Create Shipment object needed by the Route Optimization API
            shipment = routeoptimization_v1.Shipment()

            # Specify the load (in number of passengers)
            shipment.load_demands = {
                "num_passengers": {
                    "amount": safe_backend.api.config.RIDE_REQUESTS[req_id].numpass
                }
            }

            # Specify the pickup and dropoff locations in the format needed by the API
            pickup_req = shipment.VisitRequest()
            delivery_req = shipment.VisitRequest()

            pickup_req.arrival_location = {
                "latitude": safe_backend.api.config.RIDE_REQUESTS[req_id].pickupCoord[0], "longitude": safe_backend.api.config.RIDE_REQUESTS[req_id].pickupCoord[1]
            }
            delivery_req.arrival_location = {
                "latitude": float(safe_backend.api.config.RIDE_REQUESTS[req_id].dropoff[0]), "longitude": float(safe_backend.api.config.RIDE_REQUESTS[req_id].dropoff[1])
            }
            pickup_req.duration = "60s"
            delivery_req.duration = "60s"

            shipment.pickups.append(pickup_req)
            shipment.label = str(req_id)
            shipment.deliveries.append(delivery_req)

            ShipmentModel.shipments.append(shipment)
    return ShipmentModel


