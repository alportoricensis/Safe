import os
import requests
import flask
import datetime
from safe_backend.api.utils import check_time, check_dropoff, assign_rides, book_passenger
import safe_backend.api.config as global_vars
import safe_backend
import psycopg2
from geopy.geocoders import Nominatim


def geocode_address_api(address):
    """Function to call the Google Geocoding API to convert an address or spot name into coordinates."""
    loc = Nominatim(user_agent="GetLoc")
    getLoc = loc.geocode(address)
    return {"success": True, "latitude": getLoc.latitude, "longitude": getLoc.longitude}

def book_ride_api(pickup, dropoff, service, user_id):
    """Function to book a ride."""
    try:
        # Geocode pickup location
        pickup_result = geocode_address_api(pickup)
        if not pickup_result["success"]:
            return pickup_result
        
        # Geocode dropoff location
        dropoff_result = geocode_address_api(dropoff)
        if not dropoff_result["success"]:
            return dropoff_result

        # Create payload
        payload = {
            "uuid": user_id,
            "serviceName": service,
            "pickupLocation": pickup,
            "dropoffLocation": dropoff,
            "dropoffLat": dropoff_result["latitude"],
            "dropoffLong": dropoff_result["longitude"],
            "rideOrigin": "passenger",
            "numPassengers": 1
        }

        # Use Flask's test client to make the internal request
        with safe_backend.app.test_client() as client:
            response = client.post(
                "/api/v1/rides/",
                json=payload
            )
            
            if response.status_code == 200:
                data = response.get_json()
                return {"success": True, "ride_id": data.get("ride_id")}
            else:
                return {"success": False, "error": response.get_json().get("msg", "Unknown error")}

    except Exception as e:
        return {"success": False, "error": str(e)}

def cancel_ride_api(ride_id, user_id):
    """Function to cancel a ride."""
    try:
        # Use Flask's test client to make the internal request
        with safe_backend.app.test_client() as client:
            response = client.delete(
                f"/api/v1/rides/passengers/{ride_id}/",
                json={'user_id': user_id}
            )

            if response.status_code == 200:
                return {"success": True}
            else:
                error_msg = response.get_json().get("msg", "Unknown error")
                return {"success": False, "error": error_msg}

    except Exception as e:
        return {"success": False, "error": str(e)}
    
