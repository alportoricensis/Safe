import os
import requests

def geocode_address_api(address):
    """Function to call the Google Geocoding API to convert an address or spot name into coordinates."""
    try:
        api_key = os.environ.get("GOOGLE_GEOCODING_API_KEY")
        if not api_key:
            return {"success": False, "error": "Geocoding API key not configured."}

        # Prepare the request URL
        url = "https://maps.googleapis.com/maps/api/geocode/json"
        params = {
            "address": address,
            "key": api_key
        }

        # Make the GET request to the Geocoding API
        response = requests.get(url, params=params)
        data = response.json()

        if data["status"] == "OK":
            location = data["results"][0]["geometry"]["location"]
            latitude = location["lat"]
            longitude = location["lng"]
            return {"success": True, "latitude": latitude, "longitude": longitude}
        else:
            return {"success": False, "error": data.get("error_message", data["status"])}

    except Exception as e:
        return {"success": False, "error": str(e)}

def book_ride_api(pickup_lat, pickup_long, dropoff_lat, dropoff_long, user_id):
    """Function to call the /api/v1/rides/ endpoint to book a ride."""
    try:
        # Prepare the payload
        payload = {
            "pickupLocation": {
                "latitude": pickup_lat,
                "longitude": pickup_long
            },
            "dropoffLocation": {
                "latitude": dropoff_lat,
                "longitude": dropoff_long
            },
            "user_id": user_id,
            "serviceName": 'passenger'
        }

        response = requests.post(
            "http://18.191.14.26/api/v1/rides/",
            json=payload  
        )

        if response.status_code == 200:
            data = response.json()
            return {"success": True, "ride_id": data.get("ride_id")}
        else:
            return {"success": False, "error": response.json().get("msg", "Unknown error")}
    except Exception as e:
        return {"success": False, "error": str(e)}

def cancel_ride_api(ride_id, user_id):
    """Function to cancel a ride."""
    try:
        url = f"http://18.191.14.26/api/v1/rides/passengers/{ride_id}/"

        headers = {
            "Content-Type": "application/json"
        }

        response = requests.delete(
            url,
            headers=headers,
            json={'user_id':user_id}
        )

        if response.status_code == 200:
            return {"success": True}
        else:
            error_msg = response.json().get("msg", "Unknown error")
            return {"success": False, "error": error_msg}

    except Exception as e:
        return {"success": False, "error": str(e)}