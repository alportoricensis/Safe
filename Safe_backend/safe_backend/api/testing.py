"""REST API for ride requests."""
import datetime
import flask
import random
import safe_backend.api.config
import safe_backend.api.requests
import safe_backend.api.vehicles


# Routes
@safe_backend.app.route("/api/v1/test/<int:num_req>/", methods=["GET"])
def gen_data(num_req):
    names = ["Alex Nunez", "Teage Johnson", "Kunal Mansukhani", "James Nesbitt", "Joseph Wood", "Bhavesh Vuyyuru", "Aryan Pal"]
    pickups = ["Bob and Betty Beyster", "EECS", "Duderstadt", "Shapiro Library", "Francois Xavier Bagnoud", "Ford Robotics"]
    dropoffs = ["1687 Broadway St", "915 S Division St", "180 Lake Village Dr", "1300 Beal Ave", "South Quadrangle"]
    vehicles = ["288", "3005", "3004", "3003"]
    for i in range(0, num_req):
        rid = random.randint(0, 10000)
        vehicle = safe_backend.api.vehicles.Vehicle(vehicle_id=random.choice(vehicles), status="active", capacity=10, range=200)
        passenger = safe_backend.api.requests.RideRequests(rider_id=i, vehicle_id=vehicle.vehicle_id, status="assigned", pickup=random.choice(pickups), request_id=rid, dropoff=random.choice(dropoffs), passname=random.choice(names))
        if vehicle.vehicle_id not in safe_backend.api.config.VEHICLE_QUEUES:
            safe_backend.api.config.VEHICLE_QUEUES[vehicle.vehicle_id] = vehicle
        safe_backend.api.config.VEHICLE_QUEUES[vehicle.vehicle_id].itinerary.append(passenger)
        safe_backend.api.config.RIDE_REQUESTS[str(rid)] = passenger
        if safe_backend.api.config.MODE == "ROUNDROBIN":
            safe_backend.api.config.ROUND_ROBIN_QUEUE.append(vehicle)

    context = {
        "Success": True
    }
    return flask.jsonify(**context), 200