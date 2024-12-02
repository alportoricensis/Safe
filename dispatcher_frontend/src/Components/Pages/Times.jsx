import {useEffect, useState} from 'react';

import {Box, Button, Typography} from '@mui/material';


const Times = () => {
    const [services, setServices] = useState({});

    const handleClick = async (event, serviceName, startTime, endTime) => {
        event.preventDefault();

        await fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'PATCH', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({'serviceName': serviceName, 'startTime': startTime, 'endTime': endTime})})
            .catch(error => console.log(error));
    };

    const handleStartTimeChange = (event, service) => {
        setServices({
            ...services,
            [service]: {
                ...services[service],
                'startTime': event.target.value
            }
        });
    };

    const handleEndTimeChange = (event, service) => {
        setServices({
            ...services,
            [service]: {
                ...services[service],
                'endTime': event.target.value
            }
        });
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
                    Service Times
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center', flexWrap: 'wrap', width: '80vw'}}>
                    {Object.entries(services).map((service, index) => (
                        <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '20vw', height: '50vh'}}>
                            <Typography fontSize={'2em'}>
                                {service[1]['serviceName']}
                            </Typography>
                            <Typography fontSize={'1em'}>
                                Start Time: <input name='startTime' type='time' value={service[1]['startTime']} onChange={(event) => handleStartTimeChange(event, service[0])} style={{width: '7vw'}} />
                            </Typography>
                            <Typography fontSize={'1em'}>
                                End Time: <input name='endTime' type='time' value={service[1]['endTime']} onChange={(event) => handleEndTimeChange(event, service[0])} style={{width: '7vw'}} />
                            </Typography>
                            <Button type='submit' onClick={(event) => handleClick(event, service[1]['serviceName'], service[1]['startTime'], service[1]['endTime'])} style={{color: 'black'}}>
                                Update
                            </Button>
                        </Box>
                    ))}
                </Box>
            </Box>
        </Box>
    );
};

export default Times;
