# Safe! Micro-Transit Platform
## About Safe!
Safe! is an open-source platform for micro-transit providers. Safe! was created to provide non-profit
micro-transit providers (such as universities, airports, and hospitals) with a free option for providing
service. Safe!'s backend was written using Python & Flask, with an agency frontend written in React and 
passenger/driver applications written in Swift for iOS.

## Setting up Safe!
#### Running the Backend API
The following instructions borrow heavily from the [Flask tutorial from EECS 485](https://eecs485staff.github.io/p2-insta485-serverside/setup_flask.html). 
First, clone the github repository containing the backend application using: \
```git clone https://github.com/alportoricensis/Safe.git``` \
This will clone the github repository into your current folder. Because Safe!'s backend is written using Flask,
you will need to setup a Python virtual environment to be able to run it. Assuming python3 is installed
locally, run the following command to create a virtual environment: \
```python3 -m venv env/``` \
You should see a directory called env/ within your current workspace. Run \
```source env/bin/activate``` \
to activate the virtual environment. You should see a (env) to the left of your command line. We now need
to install the packages Safe!'s backend uses to run, which are specified in the ```requirements.txt```
downloaded with the backend. To do this, run: \
```pip install -r requirements.txt``` \
```pip install -e .``` \
Everything needed to run the backend has now been installed! To run the backend, run: \
```flask --app safe_backend --debug run --host 0.0.0.0 --port 8000``` \
You should see a message saying ```* Serving Flask app 'safe_backend'```, confirming the backend is
running. Note that this is **not a production server**, but rather a development server. To run Safe!
in a proper production server for your agency, you can follow the instructions for [deploying a Flask app
on AWS](https://eecs485staff.github.io/p2-insta485-serverside/setup_aws.html) from EECS 485. \

#### Installing Postgres
Safe! uses a database to store locations, vehicles, users, and ride requests. The following section provides
instructions for configuring a local database using Postgres. Note that, depending on the size of your machine,
this is likely not ideal. Rather than use a Postgres database, we recommend cloud stores such as the ones AWS,
Oracle, or Azure provide.
<details>
<summary>Installing Postgres on MAC</summary>
<br>
  To install Postgres on a macOS environment, run the following command: <br>
  ```brew install postgresql``` <br>
  ```brew services start postgresql``` <br>
  This will download postgres and start up a Postgres server locally.
</details>
<details>
<summary>Installing Postgres on Linux</summary>
<br>
  To install Postgres on a Linux environment, run the following command: <br>
  ```sudo apt install postgresql``` <br>
</details>
After you've installed and run Postgres, Safe! requires you do two things: 1) configure a user for the
database, and 2) create a database which Safe! will populate with tables when it first runs. To do so: <br>
  ```sudo -u postgres psql``` <br>
  ```CREATE USER safe WITH PASSWORD '<YOUR_PASSWORD_HERE>;```  <br>
  ```CREATE DATABASE safe_backend WITH PASSWORD;``` <br>
The password types in <YOUR_PASSWORD_HERE> needs to be added to calls to psycopg2 within the backend. You
may also leave the password field blank for no password.

#### Google Cloud & Route Optimization
One final detail needed to run the backend is that the backend uses [Google's Route Optimization API](https://console.cloud.google.com/apis/library/routeoptimization.googleapis.com?project=eecs-441-safe)
to obtain optimal assignments for vehicles. **This is not free**, but Google provides $200 of credits per
month, which is enough for most smaller agencies. Because of this, running the backend requires two more things.
For one, [follow Google's instructions to create a cloud project](https://developers.google.com/workspace/guides/create-project).
This will be used to manage billing details for the Route Optimization API. Give your project a descriptive name,
which will be added to the API later on. After creating the project, activate the Route Optimization API.
Now, we need to configure the Google credentials locally. You may need to [install Google cloud's CLI](https://cloud.google.com/sdk/docs/install).
After doing this, run: \
```gcloud auth login``` \
this will prompt you to login to Google. Use the same account that was used to create the project earlier.
After successfully logging in, your credentials will be stored locally. Lastly, in Line 129 of ```safe_backend/api/vehicles.py```,
change the request.parent string to match the name you gave to your project before. For example: \
```request.parent = "projects/<your_project_name>"``` \
That should be everything needed to run the backend!

### Accessing the Agency Web Application
Most of what is needed to run the agency web application was bundled with the backend api. The backend api
provides routes, views, and templates needed to run it, save for the JS webpack needed to run the dispatcher view.
This section assumes you've followed the instructions for setting up the backend. In the same directory the 
backend lives, run: \
```npx webpack``` \
This will create the JavaScript bundle needed in the dispatcher view. The agency web application provides
functionality for creating services, registering vehicles, specifying service ranges, and servicing rides.
You should be able to navigate the dispatcher view through the same IP address the Flask server is running
on.

### Running the Driver Frontend

### Running the Passenger App
