"""REST API for ride requests."""
import datetime
import flask
import random
import safe_backend.api.config
import safe_backend.api.requests


# Routes
@safe_backend.app.route("/api/v1/test/<int:num_req>/", methods=["GET"])
def gen_data(num_req):
    safe_backend.api.config.VEHICLE_QUEUES["288"] = []
    names = ["ALEX", "TEAGE", "KUNAL", "JAMES", "JOSEPH", "BHAVESH", "ARYAN"]
    pickups = ["BBB", "EECS", "DUDE", "UGLI", "FRB", "FXB"]
    for i in range(0, num_req):
        rid = random.randint(0, 10000)
        passenger = safe_backend.api.requests.RideRequests(rider_id=i, vehicle_id=-1, pickup=random.choice(pickups), request_id=rid, dropoff=random.choice(pickups), passname=random.choice(names))
        safe_backend.api.config.VEHICLE_QUEUES["288"].append(passenger)
        safe_backend.api.config.RIDE_REQUESTS[str(rid)] = passenger

    context = {
        "Success": True
    }
    return flask.jsonify(**context), 200