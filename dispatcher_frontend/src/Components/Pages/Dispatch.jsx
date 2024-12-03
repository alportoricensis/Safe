import {useEffect, useState} from 'react';
import {useSearchParams} from 'react-router-dom';

import {Autocomplete, GoogleMap, LoadScript, Marker} from '@react-google-maps/api';

import {Box, Button, FormControl, Input, InputAdornment, MenuItem, Select, Typography} from '@mui/material';

const apiKey = process.env.REACT_APP_GOOGLE_MAPS_API_KEY;

const Dispatch = () => {
    const [searchParams] = useSearchParams();

    const [services, setServices] = useState({});
    const [pickups, setPickups] = useState({});
    const [ranges, setRanges] = useState({});
    const [rides, setRides] = useState({});
    const [vehicles, setVehicles] = useState({});

    const [serviceName, setServiceName] = useState(searchParams.get('service'));
    
    const [pickupName, setPickupName] = useState(null);
    // const [pickupLat, setPickupLat] = useState(null);
    // const [pickupLng, setPickupLng] = useState(null);

    const [autocomplete, setAutocomplete] = useState(null);
    const [dropOffName, setDropOffName] = useState(null);
    const [dropOffLat, setDropOffLat] = useState(null);
    const [dropOffLng, setDropOffLng] = useState(null);

    const carIcon = window.google ? {
        url: 'https://images.vexels.com/media/users/3/154573/isolated/preview/bd08e000a449288c914d851cb9dae110-hatchback-car-top-view-silhouette-by-vexels.png',
        scaledSize: new window.google.maps.Size(50, 50)
    } : null

    const handleRanges = (json) => {
        const range = {};

        json['ranges'].forEach((service) => (
            range[service['service_name']] = {
                'lat': service['lat'],
                'lng': service['long']
            }
        ));
        
        setRanges(range);
    };

    const handleServiceChange = (event) => {
        setServiceName(event.target.value);
    };

    const handlePickupChange = (event) => {
        try {
            const pickup = pickups[serviceName].filter((pickup) => pickup.name === event.target.value)[0]

            setPickupName(pickup.name)
            // setPickupLat(pickup.lat)
            // setPickupLng(pickup.long)
        }

        catch {
            
        }
    };

    const handleLoad = (autocomplete) => {
        setAutocomplete(autocomplete);
    };

    const handleDropOffChange = () => {
        if (autocomplete) {
            const place = autocomplete.getPlace();
            
            setDropOffName(place.name)
            setDropOffLat(place.geometry.location.lat())
            setDropOffLng(place.geometry.location.lng())
        }
    };

    const handleCancelRide = async (event, ride) => {
        event.preventDefault();

         await fetch(`http://18.191.14.26/api/v1/rides/passengers/${ride['reqid']}/`, {method: 'delete', headers: {'Content-Type': 'application/json'}})
            .catch(error => console.log(error));
    };

    useEffect(() => {
        fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));

        fetch('http://18.191.14.26/api/v1/settings/pickups/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setPickups(json))
            .catch(error => console.log(error));

        fetch('http://18.191.14.26/api/v1/settings/ranges/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => handleRanges(json))
            .catch(error => console.log(error));

        fetch('http://18.191.14.26/api/v1/rides/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setRides(json))
                .catch(error => console.log(error));

        fetch('http://18.191.14.26/api/v1/vehicles/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setVehicles(json))
                .catch(error => console.log(error));
    }, []);

    console.log(vehicles)

    useEffect(() => {
        const intervalId = setInterval(() => {
            fetch('http://18.191.14.26/api/v1/rides/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setRides(json))
                .catch(error => console.log(error));

            fetch('http://18.191.14.26/api/v1/vehicles/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setVehicles(json))
                .catch(error => console.log(error));
            }, 10000);

        return () => clearInterval(intervalId);
    }, []);

    return (
        <LoadScript googleMapsApiKey={apiKey} libraries={['places']}>
            <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'center', alignItems: 'center', backgroundColor: 'rgb(2, 28, 52)', width: '90vw'}}>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '20vw', height: '100vh'}}>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '18vw'}} sx={{padding: '1vw'}}>
                        <Typography fontSize={'1.5em'} color={'white'}>
                            Create a Booking
                        </Typography>
                    </Box>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', backgroundColor: 'white', width: '17vw'}} sx={{paddingLeft: '1vw', paddingRight: '1vw', paddingTop: '1.5vh', borderRadius: 5}}>
                        <form action='http://18.191.14.26/api/v1/rides/' method='post' encType='multipart/form-data'>
                            <FormControl variant='standard' style={{width: '18vw'}}>
                                <Select name='serviceName' startAdornment={<InputAdornment>Service:&nbsp;</InputAdornment>} value={serviceName} onChange={handleServiceChange}>
                                    {Object.entries(services).map((service, index) => (
                                        <MenuItem key={index} value={service[1]['serviceName']}>
                                            {service[1]['serviceName']}
                                        </MenuItem>
                                    ))}
                                </Select>
                                <Input name='passengerFirstName' type='text' startAdornment={<InputAdornment>First Name:&nbsp;</InputAdornment>} required />
                                <Input name='passengerLastName' type='text' startAdornment={<InputAdornment>Last Name:&nbsp;</InputAdornment>} required />
                                <Input name='passengerPhoneNumber' type='text' startAdornment={<InputAdornment>Phone Number:&nbsp;</InputAdornment>} required />
                                <Input name='numPassengers' type='number' startAdornment={<InputAdornment>Number of Passengers:&nbsp;</InputAdornment>} required />
                                <Select name='pickupLocation' type='text' startAdornment={<InputAdornment>Pickup:&nbsp;</InputAdornment>} value={pickupName} onChange={handlePickupChange}>
                                    {serviceName ?
                                        pickups[serviceName] ?
                                            pickups[serviceName].map((pickup, index) => (
                                                <MenuItem key={index} value={pickup.name}>
                                                    {pickup.name}
                                                </MenuItem>
                                            ))
                                        :
                                            <Typography align='center'>
                                                No Locations Registered
                                            </Typography>
                                    :
                                        <Typography align='center'>
                                            Please Select a Service
                                        </Typography>
                                    }
                                </Select>
                                <Autocomplete onLoad={handleLoad} onPlaceChanged={handleDropOffChange}>
                                    <Input name='dropoffLocation' type='text' startAdornment={<InputAdornment>Drop-off:&nbsp;</InputAdornment>} value={dropOffName} onChange={(e) => setDropOffName(e.target.value)} fullWidth required />
                                </Autocomplete>
                                <Button type='submit' style={{color: 'black'}}>
                                    Submit
                                </Button>
                                <input name='rideOrigin' type='hidden' value='callIn' />
                                <input name='dropoffLat' type='hidden' value={dropOffLat}/>
                                <input name='dropoffLong' type='hidden' value={dropOffLng}/>
                            </FormControl>
                        </form>
                    </Box>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '18vw'}} sx={{padding: '1vw'}}>
                        <Typography fontSize={'1.5em'} color={'white'}>
                            Active Rides
                        </Typography>
                    </Box>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '20vw'}} sx={{overflow: 'scroll'}}>
                        {rides ?
                            Object.entries(rides).map((ride, index) => (
                                <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'flex-start', backgroundColor: 'white', width: '17vw'}} sx={{paddingLeft: '1vw', paddingRight: '1vw', paddingTop: '1.5vh', marginBottom: '1vh', borderRadius: 5}}>
                                    <Typography fontSize={'1em'}>
                                        Passenger: {ride[1]['passenger']}
                                    </Typography>
                                    <Typography fontSize={'1em'}>
                                        Number of Passengers: {ride[1]['numPassengers']}
                                    </Typography>
                                    <Typography fontSize={'1em'}>
                                        Contact: {ride[1]['phone']}
                                    </Typography>
                                    <Typography fontSize={'1em'}>
                                        Driver: {ride[1]['driver']}
                                    </Typography>
                                    <Typography fontSize={'1em'}>
                                        Pickup: {ride[1]['pickup']}
                                    </Typography>
                                    <Typography fontSize={'1em'}>
                                        Drop-off: {ride[1]['dropoff']}
                                    </Typography>
                                    <Typography fontSize={'1em'}>
                                        ETP: {ride[1]['ETP'] ? new Date(ride[1]['ETP']).toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : 'Not Assigned'}
                                    </Typography>
                                    <Typography fontSize={'1em'}>
                                        ETA: {ride[1]['ETA'] ? new Date(ride[1]['ETA']).toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : 'Not Assigned'}
                                    </Typography>
                                    <Button style={{color: 'black', alignSelf: 'center'}} onClick={(event) => handleCancelRide(event, ride[1])}>
                                        Cancel Ride
                                    </Button>
                                </Box>
                            ))
                        :
                            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', backgroundColor: 'white', width: '17vw'}} sx={{padding: '1vw', borderRadius: 5}}>
                                <Typography fontSize={'1em'}>
                                    No Active Rides
                                </Typography>
                            </Box>
                        }
                    </Box>
                </Box>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', backgroundColor: 'rgb(3, 38, 72)', width: '70vw', height: '100vh'}}>
                    {serviceName ?
                        <GoogleMap mapContainerStyle={{width: '70vw', height: '70vh'}} center={ranges[serviceName]} zoom={13}>
                            {vehicles ?
                                Object.entries(vehicles).map((vehicle, index) => (
                                    <Marker key={index} position={{lat: vehicle[1]['lat'], lng: vehicle[1]['long']}} icon={carIcon} label={{text: vehicle[1]['vehicle_id'], color: 'red', fontSize: '1em', fontWeight: 'bold'}} />
                                    
                                ))
                            :
                                null
                            }
                        </GoogleMap>
                    :
                        null
                    }
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center'}} sx={{padding: '1vw'}}>
                        <Typography fontSize={'1.5em'} color={'white'}>
                            Active Vehicles
                        </Typography>
                    </Box>
                    <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'flex-start', width: '69vw', height: '25vh'}} sx={{overflow: 'scroll', paddingLeft: '0.5vw', paddingRight: '0.5vw'}}>
                        {vehicles ?
                            Object.entries(vehicles).map((vehicle, index) => (
                                <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'flex-start', textAlign: 'left', backgroundColor: 'white', width: '17vw'}} sx={{paddingLeft: '1vw', paddingRight: '1vw', paddingTop: '1.5vh', paddingBottom: '1vh', marginRight: '1vw', borderRadius: 5}}>
                                    <Typography fontSize={'1.25em'} style={{alignSelf: 'center'}}>
                                        {vehicle[1]['vehicle_id']}
                                    </Typography>
                                    <Typography fontSize={'1em'} style={{alignSelf: 'center'}}>
                                        {vehicle[1]['itinerary'].length} Assigned Ride{vehicle[1]['itinerary'].length === 1 ? null: 's'}
                                    </Typography>
                                    {vehicle[1]['itinerary'].length > 0 ?    
                                        vehicle[1]['itinerary'].filter(item => item.isPickup).map((passenger, index) => (
                                            <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'flex-start'}} sx={{marginTop: '1vh'}}>
                                                <Typography fontSize={'1em'}>
                                                    Passenger: {passenger['passenger']}
                                                </Typography>
                                                <Typography fontSize={'1em'}>
                                                    Pickup: {passenger['pickup']}
                                                </Typography>
                                                <Typography fontSize={'1em'}>
                                                    Drop-off: {passenger['dropoff']}
                                                </Typography>
                                                <Typography fontSize={'1em'}>
                                                    ETP: {passenger['ETP'] ? new Date(passenger['ETP']).toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : 'Not Assigned'}
                                                </Typography>
                                                <Typography fontSize={'1em'}>
                                                    ETA: {passenger['ETA'] ? new Date(passenger['ETA']).toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : 'Not Assigned'}
                                                </Typography>
                                            </Box>
                                        ))
                                    :
                                        null
                                    }
                                </Box>
                            ))
                        :
                            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', backgroundColor: 'white', width: '17vw'}} sx={{padding: '1vw', borderRadius: 5}}>
                                <Typography fontSize={'1em'}>
                                    No Active Vehicles
                                </Typography>
                            </Box>
                        }
                    </Box>
                </Box>
            </Box>
        </LoadScript>
    );
};

export default Dispatch;
