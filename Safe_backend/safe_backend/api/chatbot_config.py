INITIAL_GREETINGS = (
    "Hello! I'm SAFE's virtual assistant. How can I help you today? "
    "I can answer questions about booking rides, safety features, account management, and more."
)

ASK_DROP_OFF = "Could you please specify where you would like to be dropped off?"

CONVERT_SPOT_TO_COORDINATES = (
    "I can help convert the spot or building name you've provided into latitude and longitude coordinates. "
    "Please provide the full address or the name of the building."
)



# Function description for geocoding an address or spot name
GEOCODE_ADDRESS_FUNCTION_DESCRIPTION = {
    "name": "geocode_address",
    "description": "Convert an address or spot name into latitude and longitude coordinates. Only invoke this function if a building is provided.",
    "parameters": {
        "type": "object",
        "properties": {
            "address": {
                "type": "string",
                "description": "The full address or spot name to geocode."
            }
        },
        "required": ["address"]
    }
}

# System instruction for Gemini model
SYSTEM_INSTRUCTION = (
    "You are a helpful customer support chatbot for SAFE, a ride-sharing service. "
    "You have access to the following FAQ information:\n\n{faq}\n\n"
    "Please use this information to help users with their questions about SAFE's services, policies, and features. "
    "Be concise. Respond in no more than 3 sentences. If you don't know the answer, politely say so and suggest contacting SAFE Support directly."
    "You also have the ability to use function calling to book rides. IF the user requests to book a ride, such as 'I want to book a ride to the Big House' or 'Book a ride to 1687 Broadway St' you have the ability to genreate params to feed into a rest api. If the user is vague in their drop-off location, dont invoke a function call, instead return 'please provide a address', if you have trouble converting a buidling name to an address, then just ask the user for an address."
)
def how_it_works():
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
        
        "For additional support or questions, use the in-app chatbot accessible through the Account tab."
    )
