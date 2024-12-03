"""REST API for support chatbot using Google Gemini."""
from flask import Flask, Response, request, jsonify
import os
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
import safe_backend
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
    tools=[book_ride_function, cancel_ride_function]
)


@safe_backend.app.route("/api/v1/chat/", methods=["POST"])
def chat():
    """Handle chat messages."""
    data = request.get_json()
    messages = data.get('messages', [])
    input_text = data.get('message')
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

        response = chat.send_message(input_text)
        response.resolve()
        
        # Check if response has function call
        if response.candidates[0].content.parts[0].function_call:
            function_call = response.candidates[0].content.parts[0].function_call
            function_name = function_call.name
            function_args = function_call.args
            
            if function_name == "book_ride":
                print("function_name:", function_name)
                print("function_args:", function_args)
                pickup = function_args.get("pickup")
                dropoff = function_args.get("dropoff")
                service = function_args.get("service")
                booking_response = book_ride_api(pickup, dropoff, service, user_id)

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
            
            elif function_name == "cancel_ride":
                print("function_name:", function_name)
                print("function_args:", function_args)
                ride_id = function_args.get("ride_id")

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
        print(f"Error: {str(e)}")
        return jsonify({
            "error": f"Error processing message: {str(e)}",
            "success": False
        }), 500

