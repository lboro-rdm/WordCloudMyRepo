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
      # Reset previous outputs
      output$wordcloud <- renderPlot(NULL)
      output$errorMessage <- renderText("")
      repo_data(data.frame(titles = character(), stringsAsFactors = FALSE))
      
      # Validate keyword
      if (input$keyword == "") {
        output$errorMessage <- renderText("Please enter a keyword to search.")
        return()
      }
      
      api_key <- Sys.getenv("API_KEY")
      
      # Build POST request with httr2
      library(httr2)
      
      req <- request("https://api.figshare.com/v2/articles/search") %>%
        req_headers(
          Authorization = paste("token", api_key),
          `Content-Type` = "application/json"
        ) %>%
        req_body_json(list(
          search_for = input$keyword,
          institution = 2,  # your institution ID
          group = 2,        # include group for scoping
          page = 1,
          page_size = 1000,
          order = "published_date",
          order_direction = "desc"
        ))
      
      resp <- req_perform(req)
      data <- resp_body_json(resp, simplifyVector = TRUE)
      
      # Check for results
      if (length(data) == 0 || is.null(data$title) || length(data$title) == 0) {
        output$errorMessage <- renderText("No search results found for the selected keyword.")
        return()
      }
      
      # Extract titles
      titles <- data$title
      repo_data(data.frame(titles = titles, stringsAsFactors = FALSE))
      
      # Generate wordcloud
      output$wordcloud <- renderPlot({
        titles <- repo_data()$titles
        library(tm)
        library(wordcloud)
        
        corpus <- Corpus(VectorSource(titles))
        corpus <- tm_map(corpus, content_transformer(tolower))
        corpus <- tm_map(corpus, removePunctuation)
        corpus <- tm_map(corpus, removeNumbers)
        corpus <- tm_map(corpus, removeWords, stopwords("en"))
        
        tdm <- TermDocumentMatrix(corpus)
        m <- as.matrix(tdm)
        word_freq <- sort(rowSums(m), decreasing = TRUE)
        
        if (length(word_freq) == 0) return(NULL)
        
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
      
      # Link to repository
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
    