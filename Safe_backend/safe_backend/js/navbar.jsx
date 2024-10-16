"use client";

import React from "react";


export default function Navbar() {
    return (
            <div className="navMenu">
                <a href="/"><button>Home</button></a>
                <a href="/settings"><button>Settings</button></a>
                <a href="/logout"><button>Logout</button></a>
            </div>
    )
}