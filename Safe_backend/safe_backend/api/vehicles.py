"""Request class definition in a micro-transit service."""
import copy
from google.maps import routeoptimization_v1
import safe_backend.api.config as global_vars

class Vehicle:
    """Object representing a vehicle in a micro-transit service."""
    # REQUIRES - vehicle_id to be a string identifying this vehicle
    #          - status is a string for this vehicle's current status
    #          - capacity is an integer for the number of passengers that can be
    #            in this vehicle
    #          - vrange is the range (in miles) of this vehicle (unused)
    #          - latin, login are floats for this vehicle's current coordinates
    # EFFECTS  - Initializes a vehicle
    # MODIFIES - Nothing
    def __init__(self, vehicle_id, status, capacity, vrange, latin, longin):
        """Initialize self to be a vehicle."""
        self.vehicle_id = vehicle_id
        self.capacity = capacity
        self.maxcapacity = capacity
        self.range = vrange
        self.itinerary = []
        self.queue = []
        self.status = status
        self.lat = latin
        self.log = longin
        self.miles_travelled = 0


    # REQUIRES  - response is a valid response from an OptimizeToursRequest
    # EFFECTS   - Parses response into the assigned rides for this vehicle
    # MODIFIES  - self.itinerary, self.queue, ride_request etp and eta
    def response_to_queue(self, response: routeoptimization_v1.OptimizeToursResponse) -> None:
        """Transform a response from the Route Optimization API to a queue of places to visit."""
        # For each visit in the returns routes response,
        for route in response.routes:
            if route.vehicle_label == self.vehicle_id:
                self.itinerary = []
                self.queue = []
                for visit in route.visits:
                    if visit.shipment_label not in self.queue and visit.is_pickup:
                        self.itinerary.append(global_vars.REQUESTS[visit.shipment_label])
                        self.queue.append(visit.shipment_label)
                        global_vars.REQUESTS[visit.shipment_label].driver = self.vehicle_id
                        global_vars.REQUESTS[visit.shipment_label].etp = visit.start_time
                    elif not visit.is_pickup:
                        self.queue.append(visit.shipment_label)
                        global_vars.REQUESTS[visit.shipment_label].eta = visit.start_time


    # REQUIRES - Nothing
    # EFFECTS  - Returns true if vehicle is empty
    # MODIFIES - Nothing
    def empty(self) -> bool:
        """Return true if vehicle is empty."""
        if self.capacity == self.maxcapacity:
            return True
        return False
