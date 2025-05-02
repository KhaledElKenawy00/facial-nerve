# Facial Nerve Control App

This Flutter project is designed for controlling facial nerve stimulation based on EMG sensor data communicated via Bluetooth. The app connects to a Bluetooth device (such as an EMG sensor) and displays real-time readings, allowing users to control the facial nerve operation. The app also logs sensor data into a local database and enables users to view historical data with pagination.

## Table of Contents
1. [Features](#features)
2. [Setup Instructions](#setup-instructions)
3. [Pages](#pages)
   - [Home Screen](assets/home.jpg)
   - [logain Screen](assets/logain.jpg)
   - [History Screen](assets/1.jpg)
4. [Database](#database)
5. [Dependencies](#dependencies)
6. [Future Enhancements](#future-enhancements)
7. [License](#license)
8. [Acknowledgments](#acknowledgments)

## Features

- **Bluetooth Connectivity**: Connect to paired Bluetooth devices and receive sensor data.
- **Real-Time Data Updates**: Display real-time EMG values, session time, and other sensor data.
- **Session Timer**: Track the elapsed time of the current session.
- **Data Logging**: Store received sensor data into a local database.
- **Pagination**: View historical data with pagination support for better user experience.
- **Interactive Graph**: Visualize the EMG data over time using `FlChart`.

## Setup Instructions

Follow these steps to set up and run the app locally:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/KhaledElKenawy00/Facial-Nerve-Control-App.git
