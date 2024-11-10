"""REST API for support chatbot using Google Gemini."""
from flask import Response, request
import os
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
import safe_backend.api.config

genai.configure(api_key = os.environ["GOOGLE_API_KEY"])

model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    system_instruction="""You are a helpful support assistant for a ride-sharing service called Safe. 
    You help users with booking rides, checking ride status, and general inquiries. 
    Keep responses concise and friendly. If you cannot help with a specific request, 
    direct users to contact customer support.""",
    generation_config={
        "temperature": 0.9,
        "top_k": 1,
        "top_p": 1,
        "max_output_tokens": 2048,
    },
)

def how_it_works():
    return (
        "SAFE Ride-Sharing App: FAQ\n\n"
        "1. Getting Started\n"
        "Q: How do I sign up for SAFE?\n"
        "A: Download the SAFE app from the App Store or Google Play. Open the app, tap 'Sign Up,' and follow the instructions to create an account using your email or mobile number.\n\n"
        "Q: Can I use SAFE without an account?\n"
        "A: No, you must create an account to use SAFE services. This ensures the security and safety of both riders and drivers.\n\n"
        
        "2. Booking a Ride\n"
        "Q: How do I request a ride?\n"
        "A: Open the SAFE app, enter your destination, and choose your preferred ride type. Confirm your pickup location, then tap 'Request' to book your ride.\n\n"
        "Q: Can I schedule a ride in advance?\n"
        "A: Yes, you can schedule a ride by selecting 'Schedule a Ride' before confirming your booking. Choose your preferred date and time.\n\n"
        "Q: How do I know my driver has arrived?\n"
        "A: You’ll receive a notification when your driver is nearby. You can also track their location on the app.\n\n"
        
        "3. Payment and Pricing\n"
        "Q: What payment options does SAFE offer?\n"
        "A: SAFE accepts credit/debit cards, digital wallets, and, in some locations, cash. You can set up your preferred payment method in the app.\n\n"
        "Q: How is the fare calculated?\n"
        "A: Fares are based on distance, time, demand, and the type of ride selected. You’ll see a fare estimate before confirming your ride.\n\n"
        "Q: Are there any cancellation fees?\n"
        "A: Yes, cancellation fees apply if you cancel a ride after the driver has accepted it. The fee helps compensate the driver for their time.\n\n"
        
        "4. Ride Safety\n"
        "Q: What safety features does SAFE provide?\n"
        "A: SAFE offers several safety features, including real-time tracking, an in-app emergency button, driver verification, and two-way ratings. You can also share your ride details with friends or family.\n\n"
        "Q: How are drivers screened?\n"
        "A: All drivers go through a background check and vehicle inspection. SAFE also requires drivers to meet specific safety and vehicle standards.\n\n"
        "Q: What should I do if I feel unsafe during a ride?\n"
        "A: If you feel unsafe, use the in-app emergency button to alert authorities or call for help. You can also report any issues directly to SAFE’s support team.\n\n"
        
        "5. Account and Profile\n"
        "Q: How do I update my profile information?\n"
        "A: Go to 'Account Settings' in the app to update your name, email, payment information, or phone number.\n\n"
        "Q: Can I delete my SAFE account?\n"
        "A: Yes, you can request to delete your account by going to 'Account Settings' and selecting 'Delete Account.' This process may take a few days.\n\n"
        "Q: What if I forgot my password?\n"
        "A: Tap 'Forgot Password' on the login screen, and we’ll send you instructions to reset it.\n\n"
        
        "6. Feedback and Support\n"
        "Q: How can I rate my driver?\n"
        "A: At the end of each ride, you’ll be prompted to rate your driver and leave feedback.\n\n"
        "Q: How do I report a problem with my ride?\n"
        "A: Go to 'Ride History,' select the ride with an issue, and tap 'Report an Issue.' Our support team will address it promptly.\n\n"
        "Q: How do I contact SAFE customer support?\n"
        "A: You can reach SAFE support by going to 'Help' in the app or visiting our website.\n\n"
        
        "7. Promotions and Referral Program\n"
        "Q: How do I apply a promo code?\n"
        "A: Enter the promo code in the 'Promotions' section before booking your ride. The discount will automatically apply if eligible.\n\n"
        "Q: Can I refer friends to SAFE?\n"
        "A: Yes! You can share your referral code with friends. When they sign up using your code and complete their first ride, you both earn rewards.\n\n"
        
        "8. Lost & Found\n"
        "Q: What should I do if I left an item in the car?\n"
        "A: Go to 'Ride History,' select the trip, and tap 'Report Lost Item.' You’ll be connected with the driver to arrange a return.\n\n"
        
        "For further questions or help, please visit our Help Center in the app or contact SAFE Support via email or chat."
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
                "role": "system", 
                "parts": [f"You are a helpful customer support chatbot for SAFE, a ride-sharing service. You have access to the following FAQ information:\n\n{how_it_works()}\n\nPlease use this information to help users with their questions about SAFE's services, policies, and features. Be concise. Respond in no more than 3 sentences. If you don't know the answer, politely say so and suggest contacting SAFE Support directly."]
            },
            {
                "role": "model",
                "parts": ["Hello! I'm SAFE's virtual assistant. How can I help you today? I can answer questions about booking rides, safety features, account management, and more."]
            }
        ]
        for message in messages:
            if message['role'] == 'user':
                history.append({"role": "user", "parts": [message['content']]})
            elif message['role'] == 'model':
                history.append({"role": "model", "parts": [message['content']]})

        print(history)
        chat = model.start_chat(history=history)
        
        response = chat.send_message(input_text)
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

