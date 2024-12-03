import {useEffect, useState} from 'react';

import {Autocomplete, LoadScript} from '@react-google-maps/api';

import {Box, Button, FormControl, Input, InputAdornment, MenuItem, Select, Typography} from '@mui/material';

const apiKey = process.env.REACT_APP_GOOGLE_MAPS_API_KEY;

const Locations = () => {
    const [locations, setLocations] = useState({});
    const [services, setServices] = useState({});

    const [service, setService] = useState(null);
    const [autocomplete, setAutocomplete] = useState(null);
    const [locationName, setLocationName] = useState(null);
    const [locationLat, setLocationLat] = useState(null);
    const [locationLng, setLocationLng] = useState(null);

    const handleClick = async (event, serviceName, locationName) => {
        event.preventDefault();

        await fetch('http://18.191.14.26/api/v1/settings/pickups/', {method: 'delete', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({'serviceName': serviceName, 'locationName': locationName})})
            .catch(error => console.log(error));
    };

    const handleServiceChange = (event) => {
        setService(event.target.value);
    };

     const handleLoad = (autocomplete) => {
        setAutocomplete(autocomplete);
    };

    const handlePlaceChanged = () => {
        if (autocomplete) {
            const place = autocomplete.getPlace();
            
            setLocationName(place.name)
            setLocationLat(place.geometry.location.lat())
            setLocationLng(place.geometry.location.lng())
        }
    };

    useEffect(() => {
        fetch('http://18.191.14.26/api/v1/settings/pickups/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setLocations(json))
            .catch(error => console.log(error));

        fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));
    }, []);

    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw', height: '100vh'}} sx={{overflow: 'scroll'}}>
            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '80vw', minHeight: '80vh'}}>
                <Typography fontSize={'3em'}>
                    Service Locations
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'flex-start', flexWrap: 'wrap', width: '80vw'}}>
                    {locations ?
                        Object.entries(locations).map((service, index) => (
                            <>
                                <Typography fontSize={'2em'}>
                                    {service[0]}
                                </Typography>
                                <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center', flexWrap: 'wrap', width: '80vw'}}>
                                    {service[1].map((location, index) => (
                                        <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '25vw', height: '25vh'}}>
                                            <Typography fontSize={'1.5em'}>
                                                {location['name']}
                                            </Typography>
                                            <Typography fontSize={'1em'}>
                                                Latitude: {location['lat']}
                                            </Typography>
                                            <Typography fontSize={'1em'}>
                                                Longitude: {location['long']}
                                            </Typography>
                                            <Button onClick={(event) => handleClick(event, service[0], location['name'])} style={{color: 'black'}}>
                                                Delete
                                            </Button>
                                        </Box>
                                    ))}
                                </Box> 
                            </>
                        ))
                    :
                        null
                    }
                </Box>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center'}}>
                    <Typography fontSize={'1em'}>
                        Add a Service Location
                    </Typography>
                    <form action='http://18.191.14.26/api/v1/settings/pickups/?target=/settings/pickups' method='post' encType='multipart/form-data'>
                        <FormControl variant='standard' style={{backgroundColor: 'white', width: '20vw'}}>
                            <Select name='serviceName' startAdornment={<InputAdornment>Service:&nbsp;</InputAdornment>} value={service} onChange={handleServiceChange}>
                                {Object.entries(services).map((service, index) => (
                                    <MenuItem key={index} value={service[1]['serviceName']}>
                                        {service[1]['serviceName']}
                                    </MenuItem>
                                ))}
                            </Select>
                            <LoadScript googleMapsApiKey={apiKey} libraries={['places']}>
                                <Autocomplete onLoad={handleLoad} onPlaceChanged={handlePlaceChanged}>
                                    <Input name='locationName' type='text' startAdornment={<InputAdornment>Location Name:&nbsp;</InputAdornment>} value={locationName} onChange={(event) => setLocationName(event.target.value)} required />
                                </Autocomplete>
                            </LoadScript>
                            <Input name='locationLatitude' type='text' startAdornment={<InputAdornment>Latitude:&nbsp;</InputAdornment>} value={locationLat} onChange={(event) => setLocationLat(event.target.value)} required />
                            <Input name='locationLongitude' type='text' startAdornment={<InputAdornment>Longitude:&nbsp;</InputAdornment>} value={locationLng} onChange={(event) => setLocationLng(event.target.value)} required />
                            <Button type='submit' style={{color: 'black'}}>
                                Submit
                            </Button>
                        </FormControl>
                    </form>
                </Box>
            </Box>
        </Box>
    );
};

export default Locations;
