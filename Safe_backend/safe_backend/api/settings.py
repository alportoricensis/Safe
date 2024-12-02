"""REST API for settings."""
import datetime
import flask
import safe_backend
import psycopg2


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
        cur.execute(
            "INSERT INTO vehicles (vehicle_name, capacity, vrange) VALUES (%s, %s, %s)",
            (vehicle_name, vehicle_capacity, vehicle_range)
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Succesfully created vehicle."}), 200

    if flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM vehicles")
        sel = cur.fetchall()
        context = {"vehicles": []}
        for vehicle in sel:
            context["vehicles"].append({
                "vehicle_id": vehicle[1],
                "capacity": vehicle[2],
                "vrange": vehicle[3],
            })
        return flask.jsonify(**context), 200
    return flask.jsonify(**{"msg": "Unsupported method"}), 404


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
        is_pickup = False
        if "isPickup" in flask.request.form:
            is_pickup = flask.request.form["isPickup"]
        is_dropoff = False
        if "isDropoff" in flask.request.form:
            is_dropoff = flask.request.form["isDropoff"]
        cur.execute(
            "INSERT INTO locations (loc_name, lat, long, isPickup, isDropoff, service_name) \
            VALUES (%s, %s, %s, %s, %s, %s)",
            (location_name, lat, long, is_pickup, is_dropoff, service_name)
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Successfully created location."}), 200

    if flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM locations ORDER BY service_name DESC;")
        sel = cur.fetchall()
        context = {}
        if sel is not None:
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
        return flask.jsonify(**context), 200

    if flask.request.method == "DELETE":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        location_name = flask.request.json["locationName"]
        service_name = flask.request.json["serviceName"]
        cur.execute(
            "SELECT * FROM locations WHERE loc_name = %s AND service_name = %s;",
            (location_name, service_name, )
        )
        sel = cur.fetchall()
        if sel is None:
            return flask.jsonify(**{"msg": "Location does not exist!"}), 400
        cur.execute(
            "DELETE FROM locations WHERE loc_name = %s AND service_name = %s;",
            (location_name, service_name, )
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Successfully deleted location."}), 200
    return flask.jsonify(**{"msg": "Unsupported method."}), 500


@safe_backend.app.route("/api/v1/settings/ranges/", methods=["GET", "POST", "DELETE"])
# REQUIRES  - User is authenticated with agency-level permissions (for POST)
#             User is authenticated with passenger-level permissions (for GET)
# EFFECTS   - CREATE new pickup/dropoff ranges
#             GET all pickup/dropoff ranges
# MODIFIES  - database
def ranges():
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
            return flask.jsonify(**{"msg": "Range already exists!"}), 400
        is_pickup = True
        if "isPickup" in flask.request.form:
            is_pickup = flask.request.form["isPickup"]
        is_dropoff = True
        if "isDropoff" in flask.request.form:
            is_dropoff = flask.request.form["isDropoff"]
        cur.execute(
            "INSERT INTO ranges (lat, long, radius_miles, isPickup, isDropoff, service_name) \
            VALUES (%s, %s, %s, %s, %s, %s)",
            (lat, long, radius_miles, is_pickup, is_dropoff, service_name)
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Successfully created range."}), 200

    if flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM ranges")
        sel = cur.fetchall()
        context = {
            "ranges": []
        }
        for range_center in sel:
            context["ranges"].append({
                "lat": range_center[1],
                "long": range_center[2],
                "radius_miles": range_center[3],
                "isPickup": range_center[4],
                "isDropoff": range_center[5],
                "service_name": range_center[6],
            })
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 200

    if flask.request.method == "DELETE":
        service_name = flask.request.json["serviceName"]
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM ranges")
        sel = cur.fetchall()
        if sel is None:
            return flask.jsonify(**{"msg": "No ranges for this service!"}), 404
        cur.execute("DELETE FROM ranges WHERE service_name = %s", (service_name, ))
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Successfully deleted."}), 200

    if flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM ranges", ())
        reg_services = cur.fetchall()
        context = {}

        for (index, service) in enumerate(reg_services):
            context[index] = {
                'rangeLatitude': service[1],
                'rangeLongitude': service[2],
                'rangeRadius': service[3],
                "isPickup": service[4],
                "isDropoff": service[5]
            }

        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(context), 200
    return flask.jsonify(**{"msg": "Unsupported method."}), 500


@safe_backend.app.route("/api/v1/settings/services/", methods=["GET", "POST", "DELETE", "PATCH"])
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
            return flask.jsonify(**{"msg": "Service already exists."}), 400
        cur.execute(
            "INSERT INTO services (service_name, start_time, end_time, provider, cost) \
            VALUES (%s, %s, %s, %s, %s)",
            (sname, str(datetime.datetime.strptime(stime, "%H:%M").time()),
             str(datetime.datetime.strptime(etime, "%H:%M").time()), provider, cost)
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Successfully registered service."}), 200

    if flask.request.method == "GET":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM services", ())
        reg_services = cur.fetchall()
        context = {"services": []}

        for service in reg_services:
            context["services"].append({
                'serviceName': service[0],
                'startTime': str(service[1]),
                'endTime': str(service[2]),
                "provider": str(service[3]),
                "cost": str(service[4])
            })
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**context), 200

    if flask.request.method == "DELETE":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        service_name = flask.request.json["serviceName"]
        cur.execute("SELECT * FROM services WHERE service_name = %s;", (service_name, ))
        sel = cur.fetchall()
        if sel is None:
            return flask.jsonify(**{"msg": f"Error: Service {service_name} does not exist!"}), 404
        cur.execute("DELETE FROM services WHERE service_name = %s;", (service_name, ))
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": f"Succesfully deleted {service_name}"}), 200

    if flask.request.method == "PATCH":
        conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                                port="5432")
        cur = conn.cursor()
        service_name = flask.request.json["serviceName"]
        start_time = flask.request.json["startTime"]
        end_time = flask.request.json["endTime"]
        cur.execute(
            "UPDATE services SET start_time = %s, end_time = %s WHERE service_name = %s;",
            (start_time, end_time, service_name,)
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Succesfully updated service"}), 200
    return flask.jsonify(**{"msg": "Unsupported method."}), 500


@safe_backend.app.route("/api/v1/settings/faq/", methods=["GET", "OPTIONS", "POST", "DELETE"])
# REQUIRES  - User is authenticated with agency-level permissions
# EFFECTS   - Create, Update, or Delete frequently asked questions
# MODIFIES  - database
def handle_faqs():
    """Update frequently asked questions for a service."""
    # TODO: Authentication

    # Check service validity
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()

    if flask.request.method == "GET" or flask.request.method == "OPTIONS":
        context = {"faqs": []}
        cur.execute("SELECT * FROM faqs")
        sel = cur.fetchall()
        for faq in sel:
            context["faqs"].append({
                "qid": faq[0],
                "service_name": faq[1],
                "question": faq[2],
                "answer": faq[3]
            })
        cur.close()
        conn.close()
        return flask.jsonify(**(context)), 200

    if flask.request.method == "POST":
        service_name = flask.request.json["serviceName"]
        cur.execute("SELECT * FROM services WHERE service_name = %s", (service_name, ))
        sel = cur.fetchone()
        if sel is None:
            cur.close()
            conn.close()
            return flask.jsonify(**{"msg": f"Service {service_name} does not exist."}), 404
        question = flask.request.json["question"]
        answer = flask.request.json["answer"]
        cur.execute(
            "INSERT INTO faqs (service_name, question, answer) VALUES (%s, %s, %s)",
            (service_name, question, answer)
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": "Succesfully added Q&A."}), 200

    if flask.request.method == "DELETE":
        qid = flask.request.json["questionID"]
        cur.execute(
            "DELETE FROM faqs WHERE question_id = %s",
            (qid, )
        )
        conn.commit()
        cur.close()
        conn.close()
        return flask.jsonify(**{"msg": f"Succesfully deleted Q&A with {qid}."}), 200
    return flask.jsonify(**{"msg": "Unsupported method."}), 400
