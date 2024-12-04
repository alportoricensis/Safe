import {useEffect, useState} from 'react';

import {Box, Button, FormControl, Input, InputAdornment, MenuItem, Select, Typography} from '@mui/material';


const FAQ = () => {
    const [faqs, setFaqs] = useState({});
    const [services, setServices] = useState({});

    const [service, setService] = useState(null);
    

    const handleClick = async (event, qid) => {
        event.preventDefault();

        await fetch('http://18.191.14.26/api/v1/settings/faq/', {method: 'delete', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({'qid': qid})})
            .catch(error => console.log(error));
    };

    const handleServiceChange = (event) => {
        setService(event.target.value);
    };

    useEffect(() => {
        fetch('http://18.191.14.26/api/v1/settings/faq/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setFaqs(json))
            .catch(error => console.log(error));

        fetch('http://18.191.14.26/api/v1/settings/services/', {method: 'get', headers: {'Content-Type': 'application/json'}})
            .then(response => response.json())
            .then(json => setServices(json['services']))
            .catch(error => console.log(error));
    }, []);

    console.log(faqs)

    return (
        <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', width: '90vw', height: '100vh'}} sx={{overflow: 'scroll'}}>
            <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'center', width: '80vw', minHeight: '80vh'}}>
                <Typography fontSize={'3em'}>
                    Frequently Asked Questions
                </Typography>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', alignItems: 'flex-start', flexWrap: 'wrap', width: '80vw'}}>
                    {faqs ? 
                        Object.entries(faqs).map((faq, index) => (
                            <>
                                <Typography fontSize={'2em'}>
                                    {faq[0]}
                                </Typography>
                                <Box style={{display: 'flex', flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'flex-start', flexWrap: 'wrap', width: '80vw'}}>
                                    {faq[1].map((q, index) => (
                                        <Box key={index} style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'flex-start', width: '25vw'}} sx={{paddingTop: '5vh'}}>
                                            <Typography fontSize={'1em'}>
                                                Q: {q['question']}
                                            </Typography>
                                            <Typography fontSize={'1em'}>
                                                A: {q['answer']}
                                            </Typography>
                                            <Button onClick={(event) => handleClick(event, q['qid'])} style={{alignSelf: 'center', color: 'black'}}>
                                                Delete
                                            </Button>
                                        </Box>
                                    ))}
                                </Box> 
                            </>
                        ))
                    :
                        null
                    }
                </Box>
                <Box style={{display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center'}}>
                    <Typography fontSize={'1em'}>
                        Add a Frequently Asked Question
                    </Typography>
                    <form action='http://18.191.14.26/api/v1/settings/faq/?target=/settings/faq' method='post' encType='multipart/form-data'>
                        <FormControl variant='standard' style={{backgroundColor: 'white', width: '20vw'}}>
                            <Select name='serviceName' startAdornment={<InputAdornment>Service:&nbsp;</InputAdornment>} value={service} onChange={handleServiceChange}>
                                {Object.entries(services).map((service, index) => (
                                    <MenuItem key={index} value={service[1]['serviceName']}>
                                        {service[1]['serviceName']}
                                    </MenuItem>
                                ))}
                            </Select>
                            <Input name='question' type='text' startAdornment={<InputAdornment>Question:&nbsp;</InputAdornment>} required />
                            <Input name='answer' type='text' startAdornment={<InputAdornment>Answer:&nbsp;</InputAdornment>}  required />
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

export default FAQ;
