"""Request class definition in a micro-transit service."""
import datetime
import copy
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
        dict_copy = copy.deepcopy(safe_backend.api.config.RIDE_REQUESTS)
        for route in response.routes:
            if route.vehicle_label == self.vehicle_id:
                for visit in route.visits:
                    # If this is a pickup, get the pickup coordinates corresponding to shipment_label
                    if visit.is_pickup == True:
                        # Add to itinerary WITH isPickup = true - used to display order of assignment
                        self.itinerary.append(safe_backend.api.config.RIDE_REQUESTS[visit.shipment_label])
                        safe_backend.api.config.RIDE_REQUESTS[visit.shipment_label].status = "Assigned"
                        safe_backend.api.config.RIDE_REQUESTS[visit.shipment_label].driver = self.vehicle_id
                        safe_backend.api.config.RIDE_REQUESTS[visit.shipment_label].etp = visit.start_time
                    # Otherwise, this is a dropoff, so get the dropoff coordinates corresponding to shipment index
                    else:
                        # Add to itinerary WITH isPickup = false - used to display order of assignment
                        safe_backend.api.config.RIDE_REQUESTS[visit.shipment_label].eta = visit.start_time
                        dict_copy[visit.shipment_label].isPickup = False
                        dict_copy[visit.shipment_label].etp = False
                        self.itinerary.append(dict_copy[visit.shipment_label])


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def empty(self) -> bool:
        """Return true if vehicle is empty."""
        if self.capacity == self.maxcapacity:
            return True
        return False
        


    


    