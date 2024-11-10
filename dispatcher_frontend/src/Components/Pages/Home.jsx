import {useEffect, useState} from 'react';

import {Box, Link, Typography} from '@mui/material';


const Home = () => {
    const [services, setServices] = useState({})

    const username = 'Teage Johnson'

    useEffect(() => {
        fetch('http://35.2.2.224:5000/api/v1/settings/services/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));
    }, []);

    console.log(services)

    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw'}}>
            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'space-between', alignItems: 'center', width: '80vw', minHeight: '80vh'}}>
                <Typography fontSize={'5em'}>
                    Welcome {username}
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', alignItems: 'center'}}>
                    <Typography fontSize={'3em'}>
                        Services
                    </Typography>
                    <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'center', alignItems: 'center', flexWrap: 'wrap', width: '80vw'}}>
                        {Object.entries(services).map((service, index) => (
                            <Box key={index} href={`/dispatch?service=${service[1]['serviceName']}`} component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '25vw', textDecoration: 'none', color: 'black'}} sx={{padding: '1vw', margin: '1vw', border: 1, borderRadius: 10}}>
                                <Typography fontSize={'2em'}>
                                    {service[1]['serviceName']}
                                </Typography>
                                <Typography fontSize={'1em'}>
                                    Start Time: {service[1]['startTime']}
                                </Typography>
                                <Typography fontSize={'1em'}>
                                    End Time: {service[1]['endTime']}
                                </Typography>
                            </Box>
                        ))}
                    </Box>
                </Box>
            </Box>
        </Box>
    );
};

export default Home;