library(shiny)
library(shinycssloaders)  # For the spinner
library(colourpicker)

# Define UI for application
ui <- navbarPage(
  title = "Word Cloud the Repository",

  tabPanel("Make a Word Cloud",
           fluidPage(
             h4("Make a word cloud from items in the ", a("Loughborough University Research Repository", href = "https://repository.lboro.ac.uk")),
             p("Enter a keyword (or keywords in inverted commas) to search for articles, and visualize the most frequent words as a word cloud."),
             p("Use the 'Search' button to fetch data and the 'Download' button to get the citations in CSV format."),
           ),
           sidebarLayout(
             sidebarPanel(

               p("Click on search to get going; be patient, our servers are slow :)"),
               textInput("keyword", "Enter a keyword:", value = '"Open Research"'),
               colourInput("colour1", "Choose first colour", value = "darkblue"),  # Colour 1 input
               colourInput("colour2", "Choose second colour", value = "blue"),  # Colour 2 input
               actionButton("search", "Search"),
               p(),
               downloadButton("downloadData", "Download Citations as CSV"),
               p(),
               p("Note that if the word frequency isn't varied enough, only one colour will show.")
             ),
             
             mainPanel(
                 withSpinner(plotOutput("wordcloud", width = "100%", height = "400px")) 
             )
           )
  ),
  tabPanel("Acknowledgements",
           fluidPage(
             p("This app has been created and maintained by Lara Skelly for Loughborough University. The code can be found on ", a("GitHub", href = "https://github.com/lboro-rdm/WordCloudMyRepo.git", target = "_blank")),
             p(),
             p("To cite this app:"),
             p("Skelly, Lara (2024). Word Cloud the Repository. Loughborough University. Online resource. ", 
               a("https://doi.org/10.17028/rd.lboro.27380634", href = "https://doi.org/10.17028/rd.lboro.27380634", target = "_blank")),
             p(),
             p("Throughout the creation of this Shiny app, ChatGPT acted as a conversation partner and a code checker."),
             p(),
             tags$p("The following packages were used in this code:"),
             tags$ul(
               tags$li(a("colourpicker", href = "https://daattali.com/shiny/colourInput/")),
               tags$li(a("dplyr", href = "https://dplyr.tidyverse.org")),
               tags$li(a("httr", href = "https://httr.r-lib.org/")),
               tags$li(
                 "jsonlite: Jeroen Ooms (2014). The jsonlite Package: A Practical and Consistent Mapping Between JSON Data and R Objects. arXiv:1403.2805. ", 
                 a("https://arxiv.org/abs/1403.2805", href = "https://arxiv.org/abs/1403.2805")
               ),
               tags$li(a("shiny", href = "https://shiny.posit.co/")),
               tags$li(a("shinycssloaders", href = "https://github.com/daattali/shinycssloaders")),
               tags$li(
                 "tm: Feinerer, I., Hornik, K., & Meyer, D. (2008). Text mining infrastructure in R. Journal of statistical software, 25, 1-54. ",
                 a("https://doi.org/10.18637/jss.v025.i05", href = "https://doi.org/10.18637/jss.v025.i05")
               ),
               tags$li(a("wordcloud", href = "https://blog.fellstat.com/?cat=11"))
             ),
             p(),
             p("This app was funded by the ", a("Arts Council England Develop Your Creative Practice Grant", href = "https://www.artscouncil.org.uk/dycp")),
             tags$img(src = "logo.png", width = "300px")  # Adjust width as needed
           )

           )
           
           )


