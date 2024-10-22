"use client";

import React from "react";


export default function MapView() {
    return (
        <div className="map">
            <iframe src="https://www.google.com/maps/embed?pb=!1m14!1m12!1m3!1d11805.418405354596!2d-83.7287936!3d42.2922985!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!5e0!3m2!1sen!2sus!4v1728010618143!5m2!1sen!2sus" className="map" style={{border: 0}} allowFullScreen={true} loading="lazy" referrerPolicy="no-referrer-when-downgrade"></iframe>
        </div>
    )
}