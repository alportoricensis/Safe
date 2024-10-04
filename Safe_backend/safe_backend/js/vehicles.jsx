"use client";

import React, { useState, useEffect } from "react";
import RideRequest from "./ridereq";

export default function Vehicle(vehicle) {
    // TODO - This is redundant since queue also calls the API
    // Can have less data transfer by passing down data from queue
    var vehicleItinerary = vehicle.itinerary;

    // Return vehicle widget
    return (
        <div className="vehicleWidget">
            {vehicle.vehicle_id}
            {vehicleItinerary.map((req) => RideRequest(req))}
        </div>
    )

}

