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
        self.status = status
        self.lat = latin
        self.log = longin


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def response_to_queue(self, response: routeoptimization_v1.OptimizeToursResponse) -> None:
        """Transform a response from the Route Optimization API to a queue of places to visit."""
        # For each visit in the returns routes response,
        for visit in response.routes[0].visits:
            # If this is a pickup, get the pickup coordinates corresponding to shipment_label
            if visit.is_pickup == True:
                # Add to itinerary WITH isPickup = true - used to display order of assignment
                self.itinerary.append(safe_backend.api.config.RIDE_REQUESTS[visit.shipment_label])
            # Otherwise, this is a dropoff, so get the dropoff coordinates corresponding to shipment index
            else:
                # Add to itinerary WITH isPickup = false - used to display order of assignment
                copy = safe_backend.api.config.RIDE_REQUESTS[visit.shipment_label]
                copy.isPickup = False
                self.itinerary.append(copy)


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def bookings_to_model(self) -> routeoptimization_v1.ShipmentModel:
        """Create the model needed by the Route Optimization API."""
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
                pickup_req.duration = "60s"
                delivery_req.duration = "60s"

                shipment.pickups.append(pickup_req)
                shipment.label = str(req_id)
                shipment.deliveries.append(delivery_req)

                ShipmentModel.shipments.append(shipment)
        return ShipmentModel



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
        # Create the shipment model 
        ShipmentModel = self.bookings_to_model()

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
        self.response_to_queue(response)
        


    


    