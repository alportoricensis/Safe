import psycopg2

INITIAL_GREETINGS = (
    "Hello! I'm SAFE's virtual assistant. How can I help you today? "
    "I can answer questions about booking rides, safety features, account management, and more."
)

ASK_DROP_OFF = "Could you please specify where you would like to be dropped off?"

CONVERT_SPOT_TO_COORDINATES = (
    "I can help convert the spot or building name you've provided into latitude and longitude coordinates. "
    "Please provide the full address or the name of the building."
)
ASK_RIDE_ID = "Could you please provide the ride ID you wish to cancel?"

CANCELLATION_SUCCESS = "Your ride has been successfully canceled."

CANCELLATION_FAILURE = "I'm sorry, I couldn't cancel your ride. Please ensure the ride ID is correct or contact support."

def get_available_services():
    """Get list of available services directly from database.
    
    Returns:
        list: List of service names
    """
    conn = psycopg2.connect(database="safe_backend", user="safe", password="", port="5432")
    cur = conn.cursor()
    cur.execute("SELECT service_name FROM services")
    services = [service[0] for service in cur.fetchall()]
    cur.close()
    conn.close()
    return services

def get_available_pickups():
    """Get list of available pickup locations directly from database.
    
    Returns:
        list: List of pickup location names
    """
    conn = psycopg2.connect(database="safe_backend", user="safe", password="", port="5432")
    cur = conn.cursor()
    cur.execute("SELECT loc_name FROM locations WHERE isPickup = true")
    pickups = [loc[0] for loc in cur.fetchall()]
    cur.close()
    conn.close()
    return pickups


book_ride_function = {
    "function_declarations": [
        {
            "name": "book_ride",
            "description": "Book a ride by providing pickup and dropoff locations, service name, and user ID.",
            "parameters": {
                "type": "object",
                "properties": {
                    "pickup": {
                        "type": "string",
                        "description": f"The address or name of the pickup location. Available options are: {get_available_pickups()}"
                    },
                    "dropoff": {
                        "type": "string",
                        "description": "The address or name of the dropoff location."
                    },
                    "service": {
                        "type": "string",
                        "description": f"The name of the service being requested. Available options are: {get_available_services()}"
                    }
                },
                "required": ["pickup", "dropoff", "service"]
            }
        }
    ]
}



cancel_ride_function = {
    "function_declarations": [
        {
            "name": "cancel_ride",
            "description": "Cancel an existing ride using the ride ID.",
            "parameters": {
                "type": "object",
                "properties": {
                    "ride_id": {
                        "type": "string",
                        "description": "The unique identifier of the ride to cancel."
                    }
                },
                "required": ["ride_id"]
            }
        }
    ]
}

get_bookings_function = {
    "function_declarations": [
        {
            "name": "get_user_bookings",
            "description": "Retrieve a user's past ride bookings (defaults to last 5 bookings if limit not specified)",
            "parameters": {
                "type": "object",
                "properties": {
                    "limit": {
                        "type": "integer",
                        "description": "Maximum number of bookings to return"
                    }
                },
                "required": []
            }
        }
    ]
}

# System instruction for Gemini model
SYSTEM_INSTRUCTION = (
    "You are a helpful customer support chatbot for SAFE, a ride-sharing service. "
    "You have access to the following FAQ information:\n\n{faq}\n\n"
    "Please use this information to help users with their questions about SAFE's services, policies, and features. "
    "Be concise. Respond in no more than 3 sentences. If you don't know the answer, politely say so and suggest contacting SAFE Support directly. "
    "You can help users book rides, cancel rides, and view their booking history. For booking history queries, use natural language to describe the pickup/dropoff locations and times."
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
