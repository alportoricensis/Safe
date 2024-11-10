import {Box, Typography} from '@mui/material';


const NotFound = () => {
    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw', height: '100vh'}}>
            <Typography fontSize={'5em'}>
                404
            </Typography>
            <Typography fontSize={'3em'}>
                oops! page not found
            </Typography>
        </Box>
    );
};

export default NotFound;