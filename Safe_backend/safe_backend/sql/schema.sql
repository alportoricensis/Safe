PRAGMA foreign_keys = ON;


CREATE TABLE Rides(
    ride_id SERIAL PRIMARY KEY,
    pickup_lat REAL,
    pickup_long REAL,
    dropoff_long REAL,
    dropoff_lat REAL,
    status VARCHAR(20) NOT NULL,
    vehicle INTEGER,
    ride_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY vehicle REFERENCES Vehicles(vehicle_id)
);


CREATE TABLE Vehicles(
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_name VARCHAR(20) NOT NULL,
    capacity INTEGER NOT NULL,
    vrange INTEGER NOT NULL
);


CREATE TABLE Locations(latitude REAL NOT NULL, longitude REAL NOT NULL, loc_name VARCHAR(20) NOT NULL, PRIMARY KEY(latitude, longitude);