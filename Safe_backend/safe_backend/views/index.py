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