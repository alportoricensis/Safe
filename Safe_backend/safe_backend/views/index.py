"""
Safe_backend index (main) debug view.

URLs include:
/
"""
import flask
import safe_backend


@safe_backend.app.route('/')
def show_index():
    """Display / route."""
    return flask.render_template("index.html")