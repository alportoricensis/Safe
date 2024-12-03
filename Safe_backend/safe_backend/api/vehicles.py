"""Request class definition in a micro-transit service."""
import copy
from google.maps import routeoptimization_v1
import safe_backend.api.config as global_vars

class Vehicle:
    """Object representing a vehicle in a micro-transit service."""
    # REQUIRES
    # EFFECTS
    # MODIFIES
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


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def response_to_queue(self, response: routeoptimization_v1.OptimizeToursResponse) -> None:
        """Transform a response from the Route Optimization API to a queue of places to visit."""
        # For each visit in the returns routes response,
        for route in response.routes:
            if route.vehicle_label == self.vehicle_id:
                for visit in route.visits:
                    if visit.shipment_label not in self.queue:
                        self.itinerary.append(global_vars.REQUESTS[visit.shipment_label])
                        self.queue.append(visit.shipment_label)
                        global_vars.REQUESTS[visit.shipment_label].status = "In-Progress"
                        global_vars.REQUESTS[visit.shipment_label].driver = self.vehicle_id
                        global_vars.REQUESTS[visit.shipment_label].etp = visit.start_time
                    else:
                        self.queue.append(visit.shipment_label)


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def empty(self) -> bool:
        """Return true if vehicle is empty."""
        if self.capacity == self.maxcapacity:
            return True
        return False
