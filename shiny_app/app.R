
library(shiny)
library(tidyverse)

covid <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")

states <- tibble(state = c(state.name, "District of Columbia"),
                 state_abb = c(state.abb, "D.C."))

covid_long <- covid %>% 
  filter(`Country/Region` == "US") %>% 
  pivot_longer(cols = 5:ncol(covid), names_to = "date", values_to = "cases") %>% 
  select(-`Country/Region`) %>% 
  mutate(date = mdy(date)) %>% 
  separate(`Province/State`, sep = ",", into = c("state", "state_abb")) %>% 
  filter(cases > 0) 

covid_long_early <-
  covid_long %>% 
  filter(!is.na(state_abb), date < mdy("03/10/2020")) %>% 
  select(-state) %>% 
  mutate(state_abb = str_trim(state_abb)) %>% 
  left_join(states, by = c("state_abb"="state_abb")) %>% 
  select(-state_abb) %>% 
  select(state, everything()) %>% 
  group_by(state, date) %>% 
  summarize(cases = sum(cases)) %>% 
  ungroup()

covid_long_late <-
  covid_long %>% 
  filter(is.na(state_abb) | date >= mdy("03/10/2020")) %>% 
  select(state, date, cases)

covid_long_all <- covid_long_early %>% 
  bind_rows(covid_long_late) %>% 
  filter(!state %in% c("Diamond Princess", "Grand Princess", "US")) %>%  
  mutate(state_ordered = fct_rev(fct_reorder(as.factor(state), cases, max))) %>% 
  arrange(state, date)

state_name <- covid_long_all %>% 
  distinct(state) %>% 
  pull()

ui <- fluidPage(
  selectInput("state", "US State/Territory", 
              choices = state_name, 
              multiple = TRUE),
  submitButton(text = "Compare States"),
  plotOutput(outputId = "covid_comp")
)

server <- function(input, output) {
  output$covid_comp <- renderPlot({
    covid_long_all %>% 
      filter(state %in% input$state) %>% 
      ggplot(aes(x = date, y = cases)) +
      geom_line() +
      facet_wrap(vars(state)) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)