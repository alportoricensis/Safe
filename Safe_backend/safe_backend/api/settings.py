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
        isPickup = False
        if "isPickup" in flask.request.form:
            isPickup = flask.request.form["isPickup"]
        isDropoff = False
        if "isDropoff" in flask.request.form:
            isDropoff = flask.request.form["isDropoff"]
        cur.execute("INSERT INTO locations (loc_name, lat, long, isPickup, isDropoff) VALUES (%s, %s, %s, %s, %s)", (location_name, lat, long, isPickup, isDropoff))
        conn.commit()
        cur.close()
        conn.close()
        return flask.redirect(flask.url_for("show_location_settings"))
    
    elif flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM locations;")
        sel = cur.fetchall()
        context = {
            "locations": []
        }
        if len(sel) != 0:
            for loc in sel:
                context["locations"].append({
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


@safe_backend.app.route("/api/v1/settings/ranges/", methods=["GET", "POST"])
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
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM locations WHERE lat = %s AND long = %s", (lat, long, ))
        sel = cur.fetchone()
        if sel is not None:
            flask.flash(f"Error: Range with center at (latitude, longitude) {lat, long} already exists!")
        isPickup = False
        if "isPickup" in flask.request.form:
            isPickup = flask.request.form["isPickup"]
        isDropoff = False
        if "isDropoff" in flask.request.form:
            isDropoff = flask.request.form["isDropoff"]
        cur.execute("INSERT INTO ranges (lat, long, radius_miles, isPickup, isDropoff) VALUES (%s, %s, %s, %s, %s)", (lat, long, radius_miles, isPickup, isDropoff))
        conn.commit()
        cur.close()
        conn.close()
        return flask.redirect(flask.url_for("show_range_settings"))




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
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor() 
        cur.execute("SELECT * FROM services WHERE service_name = %s", (sname, ))
        sel = cur.fetchone()
        if sel is not None:
            flask.flash(f"Error: Service {sname} already exists!")
        cur.execute("INSERT INTO services (service_name, start_time, end_time) VALUES (%s, %s, %s)", (sname, str(datetime.datetime.strptime(stime, "%H:%M").time()), str(datetime.datetime.strptime(etime, "%H:%M").time())))
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
        # context = {
        #     "services": []
        # }
        # for service in services:
        #     context["services"].append(service[1])

        context = {}

        for service in services:
            context[service[1]] = {
                'startTime': str(service[2]),
                'endTime': str(service[3])
            }

        return flask.jsonify(context), 200

    elif flask.request.method == "DELETE":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        service_name = flask.request.form["serviceName"]
        print(service_name)
        cur.execute("SELECT * FROM services WHERE service_name = %s;", (service_name, ))
        sel = cur.fetchall()
        if sel is None:
            flask.flash(f"Error: Service {service_name} does not exist!")
            return
        cur.execute("DELETE * FROM services WHERE service_name = %s;", (service_name, ))
        cur.close()
        conn.close()
        return flask.redirect(flask.url_for("show_service_settings"))