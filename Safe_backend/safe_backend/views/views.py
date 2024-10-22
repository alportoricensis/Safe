"""
Safe_backend index (main) debug view.

URLs include:
/
"""
import flask
import safe_backend
import psycopg2


@safe_backend.app.route('/dispatch')
def show_dispatch():
    """Display /dispatch route."""
    # TODO Check Logged-In and Proper Permissions
    return flask.render_template("dispatch.html")


@safe_backend.app.route('/')
def show_index():
    """Display /index route."""
    # TODO Check Logged-In and Proper Permissions

    # TODO: Get services available
    context = {
        "username": "Alex Nunez-Carrasquillo",
        "services": ["Service #1"]
    }
    return flask.render_template("index.html", **context)


@safe_backend.app.route('/settings')
def show_settings():
    """Display /settings route."""
    # TODO Check Logged-In and Proper Permissions
    return flask.render_template("settings.html")


@safe_backend.app.route('/settings/ranges')
def show_range_settings():
    """Display /settings/ranges route."""
    # TODO Check Logged-In and Proper Permissions
    return flask.render_template("ranges.html")


@safe_backend.app.route('/settings/locations')
def show_location_settings():
    """Display /settings/locations route."""
    # TODO Check Logged-In and Proper Permissions

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
    return flask.render_template("places.html", **context)


@safe_backend.app.route('/settings/vehicles')
def show_vehicle_settings():
    """Display /settings/vehicles route."""
    # TODO Check Logged-In and Proper Permissions

    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()
    cur.execute("SELECT * FROM vehicles;")
    sel = cur.fetchall()
    context = {
        "vehicles": []
    }
    if len(sel) != 0:
        for vehicle in sel:
            context["vehicles"].append({
                "name": vehicle[1],
                "range": vehicle[3],
                "capacity": vehicle[2] 
            })
    cur.close()
    conn.close()
    return flask.render_template("vehicles.html", **context)


@safe_backend.app.route('/settings/times')
def show_time_settings():
    """Display /settings/times route."""
    # TODO Check Logged-In and Proper Permissions
    return flask.render_template("times.html")