"""REST API for support chatbot using Google Gemini."""
from flask import Flask, Response, request, jsonify
import os
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
import safe_backend.api.config
import requests  
from safe_backend.api.chatbot_config  import *
from safe_backend.api.functions import *
import json

app = Flask(__name__)

genai.configure(api_key=os.environ["GOOGLE_API_KEY"])



model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    system_instruction=SYSTEM_INSTRUCTION,
    generation_config={
        "temperature": 0.9,
        "top_k": 1,
        "top_p": 1,
        "max_output_tokens": 2048,
    },
)

# Define available functions for the model to call
FUNCTIONS = [
    GEOCODE_ADDRESS_FUNCTION_DESCRIPTION,
    CANCEL_RIDE_FUNCTION_DESCRIPTION,
]

@app.route("/api/v1/chat/", methods=["POST"])
def chat():
    """Handle chat messages."""
    data = request.get_json()
    messages = data.get('messages', [])
    input_text = data.get('message')

    pickup_lat = data.get('lat')
    pickup_lon = data.get('long')
    user_id = data.get('user')
    
    if not input_text:
        return jsonify({"error": "Message is required"}), 400

    try:
        history = [
            {
                "role": "model",
                "parts": [INITIAL_GREETINGS]
            }
        ]
        for message in messages:
            if message['role'] == 'user':
                history.append({"role": "user", "parts": [message['content']]})
            elif message['role'] == 'model':
                history.append({"role": "model", "parts": [message['content']]})

        print("Chat History:", history)
        chat = model.start_chat(history=history)

        response = chat.send_message(input_text, functions=FUNCTIONS)
        response.resolve()

        if response.function_call:
            function_name = response.function_call["name"]
            function_args = response.function_call["arguments"]

            if function_name == "geocode_address":
                args = json.loads(function_args)
                address = args.get("address")
                geocode_response = geocode_address_api(address)

                if geocode_response["success"]:
                    dropoff_lat = geocode_response["latitude"]
                    dropoff_long = geocode_response["longitude"]
                    
                    
                    booking_response = book_ride_api(
                        pickup_lat=pickup_lat,
                        pickup_long=pickup_lon,
                        dropoff_lat=dropoff_lat,
                        dropoff_long=dropoff_long,
                        user_id= user_id,  
                        service_name= 'passenger'
                    )

                    if booking_response["success"]:
                        return jsonify({
                            "response": f"Your ride has been booked successfully! Your ride ID is {booking_response['ride_id']}.",
                            "success": True
                        }), 200
                    else:
                        return jsonify({
                            "response": f"Sorry, there was an issue booking your ride: {booking_response['error']}",
                            "success": False
                        }), 500
                else:
                    return jsonify({
                        "response": f"Sorry, I couldn't find the location you provided: {geocode_response['error']}",
                        "success": False
                    }), 400

            

            elif function_name == "cancel_ride":
                args = json.loads(function_args)
                ride_id = args.get("ride_id")

                if not ride_id:
                    
                    return jsonify({
                        "response": ASK_RIDE_ID,
                        "success": True
                    }), 200

                cancellation_response = cancel_ride_api(
                    ride_id=ride_id,
                    user_id=user_id
                )

                if cancellation_response["success"]:
                    return jsonify({
                        "response": CANCELLATION_SUCCESS,
                        "success": True
                    }), 200
                else:
                    return jsonify({
                        "response": f"{CANCELLATION_FAILURE} {cancellation_response['error']}",
                        "success": False
                    }), 500

        return jsonify({
            "response": response.text,
            "success": True
        }), 200

    except Exception as e:
        return jsonify({
            "error": f"Error processing message: {str(e)}",
            "success": False
        }), 500
            


if __name__ == "__main__":
    app.run(debug=True)
