"""REST API for support chatbot using Google Gemini."""
import os
from flask import request
import google.generativeai as genai
import safe_backend.api.config

genai.configure(api_key = os.environ["GOOGLE_API_KEY"])

def how_it_works():
    """Return how the ride-share app works for the chatbot."""
    return (
        "SAFE Ride-Sharing App: How It Works\n\n"

        "1. Getting Started\n"
        "Q: How do I sign up for SAFE?\n"
        "A: You have two options:\n"
        "   • Sign in with Google (recommended)\n"
        "   • Continue as a guest\n\n"

        "2. Booking a Ride\n"
        "Q: How do I request a ride?\n"
        "A: Follow these steps:\n"
        "   1. Select a service from the available options\n"
        "   2. Choose your pickup location from:\n"
        "      - Bob and Betty Biester\n"
        "      - LSA\n"
        "      - Duderstadt Center\n"
        "   3. Set your destination using the interactive map\n"
        "   4. Confirm your ride\n\n"

        "Q: How do I track my ride?\n"
        "A: Once your ride is confirmed, you'll see in Bookings:\n"
        "   • Driver's real-time location\n"
        "   • Estimated Time of Arrival (ETA)\n"
        "   • Driver's name\n"
        "   • Pickup and dropoff locations\n"
        "   The app automatically updates every 10 seconds\n\n"

        "3. Managing Bookings\n"
        "Q: How can I view my ride history?\n"
        "A: Access the Bookings tab to see:\n"
        "   • All past and current rides\n"
        "   • Ride status updates\n"
        "   • Pickup and dropoff locations\n"
        "   • Request times\n"
        "   • Driver information\n\n"

        "4. Account Management\n"
        "Q: What account features are available?\n"
        "A: In the Account tab, you can:\n"
        "   • View your profile information\n"
        "   • Add favorite locations (Home/Work)\n"
        "   • Access support via chatbot\n"
        "   • Sign out\n\n"

        "5. Support\n"
        "Q: How do I get help?\n"
        "A: SAFE provides an AI-powered chatbot that can help with:\n"
        "   • Booking rides\n"
        "   • Safety features\n"
        "   • Account management\n"
        "   • General inquiries\n\n"

        "6. Safety Features\n"
        "Q: What safety features does SAFE provide?\n"
        "A: SAFE includes:\n"
        "   • Real-time ride tracking\n"
        "   • Verified pickup locations\n"
        "   • Secure Google authentication\n"
        "   • Location services integration\n"
        "   • Regular status updates during rides\n\n"

        "7. Service Availability\n"
        "Q: What information is shown for available services?\n"
        "A: Each service displays:\n"
        "   • Provider name\n"
        "   • Service name\n"
        "   • Cost (including free services)\n"
        "   • Operating hours\n"
        "   • Availability status\n\n"

        "For additional support or questions, use the in-app chatbot"
        "accessible through the Account tab."
    )


model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    system_instruction="You are a helpful customer support chatbot for SAFE, a ride-sharing " \
        "service. You have access to the following FAQ information:\n\n{how_it_works()}\n\n" \
        "Please use this information to help users with their questions about SAFE's services," \
        "policies, and features. Be concise. Respond in no more than 3 sentences." \
        "If you don't know the answer, politely say so and suggest contacting SAFE Support" \
        "directly.",
    generation_config={
        "temperature": 0.9,
        "top_k": 1,
        "top_p": 1,
        "max_output_tokens": 2048,
    },
)


@safe_backend.app.route("/api/v1/chat/", methods=["POST"])
def chat():
    """Handle chat messages."""
    data = request.get_json()
    messages = data.get('messages', [])
    input_text = data.get('message')

    if not input_text:
        return {"error": "Message is required"}, 400

    try:
        history = [
            {
                "role": "model",
                "parts": [
                    "Hello! I'm SAFE's virtual assistant. How can I help you today?" \
                    "I can answer questions about booking rides, safety features, " \
                    "account management, and more."
                ]
            }
        ]
        for message in messages:
            if message['role'] == 'user':
                history.append({"role": "user", "parts": [message['content']]})
            elif message['role'] == 'model':
                history.append({"role": "model", "parts": [message['content']]})

        print(history)
        chat_var = model.start_chat(history=history)

        response = chat_var.send_message(input_text)
        response.resolve()

        return {
            "response": response.text,
            "success": True
        }, 200

    except Exception as e:
        return {
            "error": f"Error processing message: {str(e)}",
            "success": False
        }, 500
