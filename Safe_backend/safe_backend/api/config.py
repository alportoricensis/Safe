"""Global variables and configurations for Safe's backend"""
from apscheduler.schedulers.background import BackgroundScheduler

# Globals
# VEHICLE_QUEUES maps a vehicle_id to the vehicle object.
VEHICLES = {}
# RIDE_REQUESTS is a dictionary of all currenty active ride ride requests
REQUESTS = {}
# Scheduler for ride requests
scheduler = BackgroundScheduler()
scheduler.start()
