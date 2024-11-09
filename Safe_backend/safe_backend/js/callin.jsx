"use client";

import React, { useState, useEffect } from "react";
import {Autocomplete, LoadScript} from '@react-google-maps/api'

import LocationForm from "./location";

export default function CallInForm() {
    const rootUrl = "http://127.0.0.1:5000/";
    const servicesUrl = rootUrl + "api/v1/settings/services/"
    const pickupsUrl = rootUrl + "api/v1/settings/pickups/"
    const [services, setServices] = useState([]);
    const [pickups, setPickups] = useState([]);

    const [autocomplete, setAutocomplete] = useState(null);
    const [dropOffName, setDropOffName] = useState('')
    const [dropOffLat, setDropOffLat] = useState('')
    const [dropOffLng, setDropOffLng] = useState('')

    const bounds = {
        north: 43,
        south: 42,
        east: -83,
        west: -84,
    }

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
                var names = []
                for (let i = 0; i < arr.length; i++) {
                    names.push(arr[i]["serviceName"])
                }
                setServices(names);
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

    const handleLoad = (autocomplete) => {
        setAutocomplete(autocomplete);
    }

    const handlePlaceChanged = () => {
        if (autocomplete) {
            const place = autocomplete.getPlace();
            
            setDropOffName(place.name)
            setDropOffLat(place.geometry.location.lat())
            setDropOffLng(place.geometry.location.lng())
        }
    };

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
                        <input type="hidden" name="dropoffLat" value={dropOffLat}/>
                        <input type="hidden" name="dropoffLong" value={dropOffLng}/>
                        <select name="services" id="services">
                            {services.map((service) => <option value={service} key={service}>{service}</option>)}
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
                            {pickups.map((pickup) => <option value={pickup.name} key={pickup.name}>{pickup.name}</option>)}
                        </select>
                        <br></br>
                        <LoadScript googleMapsApiKey="AIzaSyB93jLylKO64g8nNQoxcPhcYTB1HsNL64g" libraries={['places']}>
                            <Autocomplete onLoad={handleLoad} onPlaceChanged={handlePlaceChanged} bounds={bounds} options={{strictBounds: true}}>
                                <input type="text" placeholder="Dropoff Location" name="dropoffLocation" value={dropOffName} onChange={(e) => setDropOffName(e.target.value)} />
                            </Autocomplete>
                        </LoadScript>
                        <br></br>
                        <input type="submit" name="callin" value="Add Passenger"/>
                    </form>
                </div>
            </div>
        </div>
        
    )

}