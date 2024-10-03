"""Request class definition in a micro-transit service."""
import datetime
#from rides import VEHICLE_QUEUES
#from rides import RIDE_REQUESTS

class RideRequests:
    """Object representing a ride request in a micro-transit service."""
    # REQUIRES
    # EFFECTS
    # MODIFIES
    def __init__(self, rider_id, vehicle_id, pickup, dropoff, rid):
        """Initialize self to be a request."""
        self.passenger = rider_id
        self.driver = vehicle_id
        self.pickup = pickup
        self.dropoff = dropoff
        self.rid = rid


    # REQUIRES
    # EFFECTS
    # MODIFIES
    def calculate_wait() -> datetime.time:
        """Calculate the estimated wait time for this ride request, based on assigned vehicle itinerary."""
        return datetime.time()


    