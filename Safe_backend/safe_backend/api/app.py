"""REST API for ride requests."""
import flask
import safe_backend

@safe_backend.app.route("/api/v1/", methods=["GET"])
def api_get_services():
    """Return services on this api.
    
    Example:
    {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
    """
    context = {
        "rides": "/api/v1/rides/",
        "settings": "/api/v1/settings/"
    }
    return flask.jsonify(**context), 200
