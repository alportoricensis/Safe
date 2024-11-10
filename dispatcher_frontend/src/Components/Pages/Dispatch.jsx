import {useEffect, useState} from 'react';
import {useSearchParams} from 'react-router-dom';

import {Autocomplete, GoogleMap, LoadScript, Marker} from '@react-google-maps/api';

import {Box, Button, FormControl, Input, InputAdornment, MenuItem, Select, Typography} from '@mui/material';


const Dispatch = () => {
    const [searchParams] = useSearchParams();

    const [services, setServices] = useState({});
    const [pickups, setPickups] = useState({});
    const [rides, setRides] = useState({});
    const [vehicles, setVehicles] = useState({});

    const [serviceName, setServiceName] = useState(searchParams.get('service'));
    
    const [pickupName, setPickupName] = useState(null);
    const [pickupLat, setPickupLat] = useState(null);
    const [pickupLng, setPickupLng] = useState(null);

    const [autocomplete, setAutocomplete] = useState(null);
    const [dropOffName, setDropOffName] = useState(null)
    const [dropOffLat, setDropOffLat] = useState(null)
    const [dropOffLng, setDropOffLng] = useState(null)

    const [center, setCenter] = useState({
        lat: 42.277058,
        lng: -83.7382075
    });

    const handleServiceChange = (event) => {
        setServiceName(event.target.value);
    };

    const handlePickupChange = (event) => {
        try {
            const pickup = pickups[serviceName].filter((pickup) => pickup.name === event.target.value)[0]

            setPickupName(pickup.name)
            setPickupLat(pickup.lat)
            setPickupLng(pickup.long)

            console.log(pickup)
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

            setCenter({
                lat: place.geometry.location.lat(),
                lng: place.geometry.location.lng()
            })
        }
    };

    const handleMapClick = (event) => {
        setDropOffName('Dropped Pin')
        setDropOffLat(event.latLng.lat())
        setDropOffLng(event.latLng.lng())
    };

    const handleCancelRide = async (event, ride) => {
        event.preventDefault();

         await fetch(`http://35.2.2.224:5000/api/v1/rides/passengers/${ride['reqid']}/`, {method: 'delete', headers: {'Content-Type': 'application/json'}})
            .catch(error => console.log(error));
    };

    useEffect(() => {
        fetch('http://35.2.2.224:5000/api/v1/settings/services/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));

        fetch('http://35.2.2.224:5000/api/v1/settings/pickups/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setPickups(json))
            .catch(error => console.log(error));

        fetch('http://35.2.2.224:5000/api/v1/rides/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setRides(json))
                .catch(error => console.log(error));

        fetch('http://35.2.2.224:5000/api/v1/vehicles/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setVehicles(json))
                .catch(error => console.log(error));
    }, []);

    useEffect(() => {
        const intervalId = setInterval(() => {
            fetch('http://35.2.2.224:5000/api/v1/rides/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setRides(json))
                .catch(error => console.log(error));

            fetch('http://35.2.2.224:5000/api/v1/vehicles/', {method: 'get', headers: {'Content-Type': 'application/json'}})
                .then(response => response.json())
                .then(json => setVehicles(json))
                .catch(error => console.log(error));
            }, 10000);

        return () => clearInterval(intervalId);
    }, []);

    console.log(vehicles)

    return (
        <LoadScript googleMapsApiKey="AIzaSyB93jLylKO64g8nNQoxcPhcYTB1HsNL64g" libraries={['places']}>
            <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'center', alignItems: 'center', backgroundColor: 'rgb(2, 28, 52)', width: '90vw'}}>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '20vw', height: '100vh'}}>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '20vw'}} sx={{padding: '1vh'}}>
                        <Typography fontSize={'1.5em'} color={'white'}>
                            Create a Booking
                        </Typography>
                    </Box>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', backgroundColor: 'white', width: '18vw'}} sx={{paddingLeft: '1vw', paddingRight: '1vw', paddingTop: '1vh', borderRadius: 5}}>
                        <form action='http://35.2.2.224:5000/api/v1/rides/' method='post' encType='multipart/form-data'>
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
                                    {serviceName && Object.keys(pickups).length > 0 ?
                                        pickups[serviceName].map((pickup, index) => (
                                            <MenuItem key={index} value={pickup.name}>
                                                {pickup.name}
                                            </MenuItem>
                                        ))
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
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '20vw'}} sx={{padding: '1vh'}}>
                        <Typography fontSize={'1.5em'} color={'white'}>
                            Active Rides
                        </Typography>
                    </Box>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '20vw'}} sx={{overflow: 'scroll'}}>
                        {rides ?
                            Object.entries(rides).map((ride, index) => (
                                <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'flex-start', backgroundColor: 'white', width: '18vw'}} sx={{padding: '1vw', marginBottom: '1vh', borderRadius: 5}}>
                                    <Typography fontSize={'1em'}>
                                        Passenger: {ride[1]['passenger']}
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
                            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', backgroundColor: 'white', width: '18vw'}} sx={{padding: '1vw', borderRadius: 5}}>
                                <Typography fontSize={'1em'}>
                                    No Active Rides
                                </Typography>
                            </Box>
                        }
                    </Box>
                </Box>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', backgroundColor: 'rgb(3, 38, 72)', width: '70vw', height: '100vh'}}>
                    <GoogleMap mapContainerStyle={{width: '70vw', height: '70vh'}} center={center} zoom={dropOffLat ? 15 : 13} onClick={handleMapClick}>
                        {pickupName && <Marker position={{lat: pickupLat, lng: pickupLng}} />}
                        {dropOffName && <Marker position={{lat: dropOffLat, lng: dropOffLng}} />}
                    </GoogleMap>
                    <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '20vw', height: '5vh'}} sx={{padding: '1vh'}}>
                        <Typography fontSize={'1.5em'} color={'white'}>
                            Active Vehicles
                        </Typography>
                    </Box>
                    <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'flex-start', width: '70vw', height: '25vh'}} sx={{overflow: 'scroll'}}>
                        {vehicles ?
                            Object.entries(vehicles).map((vehicle, index) => (
                                <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'flex-start', textAlign: 'left', backgroundColor: 'white', width: '18vw'}} sx={{padding: '1vw', marginRight: '1vw', borderRadius: 10}}>
                                    <Typography fontSize={'1.25em'} style={{alignSelf: 'center'}}>
                                        {vehicle[1]['vehicle_id']}
                                    </Typography>
                                    {vehicle[1]['itinerary'].length > 0 ?    
                                        vehicle[1]['itinerary'].filter(item => item.isPickup).map((passenger, index) => (
                                            <>
                                                <Typography fontSize={'1em'} style={{alignSelf: 'center'}}>
                                                    {vehicle[1]['itinerary'].length / 2} Assigned Rides
                                                </Typography>
                                                <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'flex-start'}}>
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
                                            </>
                                        ))
                                    :
                                        <Typography fontSize={'1em'} style={{alignSelf: 'center'}}>
                                            No Assigned Rides
                                        </Typography>
                                    }
                                </Box>
                            ))
                        :
                            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', backgroundColor: 'white', width: '18vw'}} sx={{padding: '1vw', borderRadius: 5}}>
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