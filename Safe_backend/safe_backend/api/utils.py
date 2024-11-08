"""Helper functions for REST API for ride requests."""
import datetime
import flask
from geopy import distance as dist
import psycopg2


# REQUIRES  -
# EFFECTS   -
# MODIFIES  - 
def check_pickup(location_name = "", coordinates = (0.0, 0.0)) -> bool:
    """Check that name or coordinates is a valid pickup location."""
    # Connect to database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()

    # Check ranges first
    cur.execute("SELECT * FROM ranges WHERE isPickup = True")
    ranges = cur.fetchall()
    for range in ranges:
        if calc_distance(location = coordinates, center = (range[1], range[2])) < range[3]:
            return True

    # Check locations second
    cur.execute("SELECT * FROM locations WHERE loc_name = %s", (location_name,))
    locations = cur.fetchall()
    if len(locations) != 0 and locations[4]:
        return True

    return False


# REQUIRES  -
# EFFECTS   -
# MODIFIES  - 
def check_dropoff(location_name = "", coordinates = (0.0, 0.0)) -> bool:
    """Check that name or coordinates is a valid pickup location."""
    # Connect to database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                            port="5432")
    cur = conn.cursor()

    # Check ranges first
    cur.execute("SELECT * FROM ranges WHERE isDropoff = True")
    ranges = cur.fetchall()
    for range in ranges:
        if calc_distance(location = coordinates, center = (range[1], range[2])) < range[3]:
            return True

    # Check locations second
    cur.execute("SELECT * FROM locations WHERE loc_name = %s", (location_name,))
    locations = cur.fetchall()
    if len(locations) != 0 and locations[5]:
        return True

    return False


# REQUIRES  -
# EFFECTS   -
# MODIFIES  - 
def check_time(startTime, endTime, currentTime) -> bool:
    """Verify currentTime is within start and end; return false otherwise."""
    if startTime < endTime:
        return startTime <= currentTime <= endTime
    else:
        return startTime <= currentTime or currentTime <= endTime
    

# REQUIRES  -
# EFFECTS   -
# MODIFIES  - 
def calc_distance(location, center) -> float:
    """Calculate distance between location and center."""
    return dist.distance(location, center).miles


