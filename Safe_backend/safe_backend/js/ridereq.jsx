"use client";

import React from "react";

export default function RideRequest(req) {
    const cancelRide = async (req_id) => {
        const request_url = "http://127.0.0.1:5000//api/v1/rides/passengers/" + req_id + "/"
        try { 
            const resp = await fetch(request_url, {
                method: "DELETE",
                headers: {
                    "Content-Type": "application/json"
                }
            });
        } catch(e) {
            console.log(e);
        }
    }

    return (
        <div className="rideWidget">
            <div className="rowFlex">
                <div className="colFlex">
                    Passenger Name:
                    <br></br>
                    Pickup Location:
                    <br></br>
                    Dropoff Location:
                    <br></br>
                    Assigned Driver:
                    <br></br>
                    Expected Pickup Time:
                    <br></br>
                    Expected Dropoff Time:
                    <br></br>
                </div>
                <div className="colFlex">
                    {req.passenger}
                    <br></br>
                    {req.pickup}
                    <br></br>
                    {req.dropoff}
                    <br></br>
                    {req.driver}
                    <br></br>
                    {req.ETP}
                    <br></br>
                    {req.ETA}
                    <br></br>
                    <button onClick={() => cancelRide(req.reqid)}>Cancel Ride</button>
                </div>
            </div>
        </div>
    )

}