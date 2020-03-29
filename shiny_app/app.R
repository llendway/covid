
library(shiny)
library(tidyverse)

covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")

covid19_comp_date <- covid19 %>% 
  group_by(state) %>% 
  arrange(date) %>% 
  mutate(cases_over20 = cases > 20,
         min_cases_over20 = which.max(cases_over20),
         days_since_first = row_number() - min_cases_over20
  ) 

state_terr_name <- covid19_comp_date %>% 
  distinct(state) %>% 
  arrange(state) %>% 
  pull()

ui <- fluidPage(
  selectInput("state", "US State/Territory", 
              choices = state_terr_name, 
              multiple = TRUE),
  checkboxInput("log", "Plot cases on log scale",
                value = FALSE),
  submitButton(text = "Compare States/Territories"),
  plotOutput(outputId = "covid_comp")
)

server <- function(input, output) {
  output$covid_comp <- renderPlot({
    covid_plot <- covid19_comp_date %>% 
      filter(state %in% input$state) %>% 
      ggplot(aes(x = days_since_first, y = cases, 
                 group = state, 
                 color = state)) +
      geom_line() +
      labs(x = "Days since # of cases greater than 20", 
           y = "Cumulative Cases") +
      theme_minimal()

      if(input$log)
      covid_plot <- covid_plot +  scale_y_log10()
      
      return(covid_plot)
      
  })
}

shinyApp(ui = ui, server = server)