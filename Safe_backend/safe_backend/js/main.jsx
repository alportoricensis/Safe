import React, { useState, useEffect, useCallback, StrictMode } from "react";
import { createRoot } from "react-dom/client";
import PropTypes from "prop-types";
import Navbar from "./navbar";
import Queue from "./queue";
import MapView from "./map";
import Drivers from "./drivers";

// Create a root
const root = createRoot(document.getElementById("reactEntry"));

// Render the webpage into the index
root.render(
    <div className="rowFlex">
        <Navbar></Navbar>
        <Queue></Queue>
        <div className="mapDriverVert">
            <MapView></MapView>
            <Drivers></Drivers>
        </div>
    </div>
)