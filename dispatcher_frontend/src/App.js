import {React} from 'react';
import {Route, Routes} from 'react-router-dom';

import {Box} from '@mui/material';

import Navbar from './Components/Features/Navbar';

import Home from './Components/Pages/Home';
import Dispatch from './Components/Pages/Dispatch';
import FAQ from './Components/Pages/FAQ';
import Settings from './Components/Pages/Settings';
import Services from './Components/Pages/Services';
import Ranges from './Components/Pages/Ranges';
import Locations from './Components/Pages/Locations';
import Times from './Components/Pages/Times';
import Vehicles from './Components/Pages/Vehicles';
import NotFound from './Components/Pages/NotFound';

const App = () => {
	return (
    <Box style={{display: 'flex', flexDirection: 'row'}}>
      <Navbar />
      <Routes>
          <Route path = '/' element = {<Home />} />
          <Route path = '/dispatch' element = {<Dispatch />} />
          <Route path = '/faq' element = {<FAQ />} />
          <Route path = '/settings' element = {<Settings />} />
          <Route path = '/settings/services' element = {<Services />} />
          <Route path = '/settings/ranges' element = {<Ranges />} />
          <Route path = '/settings/locations' element = {<Locations />} />
          <Route path = '/settings/times' element = {<Times />} />
          <Route path = '/settings/vehicles' element = {<Vehicles />} />
          <Route path = '*' element = {<NotFound />} />
      </Routes>
    </Box>
    );
};


export default App;
