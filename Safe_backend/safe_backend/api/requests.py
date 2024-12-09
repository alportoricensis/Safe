"""Request class definition in a micro-transit service."""
class RideRequests:
    """Object representing a ride request in a micro-transit service."""
    # REQUIRES - dropoff_name, rider_id, status, vehicle_id, pickup_name, first_name, last_name
    #            are valid strings
    #          - numpass is a positive integer
    #          - request time is a valid datetime.datetime
    #          - picup_coord, dropoff_coord are tuples containing (lat, long) pairs
    # EFFECTS  - Initializes a RideRequest
    # MODIFIES - Nothing
    def __init__(self, dropoff_name, request_time, rider_id, status, phone, vehicle_id, numpass,
                    pickup_name, pickup_coord, dropoff_coord, first_name, last_name, request_id):
        """Initialize self to be a request."""
        self.rider_id = rider_id
        self.request_id = request_id
        self.first_name = first_name
        self.last_name = last_name
        self.driver = vehicle_id
        self.pickup_name = pickup_name
        self.pickup_coord = pickup_coord
        self.dropoff_name = dropoff_name
        self.dropoff_coord = dropoff_coord
        self.status = status
        self.phone = phone
        self.numpass = numpass
        self.etp = 0
        self.request_time = request_time
        self.eta = 0
        self.is_pickup = True


    # REQUIRES - self and other are valid RideRequests
    # EFFECTS  - Returns true if these RideRequests have the same request_id
    # MODIFIES - Nothing
    def __eq__(self, other):
        """Return true if two request_ids are the same."""
        return self.request_id == other.request_id
