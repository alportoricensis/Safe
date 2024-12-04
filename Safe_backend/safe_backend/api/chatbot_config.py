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


def how_it_works():
    # Get all the Q&As for each service from the database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
    cur = conn.cursor()
    cur.execute(
        "SELECT * FROM faqs"
    )
    faqs = cur.fetchall()
    faq_str = "SAFE Ride-Sharing App: Freqquently Asked Questions\n\n"
    for faq in faqs:
        faq_str = faq_str + "Q: " + faq[1] + "\n" + "A: " + faq[2] + "\n\n"
    cur.close()
    conn.close()
    return faq_str

# System instruction for Gemini model
SYSTEM_INSTRUCTION = (
    f"You are a helpful customer support chatbot for SAFE, a ride-sharing service. "
    f"You have access to the following FAQ information:\n\n{how_it_works()}\n\n"
    f"Please use this information to help users with their questions about SAFE's services, policies, and features. "
    f"Be concise. Respond in no more than 3 sentences. If you don't know the answer, politely say so and suggest contacting SAFE Support directly. "
    f"You can help users book rides, cancel rides, and view their booking history. For booking history queries, use natural language to describe the pickup/dropoff locations and times."
    f"Respond in the same language as the user's message."
)
