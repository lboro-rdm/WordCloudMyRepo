  # Define server logic
  server <- function(input, output, session) {
    
    # Initialize reactive values
    repo_data <- reactiveVal(data.frame(titles = character(), stringsAsFactors = FALSE))
    combined_df <- reactiveVal(data.frame(Citation = character(), URL = character(), stringsAsFactors = FALSE))
    
    # Reactive expression to check if there are results
    hasResults <- reactive({
      req(repo_data())
      nrow(repo_data()) > 0
    })
    
    # Register `hasResults` as an output variable for conditionalPanel
    output$hasResults <- reactive({ hasResults() })
    outputOptions(output, "hasResults", suspendWhenHidden = FALSE)
    
    # Reactive expression to handle search
    observeEvent(input$search, {
      # Check if the keyword input is empty
      if (input$keyword == "") {
        # Show error message if no keyword is entered
        output$errorMessage <- renderText({
          "Please enter a keyword to search."
        })
        repo_data(data.frame(titles = character(), stringsAsFactors = FALSE))  # Clear previous data
        return()  # Early exit
      }
      
      req(input$keyword)
      print(input$keyword)
      
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
        # If no results, clear repo_data, clear the word cloud, and show error message
        repo_data(data.frame(titles = character(), stringsAsFactors = FALSE))
        output$wordcloud <- NULL  # Clear previous plot
        output$errorMessage <- renderText({
          "No search results found for the selected keyword."
        })
        return(NULL)  # Early exit
      }
      
      # Extract titles
      titles <- data$title
      repo_data(data.frame(titles = titles, stringsAsFactors = FALSE))  # Create dataframe
      
      output$errorMessage <- renderText({  # Clear previous messages
        ""
      })
      
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
          output$wordcloud <- NULL  # Clear the plot
          return(NULL)
        }
        
        # Create a word cloud using the selected colours
        wordcloud(
          names(word_freq),
          word_freq,
          min.freq = 3,
          max.words = 100,
          colors = c(input$colour1, input$colour2),
          rot.per = 0,
          fixed.asp = FALSE,
          random.order = FALSE
        )
      })
      
      output$repoLink <- renderUI({
        keyword <- URLencode(input$keyword, reserved = TRUE)
        url <- paste0("https://repository.lboro.ac.uk/search?q=", keyword)
        div(
          style = "text-align: center;",
          tags$a("See the items on the Research Repository", href = url, target = "_blank")
        )
      })
    })
    
  }
