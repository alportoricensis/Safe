"""Request class definition in a micro-transit service."""
import datetime
import safe_backend.api.config

class RideRequests:
    """Object representing a ride request in a micro-transit service."""
    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __init__(self, rider_id, status, vehicle_id, pickup, dropoff, firstName, lastName, request_id):
        """Initialize self to be a request."""
        self.rider_id = rider_id
        self.request_id = request_id
        self.firstName = firstName
        self.lastName = lastName
        self.driver = vehicle_id
        self.pickup = pickup
        self.dropoff = dropoff
        self.status = status
        self.etp = 0
        self.eta = 0


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __eq__(self, other):
        """Initialize self to be a request."""
        return self.request_id == other.request_id


    