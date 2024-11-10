import {Box} from '@mui/material';

import HomeIcon from '@mui/icons-material/Home';
import SettingsIcon from '@mui/icons-material/Settings';
import LogoutIcon from '@mui/icons-material/Logout';

const Navbar = () => {
    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'space-evenly', alignItems: 'center', backgroundColor: 'rgb(1, 18, 32)', width: '10vw', height: '100vh'}}>
            <a href='/'>
                <HomeIcon style={{color: 'white', width: '5vw', height: '5vw'}}/>
            </a>
            <a href='/settings'>
                <SettingsIcon style={{color: 'white', width: '5vw', height: '5vw'}}/>
            </a>
            <a href='/logout'>
                <LogoutIcon style={{color: 'white', width: '5vw', height: '5vw'}}/>
            </a>
        </Box>
    );
};

export default Navbar;