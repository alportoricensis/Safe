"""Request class definition in a micro-transit service."""
import datetime
import safe_backend.api.config
import safe_backend.api.requests

class Vehicle:
    """Object representing a vehicle in a micro-transit service."""
    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __init__(self, vehicle_id, capacity, range):
        """Initialize self to be a vehicle."""
        self.vehicle_id = vehicle_id
        self.capacity = capacity
        self.range = range
        self.itinerary = []


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def calculate_cost(request_in) -> datetime.time:
        """Calculate the cost for adding this request into this vehicle."""
        return datetime.time()


    