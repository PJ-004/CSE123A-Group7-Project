# Documentation for CSE123 Group7 Frontend

## App Title: BLINK
### Overview

BLINK is a Flutter based app designed to monitor driver fatigue/drowsiness and provide real-time safety indicators.
The application integrates: 
- Driver fatigue visualization 
- GPS location tracking
- Weather Data integration 
- Speed Tracking Analysis

### Structure


The frontend is separated into submodules for easier app development. 

- main.dart: Application entrypoint

- app.dart: Defines routes and navigation

- login_screen.dart: User authentication UI

- live_monitor_screen.dart: Dashboard displaying detection information, location, weather, etc

- drowsiness_detected_screen.dart: Page that routes to Google Maps after drowsiness is detected

- weather_service.dart: Handles OpenWeather API communication

- secrets.dart: Stores API keys (gitignored)

- secrets.example.dart: Template showing required API key placeholders, copy to secrets.dart to set up

- role_selection_screen.dart: Post-signup screen where users set their name, role (driver or fleet operator), and Jetson device ID

- fleet_operator_dashboard.dart: Dashboard for fleet operators to monitor multiple drivers' fatigue status in real time

- osm_map_screen.dart: Map screen using OpenStreetMap that displays nearby rest stops after drowsiness is detected

- auth_service.dart: Handles user signup and login with the backend, stores auth token securely on device

- ble_service.dart: Connects to the Jetson via Bluetooth LE and streams drowsiness alerts

- jetson_websocket_service.dart: Connects to the Jetson backend via WebSocket and streams drowsiness alerts and presence events

- osm_places_service.dart: Fetches nearby rest stops using the OpenStreetMap Overpass API with caching and fallback endpoints

- places_service.dart: Fetches nearby gas stations using the Google Places API

- user_role_service.dart: Manages user profile and role data (driver vs fleet operator) from the backend

- fatigue_risk_logic.dart: Pure logic for computing and ramping the fatigue risk percentage from incoming alerts

### App Navigation Flow

Login Screen -> Live Monitor Dashboard -> Drowsiness Detected Screen

### User Authentication

Create an account and pick user role options. Set name and device (jetson ID) ID.


### Dashboard Components

#### Header Card:

- Driver Name
- Vehicle Name
- LIVE system status indicator

#### Fatigue Risk Card:

- Risk Percentage
- Status Label

#### Status Chips:

Displays real-time contextual information:
- Face detection status
- Eye status
- Alert state
- Latitude/Longitude
- Weather Condition
- Temperature



