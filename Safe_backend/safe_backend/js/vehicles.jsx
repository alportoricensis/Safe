"use client";

import React, { useState, useEffect } from "react";

export default function Vehicle(vehicle) {
    // TODO - This is redundant since queue also calls the API
    // Can have less data transfer by passing down data from queue
    var vehicleItinerary = vehicle.itinerary;

    function ItineraryRide(req) {
        var type = (req.isPickup) ? "Picking Up" : "Dropping Off"
        var location = (req.isPickup) ? req.pickup : req.dropoff
        return (
            <div className="rideWidget">
                <b>{req.passenger}</b> <br></br>
                {location} <br></br>
                {type}
            </div>
        )
    }

    // Return vehicle widget
    return (
        <div className="vehicleWidget">
            <br></br>
            {vehicle.vehicle_id}
            <br></br>
            {vehicle.lat}, {vehicle.long}
            <br></br>
            Vehicle Itinerary:
            {vehicleItinerary.map((req) => ItineraryRide(req))}
        </div>
    )

}

