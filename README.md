# WordCloudMyRepo

## Overview
A shiny app that creates word clouds from a list of titles chosen in the Loughborough University Research Repository. See the app live at https://research-data-lboro.shinyapps.io/WordCloudMyRepo/

## Features
  - Keyword search functionality
  - Customizable color options for the word cloud
  - Downloadable citations in CSV format
  - Responsive and user-friendly design
  
## Installation
### Prerequisites
The following software and packages are needed to run the app:
- R
- RStudio
- Required packages:
  - `shiny`
  - `shinycssloaders`
  - `colourpicker`
  - `httr`
  - `jsonlite`
  - `dplyr`
  - `tm`
  - `wordcloud`

### Steps
How to install and run the app:
1. Clone or download the repository.
2. Open the project in RStudio.
3. Install the required packages (if not already installed).
4. Create the global.R file (see below
5. Run the app using the command:
   R
   shiny::runApp()
   
### Code for the global.R file

Sys.setenv( 
  
  API_KEY = "YOUR API KEY" 
  
) 

## Licence
MIT licence

## Acknowledgements
Please see the Acknowledgements tab within the app.

## Cite this app:
Skelly, Lara (2024). Word Cloud the Repository. Loughborough University. Online resource. https://doi.org/10.17028/rd.lboro.27380634
