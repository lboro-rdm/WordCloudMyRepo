options(encoding = "UTF-8")

keyword = "autumn"

# Set your Figshare API key
api_key <- Sys.getenv("API_KEY")

# Set up the base URL and query parameters
base_url <- "https://api.figshare.com/v2/articles"

query_params <- list(
  institution = 2,
  page_size = 1000,
  search_for = keyword
)

response <- GET(
  url = base_url,
  query = query_params,
  add_headers(Authorization = paste("token", api_key))
)

# Try fetching the response content
data <- rawToChar(response$content)

# Parse JSON
data <- fromJSON(data)

titles <- data$title  # Extract titles
repo_data <- data.frame(titles = titles, stringsAsFactors = FALSE)  # Create dataframe

# Generate word cloud

  # Get titles as a vector of text
  titles <- repo_data$titles
  
  # Create a corpus from titles
  corpus <- Corpus(VectorSource(titles))
  
  # Clean up the text (removing stop words, punctuation, etc.)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("en"))
  
  # Create term-document matrix
  tdm <- TermDocumentMatrix(corpus)
  
  # Convert to matrix and sum the frequency of words
  m <- as.matrix(tdm)
  word_freq <- sort(rowSums(m), decreasing = TRUE)

  # Create a word cloud
  wordcloud(
    names(word_freq), 
    word_freq, 
    min.freq = 3, 
    max.words = 100, 
    colors = c("orange", "brown"), 
    rot.per=0, 
    fixed.asp=TRUE, 
    random.order = FALSE
  )
  
  
  #colors = brewer.pal(3, "Dark2")
### DOWNLOAD FILE ###
  
  article_ids <- data$id
  
  #Set the Figshare API request URL
  endpoint2 <- "https://api.figshare.com/v2/articles/"
  
  combined_df <- data.frame()
  
  #Use article IDs to get article citation
  for (article_id in article_ids) {
    full_url_citation <- paste0(endpoint2, article_id)
    
    # Get the article citation datadata
    response <- GET(full_url_citation)
    # Create a JSON file
    citation_data <- fromJSON(rawToChar(response$content), flatten = TRUE)
    #put the citation into a dataframe
    citation_df <-data.frame(Citation = citation_data$citation, URL = citation_data$figshare_url)
    combined_df <- rbind(combined_df, citation_df)
  }
  
  write.csv(combined_df, "combined_citations.csv", row.names = FALSE)


# In your server.R file
output$downloadData <- downloadHandler(
  filename = function() {
    paste("titles_", Sys.Date(), ".csv", sep = "")  # Set filename with date
  },
  content = function(file) {
    # Get the titles from repo_data
    titles_df <- repo_data()
    
    # Write the titles to a CSV file
    write.csv(titles_df, file, row.names = FALSE)
  }
)

library(magick)
img <- image_read("www/lottery_logo_black_rgb.jpg")
print(img)

print(www/lottery_logo_black_rgb.jpg)
