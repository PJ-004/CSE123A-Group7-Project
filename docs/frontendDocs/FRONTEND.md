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


frontend/

    lib/

        screens/

            drowiness_detected_screen.dart

            live_monitor_screen.dart

            login_screen.dart

        services/

            places_service.dart

            weather_service.dart

            speed_tracking.dart

        app.dart

        main.dart

The frontend is separated into submodules for easier app development. 

- main.dart: Application entrypoint

- app.dart: Defines routes and navigation

- login_screen.dart: User authentication UI

- live_monitor_screen.dart: Dashboard displaying detection information, location, weather, etc

- drowsiness_detected_screen.dart: Page that routes to Google Maps after drowsiness is detected

- weather_service.dart: Handles OpenWeather API communication

- secrets.dart: Stores API keys (gitignored)

### App Navigation Flow

Login Screen -> Live Monitor Dashboard -> Drowsiness Detected Screen

### User Authentication

Currently, we support for the driver side of the application. We will work on the Fleet
Operator side of the application towards the next quarter. 

#### Driver Authentication:
email: admin@blink.ai

password: blink123

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


