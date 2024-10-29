"""Request class definition in a micro-transit service."""
import datetime
import safe_backend.api.config
import safe_backend.api.requests

class Vehicle:
    """Object representing a vehicle in a micro-transit service."""
    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __init__(self, vehicle_id, status, capacity, range, latin, longin):
        """Initialize self to be a vehicle."""
        self.vehicle_id = vehicle_id
        self.capacity = capacity
        self.range = range
        self.itinerary = []
        self.status = status
        self.lat = latin
        self.log = longin


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def assign_rides():
        """Parse the active rides and find a tour using the optimization API."""

    


    