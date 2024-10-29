"use client";

import React, { useState, useEffect } from "react";

export default function CallInForm() {
    const rootUrl = "http://127.0.0.1:5000/";
    const servicesUrl = rootUrl + "api/v1/settings/services/"
    const pickupsUrl = rootUrl + "api/v1/settings/pickups/"
    const [services, setServices] = useState([]);
    const [pickups, setPickups] = useState([]);

    const getServices = async () => {
        try {
            const resp = await fetch(servicesUrl, {
                method: "GET",
                headers: {
                    "Content-Type": "application/json"
                }
            });
            const data = await resp.json();
            if (data !== null) {
                var arr = Object.values(data);
                setServices(arr[0]);
            } else {
                var arr = [];
                setServices(arr);
            }
        } catch(e) {
            console.log(e);
        }
    };

    // Get pickup locations
    const getPickups = async () => {
        try {
            const resp = await fetch(pickupsUrl, {
                method: "GET",
                headers: {
                    "Content-Type": "application/json"
                }
            });
            const data = await resp.json();
            if (data !== null) {
                var arr = Object.values(data["locations"]);
                setPickups(arr);
            } else {
                var arr = [];
                setPickups(arr);
            }
        } catch(e) {
            console.log(e);
        }
    }

    // Set up a callback to call all active services endpoint on the API every so often
    // Every four seconds, for now
    useEffect(() => {
        const interval = setInterval(() => {
            getServices()
            getPickups()
        }, 4000);
        return () => clearInterval(interval);
    }, []);
    
    return (
        <div className="rideWidget">
            <div className="rowFlex">
                <div className="colFlex">
                    <h3>Create a Booking</h3>
                    <form action="/api/v1/rides/" target="hiddenFrame" method="post" encType="multipart/form-data">
                        <input type="hidden" name="rideOrigin" value="callIn"/>
                        <select name="services" id="services">
                            {services.map((service) => <option value={service}>{service}</option>)}
                        </select>
                        <br></br>
                        <input type="text" placeholder="First Name" name="passengerFirstName" required/>
                        <br></br>
                        <input type="text" placeholder="Last Name" name="passengerLastName" required/>
                        <br></br>
                        <input type="text" placeholder="Phone Number" name="passengerPhoneNumber" required/>
                        <br></br>
                        <input type="number" placeholder="Number of Passengers" name="numPassengers" required/>
                        <br></br>
                        <select name="pickupLocation" id="pickupLocation">
                            {pickups.map((pickup) => <option value={pickup.name}>{pickup.name}</option>)}
                        </select>
                        <br></br>
                        <input type="text" placeholder="Dropoff Location" name="dropoffLocation" required/>
                        <br></br>
                        <input type="submit" name="callin" value="Add Passenger"/>
                    </form>
                </div>
            </div>
        </div>
    )

}