library(shiny)
library(shinycssloaders)  # For the spinner
library(colourpicker)

# Define UI for application
ui <- navbarPage(
  title = "Word Cloud from Figshare",
  
  tabPanel("Welcome",
           fluidPage(
             titlePanel("Welcome to the Word Cloud App"),
             h4("This application allows you to create a word cloud from articles in the Figshare repository."),
             p("Enter a keyword to search for articles, and visualize the most frequent words as a word cloud."),
             p("Use the 'Search' button to fetch data and the 'Download' button to get the citations in CSV format.")
           )
  ),
  
  tabPanel("App",
           sidebarLayout(
             sidebarPanel(
               textInput("keyword", "Enter a keyword:", value = "sport"),
               colourInput("colour1", "Choose first colour", value = "orange"),  # Colour 1 input
               colourInput("colour2", "Choose second colour", value = "brown"),  # Colour 2 input
               actionButton("search", "Search"),
               p(),
               downloadButton("downloadData", "Download Citations as CSV")
             ),
             
             mainPanel(
               withSpinner(plotOutput("wordcloud")),
               verbatimTextOutput("errorMessage")  # Output area for error messages
             )
           )
  )
)

shinyUI(ui)
