# ESP32-Energy-Meeter-GUI

This project is a graphical user interface (GUI) for monitoring and analyzing energy data from an ESP32-based energy meter. The GUI is built using Processing and provides various functionalities such as real-time data visualization, frequency estimation, and data export.

## Features

- **Real-time Data Visualization**: Displays time-domain and frequency-domain data for multiple channels.
- **Phasor Diagrams**: Visualizes phasor diagrams for harmonic analysis.
- **Power Quality Metrics**: Calculates and displays power quality metrics such as RMS, THD, and power factors.
- **Data Export**: Allows exporting captured data to CSV files.
- **Configurable Parameters**: Provides a settings tab to configure various parameters like voltage factor, current factor, sample rate, etc.

## File Structure

- `ESP32-Energy-Meeter-GUI.pde`: Main file that initializes the GUI and handles the main drawing loop.
- `Actions.pde`: Handles user interactions such as mouse clicks and key presses.
- `Classes.pde`: Defines custom classes for UI components like buttons, dropdowns, text boxes, and checkboxes.
- `Dashboard.pde`: Contains functions for drawing time-domain and frequency-domain graphs, as well as combined plots and electrical parameters.
- `DataAct.pde`: Processes incoming data packets and updates the data buffers.
- `IP_aux.pde`: Provides utility functions for extracting and obtaining IP addresses.
- `PQ_Meter.pde`: Calculates power quality metrics and displays them.
- `Settings.pde`: Initializes and handles the settings tab, including updating parameters and displaying status indicators.
- `Tabs.pde`: Draws the tab navigation at the top of the GUI.
- `ZeroCrossing.pde`: Implements zero-crossing frequency estimation.

## How to Use

1. **Setup**: Open the `ESP32-Energy-Meeter-GUI.pde` file in Processing and run the sketch.
2. **Configure Parameters**: Go to the "Settings" tab and configure the parameters such as voltage factor, current factor, sample rate, etc. Click "Update Parameters" to apply the changes.
3. **Select Device**: Choose between "Local IP" and "Custom IP" by selecting one of the checkboxes. Select an available ESP device from the dropdown and click "Confirm".
4. **Operation Modes**: Use the checkboxes to switch between Continuous Mode and Shot Mode.
   - **Continuous Mode**: Real-time data visualization. Use the spacebar to pause/resume plotting.
   - **Shot Mode**: Capture and freeze data. Click "Trigger Shot" to capture data and "Export CSV" to save the data to a CSV file.
5. **Navigation**: Use the tabs at the top to navigate between different views such as Settings, PQ Meter, Time Domain, Phasor Diagram, and Phase views.

## Dependencies

- Processing
- UDP library for Processing
