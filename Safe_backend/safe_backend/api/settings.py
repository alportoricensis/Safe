"""REST API for settings."""
import datetime
import flask
import safe_backend
import psycopg2
from collections import deque


# Routes
@safe_backend.app.route("/api/v1/settings/vehicles/", methods=["GET", "POST", "DELETE"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Creates a new vehicle with capacity and range
# MODIFIES  - database
def vehicles():
    """Create a new vehicle with given parameters."""
    # TODO: Authentication
    
    # Get data from request
    if flask.request.method == "POST":
        vehicle_name = flask.request.form["vehicleName"]
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM vehicles WHERE vehicle_name = %s", (vehicle_name, ))
        sel = cur.fetchone()
        if sel is not None:
            flask.flash(f"Error: Vehicle {vehicle_name} already exists!")
        vehicle_range = flask.request.form["vehicleRange"]
        vehicle_capacity = flask.request.form["vehicleCapacity"]
        cur.execute("INSERT INTO vehicles (vehicle_name, capacity, vrange) VALUES (%s, %s, %s)", (vehicle_name, vehicle_capacity, vehicle_range))
        conn.commit()
        cur.close()
        conn.close()
        return flask.redirect(flask.url_for("show_vehicle_settings"))

    elif flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM vehicles")
        sel = cur.fetchall()
        context = {"vehicles": []}
        for vehicle in sel:
            context["vehicles"].append(vehicle[1])
        return flask.jsonify(**context), 200


@safe_backend.app.route("/api/v1/settings/pickups/", methods=["GET", "POST", "DELETE"])
# REQUIRES  - User is authenticated with agency-level permissions (for POST)
#             User is authenticated with passenger-level permissions (for GET)
# EFFECTS   - CREATE new pickup/dropoff location
#             GET all pickup/dropoff locations
# MODIFIES  - database
def locations():
    """Create or get a new pickup/dropoff location."""
    # TODO: Authentication
    
    # Get data from request
    if flask.request.method == "POST":
        location_name = flask.request.form["locationName"]
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM locations WHERE loc_name = %s", (location_name, ))
        sel = cur.fetchone()
        if sel is not None:
            flask.flash(f"Error: Location {location_name} already exists!")
        lat = flask.request.form["locationLatitude"]
        long = flask.request.form["locationLongitude"]
        service_name = flask.request.form["serviceName"]
        isPickup = False
        if "isPickup" in flask.request.form:
            isPickup = flask.request.form["isPickup"]
        isDropoff = False
        if "isDropoff" in flask.request.form:
            isDropoff = flask.request.form["isDropoff"]
        cur.execute("INSERT INTO locations (loc_name, lat, long, isPickup, isDropoff, service_name) VALUES (%s, %s, %s, %s, %s, %s)", (location_name, lat, long, isPickup, isDropoff, service_name))
        conn.commit()
        cur.close()
        conn.close()
        return flask.redirect(flask.url_for("show_location_settings"))
    
    elif flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM locations ORDER BY service_name DESC;")
        sel = cur.fetchall()
        context = {}
        if len(sel) != 0:
            for loc in sel:
                if loc[6] not in context:
                    context[loc[6]] = []
                context[loc[6]].append({
                    "name": loc[1],
                    "long": loc[2],
                    "lat": loc[3],
                    "isPickup": loc[4],
                    "isDropoff": loc[5] 
                })
        cur.close()
        conn.close()
        return flask.jsonify(**context)
    
    elif flask.request.method == "DELETE": 
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        location_name = flask.request.form["loc_name"]
        cur.execute("SELECT * FROM locations WHERE loc_name = %s;", (location_name, ))
        sel = cur.fetchall()
        if sel is None:
            flask.flash(f"Error: Location {location_name} does not exist!")
            return
        cur.execute("DELETE * FROM locations WHERE loc_name = %s;", (location_name, ))
        cur.close()
        conn.close()
        return flask.redirect(flask.url_for("show_location_settings"))


@safe_backend.app.route("/api/v1/settings/ranges/", methods=["GET", "POST", "DELETE"])
# REQUIRES  - User is authenticated with agency-level permissions (for POST)
#             User is authenticated with passenger-level permissions (for GET)
# EFFECTS   - CREATE new pickup/dropoff ranges
#             GET all pickup/dropoff ranges
# MODIFIES  - database
def range():
    """Create a new vehicle with given parameters."""
    # TODO: Authentication
    
    # Get data from request
    if flask.request.method == "POST":
        lat = flask.request.form["rangeLatitude"]
        long = flask.request.form["rangeLongitude"]
        radius_miles = flask.request.form["rangeRadius"]
        service_name = flask.request.form["serviceName"]
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM ranges WHERE lat = %s AND long = %s", (lat, long, ))
        sel = cur.fetchone()
        if sel is not None:
            flask.flash(f"Error: Range with center at (latitude, longitude) {lat, long} already exists!")
        isPickup = True
        if "isPickup" in flask.request.form:
            isPickup = flask.request.form["isPickup"]
        isDropoff = True
        if "isDropoff" in flask.request.form:
            isDropoff = flask.request.form["isDropoff"]
        cur.execute("INSERT INTO ranges (lat, long, radius_miles, isPickup, isDropoff, service_name) VALUES (%s, %s, %s, %s, %s, %s)", (lat, long, radius_miles, isPickup, isDropoff, service_name))
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Successfully created range."}), 200
    
    elif flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM ranges")
        sel = cur.fetchall()
        context = {
            "ranges": []
        }
        for range in sel:
            context["ranges"].append({
                "lat": range[1],
                "long": range[2],
                "radius_miles": range[3],
                "isPickup": range[4],
                "isDropoff": range[5],
                "service_name": range[6],
            })
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 200

    elif flask.request.method == "DELETE":
        service_name = flask.request.json["serviceName"]
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM ranges")
        sel = cur.fetchall()
        if len(sel) == 0:
            return flask.jsonify(**{"msg": "No ranges for this service!"}), 404
        cur.execute("DELETE FROM ranges WHERE service_name = %s", (service_name, ))
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Succesfully deleted range"}), 200


@safe_backend.app.route("/api/v1/settings/services/", methods=["GET", "POST", "DELETE"])
# REQUIRES  - User is authenticated with agency-level permissions (for POST)
#             User is authenticated with passenger-level permissions (for GET)
# EFFECTS   - CREATE a new service provided by this agency
#             GET all services
# MODIFIES  - database
def services():
    """Create a new service with given parameters."""
    # TODO: Authentication
    
    # Get data from request
    if flask.request.method == "POST":
        sname = flask.request.form["serviceName"]
        stime = flask.request.form["startTime"]
        etime = flask.request.form["endTime"]
        provider = flask.request.form["provider"]
        cost = flask.request.form["cost"]
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM services WHERE service_name = %s", (sname, ))
        sel = cur.fetchone()
        if sel is not None:
            flask.flash(f"Error: Service {sname} already exists!")
        cur.execute(
            "INSERT INTO services (service_name, start_time, end_time, provider, cost) VALUES (%s, %s, %s, %s, %s)",
            (sname, str(datetime.datetime.strptime(stime, "%H:%M").time()), str(datetime.datetime.strptime(etime, "%H:%M").time()), provider, cost)
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.redirect(flask.url_for("show_service_settings"))
    
    elif flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM services", ())
        services = cur.fetchall()
        context = {"services": []}

        for service in services:
            context["services"].append({
                'serviceName': service[0],
                'startTime': str(service[1]),
                'endTime': str(service[2]),
                "provider": service[3],
                "cost": str(service[4])
            })
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(context), 200

    elif flask.request.method == "DELETE":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        service_name = flask.request.json["serviceName"]
        print(service_name)
        cur.execute("SELECT * FROM services WHERE service_name = %s;", (service_name, ))
        sel = cur.fetchall()
        if sel is None:
            flask.flash(f"Error: Service {service_name} does not exist!")
            return
        cur.execute("DELETE FROM services WHERE service_name = %s;", (service_name, ))
        conn.commit()
        cur.close()
        conn.close()
        context = {}
        return flask.jsonify(context), 200