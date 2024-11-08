"use client";

import React, {useState} from "react";
import {Autocomplete, LoadScript} from '@react-google-maps/api'

export default function LocationForm() {
    const [autocomplete, setAutocomplete] = useState(null);
    const [locationName, setLocationName] = useState('')
    const [locationLat, setLocationLat] = useState('')
    const [locationLng, setLocationLng] = useState('')

    const bounds = {
        north: 43,
        south: 42,
        east: -83,
        west: -84,
    }

    const handleLoad = (autocomplete) => {
        setAutocomplete(autocomplete);
    }

    const handlePlaceChanged = () => {
        if (autocomplete) {
            const place = autocomplete.getPlace();
            
            setLocationName(place.name)
            setLocationLat(place.geometry.location.lat())
            setLocationLng(place.geometry.location.lng())
        }
    };
    
    return (
        <form action="/api/v1/settings/pickups/?target=/settings/locations" method="post" encType="multipart/form-data">
            <LoadScript googleMapsApiKey="AIzaSyB93jLylKO64g8nNQoxcPhcYTB1HsNL64g" libraries={['places']}>
                <Autocomplete onLoad={handleLoad} onPlaceChanged={handlePlaceChanged} bounds={bounds} options={{strictBounds: true}}>
                    <input type="text" placeholder="Location Name" name="locationName" value={locationName}  onChange={(e) => setLocationName(e.target.value)} />
                </Autocomplete>
            </LoadScript>
            Latitude
            <input type="text" name="locationLatitude" value={locationLat} onChange={(e) => setLocationLat(e.target.value)} required/>
            <br></br>
            Longitude
            <input type="text" name="locationLongitude" value={locationLng} onChange={(e) => setLocationLng(e.target.value)} required/>
            <br></br>
            Accept pick-ups at this location?
            <input type="checkbox" name="isPickup"/>
            <br></br>
            Accept drop-offs at this location?
            <input type="checkbox" name="isDropoff"/>
            <br></br>
            <input type="submit" name="submit" value="Create Pick-up Location"/>
        </form>
    )
}