import {useEffect, useState} from 'react';

import {Box, Button, FormControl, Input, InputAdornment, Typography} from '@mui/material';


const Services = () => {
    const [services, setServices] = useState({});

    const handleClick = async (event, serviceName) => {
        event.preventDefault();

        await fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'delete', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({'serviceName': serviceName})})
            .catch(error => console.log(error));
    };

    useEffect(() => {
        fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));
    }, []);

    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw'}}>
            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '80vw', minHeight: '80vh'}}>
                <Typography fontSize={'3em'}>
                    Services
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center', flexWrap: 'wrap', width: '80vw'}}>
                    {Object.entries(services).map((service, index) => (
                        <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '20vw', height: '40vh'}}>
                            <Typography fontSize={'2em'}>
                                {service[1]['serviceName']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Provider: {service[1]['provider']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Start Time: {service[1]['startTime']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                End Time: {service[1]['endTime']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Cost: {service[1]['cost']}
                            </Typography>
                            <Button onClick={(event) => handleClick(event, service[1]['serviceName'])} style={{color: 'black'}}>
                                Delete
                            </Button>
                        </Box>
                    ))}
                </Box>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center'}}>
                    <Typography fontSize={'1em'}>
                        Add a Service
                    </Typography>
                    <form action='http://18.191.14.26/api/v1/settings/services/?target=/settings/services' method='post' encType='multipart/form-data'>
                        <FormControl variant='standard' style={{backgroundColor: 'white', width: '20vw'}}>
                            <Input name='serviceName' type='text' startAdornment={<InputAdornment>Service Name:&nbsp;</InputAdornment>} required />
                            <Input name='provider' type='text' startAdornment={<InputAdornment>Provider:&nbsp;</InputAdornment>} required />
                            <Input name='startTime' type='time' startAdornment={<InputAdornment>Start Time:&nbsp;</InputAdornment>} required />
                            <Input name='endTime' type='time' startAdornment={<InputAdornment>End Time:&nbsp;</InputAdornment>} required />
                            <Input name='cost' type='number' startAdornment={<InputAdornment>Cost:&nbsp;</InputAdornment>} required />
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

export default Services;
