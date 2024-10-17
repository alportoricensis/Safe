"""
Safe_backend index (main) debug view.

URLs include:
/
"""
import flask
import safe_backend


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


@safe_backend.app.route('/settings/vehicles')
def show_vehicle_settings():
    """Display /settings/vehicles route."""
    # TODO Check Logged-In and Proper Permissions
    return flask.render_template("vehicles.html")


@safe_backend.app.route('/settings/times')
def show_time_settings():
    """Display /settings/times route."""
    # TODO Check Logged-In and Proper Permissions
    return flask.render_template("times.html")