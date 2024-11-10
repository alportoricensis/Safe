import {Box, Link, Typography} from '@mui/material';


const Settings = () => {
    return (
        <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'space-evenly', alignItems: 'center', flexWrap: 'wrap', width: '90vw', height: '100vh'}}>
            <Box href='/settings/services' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '25vw', height: '40vh', textDecoration: 'none', color: 'black'}} sx={{border: 1, borderRadius: 10}}>
                <Typography fontSize={'3em'}>
                    Services
                </Typography>
            </Box>
            <Box href='/settings/ranges' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '25vw', height: '40vh', textDecoration: 'none', color: 'black'}} sx={{border: 1, borderRadius: 10}}>
                <Typography fontSize={'3em'}>
                    Service Ranges
                </Typography>
            </Box>
            <Box href='/settings/locations' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '25vw', height: '40vh', textDecoration: 'none', color: 'black'}} sx={{border: 1, borderRadius: 10}}>
                <Typography fontSize={'3em'}>
                    Service Locations
                </Typography>
            </Box>
            <Box href='/settings/times' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '25vw', height: '40vh', textDecoration: 'none', color: 'black'}} sx={{border: 1, borderRadius: 10}}>
                <Typography fontSize={'3em'}>
                    Service Times
                </Typography>
            </Box>
            <Box href='/settings/vehicles' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '25vw', height: '40vh', textDecoration: 'none', color: 'black'}} sx={{border: 1, borderRadius: 10}}>
                <Typography fontSize={'3em'}>
                    Register Vehicles
                </Typography>
            </Box>
            <Box href='/settings/routing' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', width: '25vw', height: '40vh', textDecoration: 'none', color: 'black'}} sx={{border: 1, borderRadius: 10}}>
                <Typography fontSize={'3em'}>
                    Routing Options
                </Typography>
            </Box>
        </Box>
    );
};

export default Settings;