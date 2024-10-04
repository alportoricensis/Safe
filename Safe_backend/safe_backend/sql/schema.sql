PRAGMA foreign_keys = ON;


CREATE TABLE Rides(
    pickup_lat REAL,
    pickup_long REAL,
    dropoff_long REAL,
    dropoff_lat REAL,
    status VARCHAR(20) NOT NULL,
    vehicle INTEGER,
    ride_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY vehicle REFERENCES Vehicles(vehicle_id),
    INTEGER PRIMARY KEY
);


CREATE TABLE Vehicles(
    vehicle_name VARCHAR(20) NOT NULL,
    vehicle_id INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    vrange INTEGER NOT NULL
)