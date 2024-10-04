"use client";

import React, { useState, useEffect } from "react";
import RideRequest from "./ridereq";
import CallInForm from "./callin";


export default function Queue() {
    const request_url = "http://127.0.0.1:5000/api/v1/rides/";
    const [requests, setRequests] = useState([]);

    const getReq = async () => {
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
                setRequests(arr);
            } else {
                var arr = [];
                setRequests(arr);
            }
        } catch(e) {
            console.log(e);
        }
    };

    // Set up a callback to call all active rides endpoint on the API every so often
    // Every four seconds, for now
    useEffect(() => {
        const interval = setInterval(() => {
            getReq()
        }, 4000);
        return () => clearInterval(interval);
    }, []);

    return (
            <div className="queue">
                <CallInForm></CallInForm>
                {requests.map((req) => RideRequest(req))}
            </div>
    )
}