from collections import deque

# Globals
# VEHICLE_QUEUES maps a vehicle_id to the vehicle object.
VEHICLE_QUEUES = {}
# RIDE_REQUESTS is a dictionary of all currenty active ride ride requests
RIDE_REQUESTS = {}
# MODE is the algorithm currently used to assign ride requests
MODE = "ROUNDROBIN"
# ROUND_ROBIN_QUEUE is a queue of riders used when MODE is ROUNDROBIN
ROUND_ROBIN_QUEUE = deque()