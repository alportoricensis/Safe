import {Box, Link, Typography} from '@mui/material';

import BookIcon from '@mui/icons-material/Book';
import HomeIcon from '@mui/icons-material/Home';
import SettingsIcon from '@mui/icons-material/Settings';
import LogoutIcon from '@mui/icons-material/Logout';

const Navbar = () => {
    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'space-between', alignItems: 'center', backgroundColor: 'rgb(1, 18, 32)', width: '10vw', height: '90vh'}} sx={{paddingTop: '5vh', paddingBottom: '5vh'}}>
            <Box href='/' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textDecoration: 'none', color: 'white'}}>
                <HomeIcon style={{color: 'white', width: '5vw', height: '5vw'}}/>
                <Typography fontSize={'1em'}>
                    Home
                </Typography>
            </Box>
            <Box href='/dispatch' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textDecoration: 'none', color: 'white'}}>
                <BookIcon style={{color: 'white', width: '5vw', height: '5vw'}}/>
                <Typography fontSize={'1em'}>
                    Dispatch
                </Typography>
            </Box>
            <Box href='/settings' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textDecoration: 'none', color: 'white'}}>
                <SettingsIcon style={{color: 'white', width: '5vw', height: '5vw'}}/>
                <Typography fontSize={'1em'}>
                    Settings
                </Typography>
            </Box>
            <Box href='/logout' component={Link} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textDecoration: 'none', color: 'white'}}>
                <LogoutIcon style={{color: 'white', width: '5vw', height: '5vw'}}/>
                <Typography fontSize={'1em'}>
                    Sign Out
                </Typography>
            </Box>
        </Box>
    );
};

export default Navbar;