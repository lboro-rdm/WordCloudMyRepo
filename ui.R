library(shiny)
library(shinycssloaders)  # For the spinner
library(colourpicker)
library(magick)

# Define UI for application
ui <- navbarPage(
  title = "Word Cloud the Repository",
  
  tabPanel("Welcome",
           fluidPage(
             titlePanel("Welcome to the Word Cloud App"),
             h4("This application allows you to create a word cloud from articles in the Loughborough University Research Repository."),
             p("This app has been created and maintained by Lara Skelly for Loughborough University."),
             p(),
             p("The code can be found on ", a("GitHub", href = "https://github.com/lboro-rdm/WordCloudMyRepo.git", target = "_blank")),
             p(),
             p("To cite this app:"),
             p("Skelly, Lara (2024). Word Cloud the Repository. Loughborough University. Online resource. ", 
               a("https://doi.org/10.17028/rd.lboro.27380634", href = "https://doi.org/10.17028/rd.lboro.27380634", target = "_blank")),
             tags$img(src = "nonexistent_image.jpg", alt = "Dummy Image"),
             tags$img(src = "logo.png", alt = "Lottery Logo")
           )
  ),
  
  tabPanel("App",
           sidebarLayout(
             sidebarPanel(
               p("Enter a keyword to search for articles, and visualize the most frequent words as a word cloud."),
               p("Use the 'Search' button to fetch data and the 'Download' button to get the citations in CSV format."),
               textInput("keyword", "Enter a keyword:", value = "winter"),
               colourInput("colour1", "Choose first colour", value = "darkblue"),  # Colour 1 input
               colourInput("colour2", "Choose second colour", value = "lightblue"),  # Colour 2 input
               actionButton("search", "Search"),
               p(),
               downloadButton("downloadData", "Download Citations as CSV")
             ),
             
             mainPanel(
               div(
                 style = "width: 100%; max-width: 600px; height: 400px; max-height: 500px; margin: 10px auto;",
                 withSpinner(plotOutput("wordcloud", width = "100%", height = "400px"))  # Set height explicitly here
               ),
               verbatimTextOutput("errorMessage")  # Output area for error messages
             )
           )
  )
)

# Run the application 
shinyApp(ui = ui, server = function(input, output) {})
