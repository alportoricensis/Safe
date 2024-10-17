"use client";

import React from "react";

export default function CallInForm(req) {
    const request_url = "http://127.0.0.1:5000/api/v1/rides/";
    const curr_url = "http://127.0.0.1:5000/";

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
                </div>
                <div className="colFlex">
                    <form action="/api/v1/rides/" target="hiddenFrame" method="post" encType="multipart/form-data">
                        <input type="hidden" name="operation" value="create"/>
                        <input type="text" name="passenger_name" required/>
                        <br></br>
                        <input type="text" name="pickup" required/>
                        <br></br>
                        <input type="text" name="dropoff" required/>
                        <br></br>
                        <input type="submit" name="callin" value="Add Passenger"/>
                    </form>
                </div>
            </div>
        </div>
    )

}