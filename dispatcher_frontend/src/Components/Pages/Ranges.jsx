import {useEffect, useState} from 'react';

import {Box, Button, FormControl, Input, InputAdornment, MenuItem, Select, Typography} from '@mui/material';


const Ranges = () => {
    const [ranges, setRanges] = useState({});
    const [services, setServices] = useState({});

    const [service, setService] = useState(null);

    const handleClick = async (event, serviceName) => {
        event.preventDefault();

        await fetch('http://18.191.14.26/api/v1/settings/ranges/', {method: 'delete', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({'serviceName': serviceName})})
            .catch(error => console.log(error));
    };

    const handleServiceChange = (event) => {
        setService(event.target.value);
    };
    
    useEffect(() => {
        fetch('http://18.191.14.26/api/v1/settings/ranges/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setRanges(json['ranges']))
            .catch(error => console.log(error));

        fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'get', headers: {"Content-Type": "application/json"}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));
    }, []);

    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw', height: '100vh'}} sx={{overflow: 'scroll'}}>
            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '80vw', minHeight: '80vh'}}>
                <Typography fontSize={'3em'}>
                    Service Ranges
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center', flexWrap: 'wrap', width: '80vw'}}>
                    {Object.entries(ranges).map((range, index) => (
                        <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '20vw', height: '50vh'}}>
                            <Typography fontSize={'2em'}>
                                {range[1]['service_name']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Center Latitude: {range[1]['lat']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Center Longitude: {range[1]['long']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Radius: {range[1]['radius_miles']} miles
                            </Typography>
                            <Button onClick={(event) => handleClick(event, range[1]['service_name'])} style={{color: 'black'}}>
                                Delete
                            </Button>
                        </Box>
                    ))}
                </Box>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center'}}>
                    <Typography fontSize={'1em'}>
                        Add a Service Range
                    </Typography>
                    <form action='http://18.191.14.26/api/v1/settings/ranges/?target=/settings/ranges' method='post' encType='multipart/form-data'>
                        <FormControl variant='standard' style={{backgroundColor: 'white', width: '20vw'}}>
                            <Select name='serviceName' startAdornment={<InputAdornment>Service:&nbsp;</InputAdornment>} value={service} onChange={handleServiceChange}>
                                {Object.entries(services).map((service, index) => (
                                    <MenuItem key={index} value={service[1]['serviceName']}>
                                        {service[1]['serviceName']}
                                    </MenuItem>
                                ))}
                            </Select>
                            <Input name='rangeLatitude' type='text' startAdornment={<InputAdornment>Center Latitude:&nbsp;</InputAdornment>} required />
                            <Input name='rangeLongitude' type='text' startAdornment={<InputAdornment>Center Longitude:&nbsp;</InputAdornment>} required />
                            <Input name='rangeRadius' type='text' startAdornment={<InputAdornment>Radius (miles):&nbsp;</InputAdornment>} required />     
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

export default Ranges;
