"""REST API for users."""
import flask
import psycopg2
import safe_backend.api.config

# Routes
@safe_backend.app.route("/api/v1/users/login/", methods=["POST"])
# REQUIRES  - uuid, displayName, and email are in the request
# EFFECTS   - Logs in a user with this agency
# MODIFIES  - users relation
def login_user():
    """Log in a user with the uuid from the request."""
    # Get uuid from request
    pass_uuid = flask.request.json["uuid"]

    # If this passenger hasn't been seen before, add them to the database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
    cur = conn.cursor()
    cur.execute("SELECT * FROM users WHERE uuid = %s;", (pass_uuid, ))
    user = cur.fetchone()
    if user is None:
        display_name = flask.request.json["displayName"]
        email = flask.request.json["email"]
        cur.execute(
            "INSERT INTO users (uuid, display_name, phone_number, email) \
            VALUES (%s, %s, %s, %s)",
            (pass_uuid, display_name, "(000) 000-0000", email)
        )
        conn.commit()
        cur.close()
        conn.close()
    return flask.jsonify(**{"msg": "Succesfully logged {pass_uuid} in."}), 200


@safe_backend.app.route("/api/v1/users/bookings/", methods=["GET"])
# REQUIRES  - uuid is in the request
# EFFECTS   - Returns prior bookings for this user
# MODIFIES  - Nothing
def get_bookings():
    """Return bookings this user has made."""
    # Get UUID from the request
    pass_uuid = flask.request.args.get("uuid")

    # Get prior rides from the database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
    cur = conn.cursor()
    cur.execute(
        "SELECT * FROM ride_requests WHERE user_id = %s ORDER BY ride_id DESC;",
        (pass_uuid, )
    )
    requests = cur.fetchall()
    context = {"requests": []}
    for request in requests:
        context["requests"].append({
            "ride_id": request[0],
            "pickup_lat": request[1],
            "pickup_long": request[2],
            "dropoff_lat": request[3],
            "dropoff_long": request[4],
            "status": request[7],
            "pickup_time": str(request[8]),
            "dropoff_time": str(request[9]),
            "request_time": str(request[10]),
            "service_name": request[11]
        })
    return flask.jsonify(**context), 200
