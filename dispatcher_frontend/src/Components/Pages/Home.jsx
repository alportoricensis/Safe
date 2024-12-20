import {useEffect, useState} from 'react';

import {Box, Link, Typography} from '@mui/material';


const Home = () => {
    const [services, setServices] = useState({})

    const username = 'Teage Johnson'

    useEffect(() => {
        fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));
    }, []);

    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw', backgroundColor: 'rgb(3, 38, 72)'}}>
            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'space-between', alignItems: 'center', width: '80vw', minHeight: '80vh'}}>
                <Typography fontSize={'5em'} color='white'>
                    Welcome {username}
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', alignItems: 'center'}}>
                    <Typography fontSize={'3em'} color='white'>
                        Services
                    </Typography>
                    <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'center', alignItems: 'center', flexWrap: 'wrap', width: '80vw'}}>
                        {Object.entries(services).length > 0 ?
                            Object.entries(services).map((service, index) => (
                                <Box key={index} href={`/dispatch?service=${service[1]['serviceName']}`} component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '25vw', textDecoration: 'none', color: 'black', backgroundColor: 'white'}} sx={{padding: '1vw', margin: '1vw', borderRadius: 10}}>
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
                            ))
                        :
                            <Typography fontSize={'1.25em'}>
                                No Services Registered
                            </Typography>
                        }
                    </Box>
                </Box>
            </Box>
        </Box>
    );
};

export default Home;
