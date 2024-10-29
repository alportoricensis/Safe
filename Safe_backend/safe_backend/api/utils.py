"""Helper functions for REST API for ride requests."""
import datetime
import flask
import psycopg2


# REQUIRES  -
# EFFECTS   -
# MODIFIES  - 
def check_pickup(location_name = "", coordinates = (0.0, 0.0)) -> bool:
    """Check that name or coordinates is a valid pickup location."""
    # TODO - Implement
    return True


# REQUIRES  -
# EFFECTS   -
# MODIFIES  - 
def check_dropoff(location_name = "", coordinates = (0.0, 0.0)) -> bool:
    """Check that name or coordinates is a valid pickup location."""
    # TODO - Implement
    return True


# REQUIRES  -
# EFFECTS   -
# MODIFIES  - 
def check_time(startTime, endTime, currentTime) -> bool:
    """Verify currentTime is within start and end; return false otherwise."""
    if startTime < endTime:
        return startTime <= currentTime <= endTime
    else:
        return startTime <= currentTime or currentTime <= endTime


