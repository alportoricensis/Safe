"""Request class definition in a micro-transit service."""
import datetime
import safe_backend.api.config

class RideRequests:
    """Object representing a ride request in a micro-transit service."""
    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __init__(self, dropoffName, request_time, rider_id, status, phone, vehicle_id, numpass, pickupName, pickupCoord, dropoff, firstName, lastName, request_id):
        """Initialize self to be a request."""
        self.rider_id = rider_id
        self.request_id = request_id
        self.firstName = firstName
        self.lastName = lastName
        self.driver = vehicle_id
        self.pickupName = pickupName
        self.pickupCoord = pickupCoord
        self.dropoffName = dropoffName
        self.dropoff = dropoff
        self.status = status
        self.phone = phone
        self.numpass = numpass
        self.etp = 0
        self.request_time = request_time
        self.pickuptime = 0
        self.dropofftime = 0
        self.eta = 0
        self.isPickup = True


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __eq__(self, other):
        """Initialize self to be a request."""
        return self.request_id == other.request_id


    