"use client";

import React, { useState, useEffect } from "react";
import Vehicle from "./vehicles";


export default function Drivers() {
    // Set up REACT state
    const request_url = "http://127.0.0.1:5000/api/v1/vehicles/"
    const [vehicles, setVehicles] = useState([]);

    // Fetch active vehicles from the API
    const getVehicles = async () => {
        try {
            const resp = await fetch(request_url, {
                method: "GET",
                headers: {
                    "Content-Type": "application/json"
                }
            });
            const data = await resp.json();
            if (data !== null) {
                var arr = Object.values(data);
                setVehicles(arr);
            } else {
                var arr = [];
                setVehicles(arr);
            }
        } catch(e) {
            console.log(e);
        }
    }

    // Set up a callback to call all active rides endpoint on the API every so often
    // Every four seconds, for now
    useEffect(() => {
        const interval = setInterval(() => {
            getVehicles()
        }, 4000);
        return () => clearInterval(interval);
    }, []);

    // For active vehicles, fetch vehicle itineraries from API every so often

    return (
            <div className="driverMenu">
                {vehicles.map((vehicle) => Vehicle(vehicle))}
            </div>
    )
}