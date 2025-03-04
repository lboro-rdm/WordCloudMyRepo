library(shiny)
library(shinycssloaders)
library(colourpicker)
library(httr)
library(jsonlite)
library(dplyr)
library(tm)
library(wordcloud)

ui <- tags$html(lang = "en",
                fluidPage(
                  tags$head(
                    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
                  ),
                  
                  navbarPage(
                    title = "Word Cloud the Repository",
                    
                    tabPanel("Make a Word Cloud",
                             fluidPage(
                               h1("Make a Word Cloud..."),
                               p(style = "font-size: 1.2em;", strong("...from items in the "), a("Loughborough University Research Repository", href = "https://repository.lboro.ac.uk")),
                               p("Enter a keyword (or keywords in inverted commas) to search for articles, and visualise the most frequent words as a word cloud."),
                               p("Use the 'Search' button to fetch data."),
                               p("Please be patient, our servers are slow :) ")
                             ),
                             sidebarLayout(
                               sidebarPanel(
                                 textInput("keyword", "Enter a keyword:"),
                                 colourInput("colour1", "Choose first colour:", value = "#cc6b00"),
                                 colourInput("colour2", "Choose second colour:", value = "#ffb74d"),
                                 actionButton("search", "Search"),
                                 p(),
                                 p("Note that if the word frequency isn't varied enough, only one colour will show.")
                               ),
                               
                               mainPanel(
                                 conditionalPanel(
                                   condition = "output.hasResults",
                                   withSpinner(plotOutput("wordcloud", width = "100%", height = "400px")),
                                   uiOutput("repoLink")
                                 ),
                                 
                                 conditionalPanel(
                                   condition = "!output.hasResults",
                                   span(textOutput("errorMessage"), style = "color:#5a650a")
                                 )
                               )
                             )
                    ),
                    tabPanel("Acknowledgements",
                             fluidPage(
                               tags$head(
                                 tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
                               ),
                               h1("Acknowledgements"),
                               p("This web app creates dynamic wordclouds based on textual data."),
                               p(),
                               p("It was created in R, with the following packages:"),
                               tags$ul(
                                 tags$li(HTML("Attali, D. (2023). <i>colourpicker: A Colour Picker Tool for Shiny and for Selecting Colours in Plots</i>. R package version 1.3.0. "), 
                                         a("https://CRAN.R-project.org/package=colourpicker", href = "https://CRAN.R-project.org/package=colourpicker")),
                                 tags$li(HTML("Feinerer, I., & Hornik, K. (2024). <i>tm: Text Mining Package</i>. R package version 0.7-15. "), 
                                         a("https://CRAN.R-project.org/package=tm", href = "https://CRAN.R-project.org/package=tm")),
                                 tags$li(HTML("Fellows, I. (2018). <i>wordcloud: Word Clouds</i>. R package version 2.6. "), 
                                         a("https://CRAN.R-project.org/package=wordcloud", href = "https://CRAN.R-project.org/package=wordcloud")),
                                 tags$li(HTML("Chang, W., Cheng, J., Allaire, J., Sievert, C., Schloerke, B., Xie, Y., Allen, J., McPherson, J., Dipert, A., & Borges, B. (2024). <i>shiny: Web Application Framework for R</i>. R package version 1.9.1. "), 
                                         a("https://CRAN.R-project.org/package=shiny", href = "https://CRAN.R-project.org/package=shiny")),
                                 tags$li(HTML("Ooms, J. (2014). “The jsonlite Package: A Practical and Consistent Mapping Between JSON Data and R Objects.” <i>arXiv:1403.2805 [stat.CO]</i>. "), 
                                         a("https://arxiv.org/abs/1403.2805", href = "https://arxiv.org/abs/1403.2805")),
                                 tags$li(HTML("Sali, A., & Attali, D. (2020). <i>shinycssloaders: Add Loading Animations to a 'shiny' Output While It's Recalculating</i>. R package version 1.0.0. "), 
                                         a("https://CRAN.R-project.org/package=shinycssloaders", href = "https://CRAN.R-project.org/package=shinycssloaders")),
                                 tags$li(HTML("Wickham, H. (2023). <i>httr: Tools for Working with URLs and HTTP</i>. R package version 1.4.7. "), 
                                         a("https://CRAN.R-project.org/package=httr", href = "https://CRAN.R-project.org/package=httr")),
                                 tags$li(HTML("Wickham, H., François, R., Henry, L., Müller, K., & Vaughan, D. (2023). <i>dplyr: A Grammar of Data Manipulation</i>. R package version 1.1.4. "), 
                                         a("https://CRAN.R-project.org/package=dplyr", href = "https://CRAN.R-project.org/package=dplyr"))
                               ),
                               
                               p("This app has been created and maintained by Lara Skelly for Loughborough University, copyright: MIT. The code can be found on ", a("GitHub", href = "https://github.com/lboro-rdm/WordCloudMyRepo.git", target = "_blank")),
                               
                               p(),
                               p("To cite this app:"),
                               tags$ul(
                                 tags$li(
                                   HTML("Skelly, Lara (2024). <i>Word Cloud the Repository: a R/Shiny app that creates word clouds based on a search from the Loughborough University Research Repository.</i> Loughborough University. Online resource. ")
                                   , a("https://doi.org/10.17028/rd.lboro.27380634", href = "https://doi.org/10.17028/rd.lboro.27380634")
                                 )
                               ),
                               
                               p(),
                               p("Throughout the creation of this Shiny app, ChatGPT acted as a conversation partner and a code checker."),
                               p(),
                               p("This webapp does not use cookies or store any data on your device."),
                               p(),
                               p("This app was funded by the ", a("Arts Council England Develop Your Creative Practice Grant", href = "https://www.artscouncil.org.uk/dycp")),
                               tags$img(src = "logo.png", width = "300px", alt = "Arts Council England logo")
                             )
                    ),
                    tags$div(class = "footer", 
                             fluidRow(
                               column(12, 
                                      tags$a(href = 'https://doi.org/10.17028/rd.lboro.28525481', 
                                             "Accessibility Statement",
                                             style = "color: #ffffff !important; text-decoration: none;")
                               )
                             ),
                             style = "background-color: #333; color: #ffffff !important; padding: 10px; margin-top: 30px; text-align: center;"
                    )
                  )
                )
)
