"""Request class definition in a micro-transit service."""
import datetime
from google.maps import routeoptimization_v1
from google.auth import credentials
import safe_backend.api.requests
import safe_backend.api.config

class Vehicle:
    """Object representing a vehicle in a micro-transit service."""
    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __init__(self, vehicle_id, status, capacity, range, latin, longin):
        """Initialize self to be a vehicle."""
        self.vehicle_id = vehicle_id
        self.capacity = capacity
        self.maxcapacity = capacity
        self.range = range
        self.itinerary = []
        self.queue = []
        self.status = status
        self.lat = latin
        self.log = longin


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def empty(self) -> bool:
        """Return true if vehicle is empty."""
        if self.capacity == self.maxcapacity:
            return True
        return False


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def assign_rides(self):
        """Parse the active rides and find a tour using the optimization API."""
        ShipmentModel = routeoptimization_v1.ShipmentModel()

        # Set up the vehicle object needed by the Route Optimization API
        Vehicle = routeoptimization_v1.Vehicle()
        Vehicle.start_location = {
            "latitude": self.lat, "longitude": self.log
        }
        Vehicle.travel_mode = routeoptimization_v1.Vehicle.TravelMode.DRIVING
        Vehicle.unloading_policy = routeoptimization_v1.Vehicle.UnloadingPolicy.UNLOADING_POLICY_UNSPECIFIED
        capacity_limit = routeoptimization_v1.Vehicle.LoadLimit()
        capacity_limit.max_load = self.maxcapacity
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
                pickup_req.duration = "160s"
                delivery_req.duration = "160s"

                shipment.pickups.append(pickup_req)
                shipment.display_name = f"{safe_backend.api.config.RIDE_REQUESTS[req_id].firstName}_{safe_backend.api.config.RIDE_REQUESTS[req_id].lastName}_{str(req_id)}"
                shipment.deliveries.append(delivery_req)

                ShipmentModel.shipments.append(shipment)

        #ShipmentModel.global_start_time = datetime.datetime.now()
        #ShipmentModel.global_end_time = datetime.datetime.now() + datetime.timedelta(days = 1)

        # Instantiate the client to send and receive the request
        breakpoint()
        client = routeoptimization_v1.RouteOptimizationClient()
        
        # Initialize the arguments
        request = routeoptimization_v1.OptimizeToursRequest()
        request.model = ShipmentModel
        request.parent = "projects/eecs-441-safe"

        # Send and retrieve the request
        response = client.optimize_tours(
            request = request
        )
        print(response)
        


    


    