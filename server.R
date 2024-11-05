library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(tm)
library(wordcloud)
library(colourpicker)

# Define server logic
server <- function(input, output, session) {
  
  # Initialize reactive values
  repo_data <- reactiveVal(data.frame(titles = character(), stringsAsFactors = FALSE))
  combined_df <- reactiveVal(data.frame(Citation = character(), URL = character(), stringsAsFactors = FALSE))
  
  # Reactive expression to handle search
  observeEvent(input$search, {
    req(input$keyword)
    
    options(encoding = "UTF-8")
    api_key <- Sys.getenv("API_KEY")
    
    # Set up the base URL and query parameters
    base_url <- "https://api.figshare.com/v2/articles"
    
    query_params <- list(
      institution = 2,
      page_size = 1000,
      search_for = input$keyword
    )
    
    response <- GET(
      url = base_url,
      query = query_params,
      add_headers(Authorization = paste("token", api_key))
    )
    
    # Try fetching the response content
    data <- fromJSON(rawToChar(response$content), flatten = TRUE)
    
    # Check if titles are available
    if (is.null(data$title) || length(data$title) == 0) {
      output$wordcloud <- renderUI({
        tags$div(
          style = "text-align: center;",  # Center the content
          tags$img(src = "www/sad_face.png", width = 120, height = 100),
          tags$p("No search results found for the selected keyword.")
        )
      })
      return(NULL)  # Early exit
    }
    
    # Extract titles
    titles <- data$title
    repo_data(data.frame(titles = titles, stringsAsFactors = FALSE))  # Create dataframe
    
    output$errorMessage <- renderText("")  # Clear previous messages
    
    # Generate word cloud
    output$wordcloud <- renderPlot({
      titles <- repo_data()$titles
      
      # Create a corpus from titles
      corpus <- Corpus(VectorSource(titles))
      corpus <- tm_map(corpus, content_transformer(tolower))
      corpus <- tm_map(corpus, removePunctuation)
      corpus <- tm_map(corpus, removeNumbers)
      corpus <- tm_map(corpus, removeWords, stopwords("en"))
      
      # Create term-document matrix
      tdm <- TermDocumentMatrix(corpus)
      m <- as.matrix(tdm)
      word_freq <- sort(rowSums(m), decreasing = TRUE)
      
      # Check if word_freq is valid (i.e., has data)
      if (length(word_freq) == 0) {
        output$wordcloud <- renderUI({
          tags$p("No valid words available to generate the word cloud.")
        })
        return(NULL)
      }
      
      # Remove plot margins to fit the word cloud within the available area
      par(mai = c(0, 0, 0, 0))
      
      # Create a word cloud using the selected colours
      wordcloud(
        names(word_freq),
        word_freq,
        min.freq = 3,
        max.words = 100,
        colors = c(input$colour1, input$colour2),  # Use selected colours
        rot.per = 0,
        fixed.asp = FALSE,
        random.order = FALSE
      )
    })
    
    # Get article IDs for citations
    article_ids <- data$id
    endpoint2 <- "https://api.figshare.com/v2/articles/"
    
    # Build citation data
    citation_list <- lapply(article_ids, function(article_id) {
      full_url_citation <- paste0(endpoint2, article_id)
      response <- GET(full_url_citation)
      
      if (http_status(response)$category == "Success") {
        citation_data <- fromJSON(rawToChar(response$content), flatten = TRUE)
        data.frame(Citation = citation_data$citation, URL = citation_data$figshare_url, stringsAsFactors = FALSE)
      } else {
        NULL
      }
    })
    
    # Combine all citation data
    combined_df(do.call(rbind, citation_list))
    
  })
  
  # Download handler for citations
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("citations_", Sys.Date(), ".csv", sep = "")  # Set filename with date
    },
    content = function(file) {
      write.csv(combined_df(), file, row.names = FALSE)  # Write combined_df to CSV
    }
  )
}

shinyServer(server)
