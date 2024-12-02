import {useEffect, useState} from 'react';

import {Box, Button, FormControl, Input, InputAdornment, Typography} from '@mui/material';


const Vehicles = () => {
    const [vehicles, setVehicles] = useState({});

    const handleClick = async (event, vehicleName) => {
        event.preventDefault();

        await fetch('http://10.0.0.161:5000/api/v1/settings/vehicles/', {method: 'delete', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({'vehicleName': vehicleName})})
            .catch(error => console.log(error));
    };
    
    useEffect(() => {
        fetch('http://10.0.0.161:5000/api/v1/settings/vehicles/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setVehicles(json['vehicles']))
            .catch(error => console.log(error));
    }, []);

    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw'}}>
            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '80vw', minHeight: '80vh'}}>
                <Typography fontSize={'3em'}>
                    Register Vehicles
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center', flexWrap: 'wrap', width: '80vw'}}>
                    {Object.entries(vehicles).map((vehicle, index) => (
                        <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '20vw', height: '50vh'}}>
                            <Typography fontSize={'2em'}>
                                {vehicle[1]['vehicle_id']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Capacity: {vehicle[1]['capacity']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Range: {vehicle[1]['vrange']} miles
                            </Typography>
                            <Button onClick={(event) => handleClick(event, vehicle[1]['vehicle_id'])} style={{color: 'black'}}>
                                Delete
                            </Button>
                        </Box>
                    ))}
                </Box>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center'}}>
                    <Typography fontSize={'1em'}>
                        Register a Vehicle
                    </Typography>
                    <form action='http://10.0.0.161:5000/api/v1/settings/vehicles/?target=/settings/vehicles' method='post' encType='multipart/form-data'>
                        <FormControl variant='standard' style={{backgroundColor: 'white', width: '20vw'}}>
                            <Input name='vehicleName' type='text' startAdornment={<InputAdornment>Vehicle Name:&nbsp;</InputAdornment>} required />
                            <Input name='vehicleCapacity' type='text' startAdornment={<InputAdornment>Capacity:&nbsp;</InputAdornment>} required />
                            <Input name='vehicleRange' type='text' startAdornment={<InputAdornment>Range (miles):&nbsp;</InputAdornment>} required />     
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

export default Vehicles;
