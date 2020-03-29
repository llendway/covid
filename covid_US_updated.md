---
title: "US covid_19 data from NYT"
author: "Lisa Lendway"
output: 
  html_document:
    keep_md: yes
---



Load libraries and set theme.

```r
library(tidyverse)
library(lubridate)
library(gganimate)
library(knitr)
library(geofacet)

theme_set(theme_minimal())
```

The data come from the New York Times covid-19 data [github repo](https://github.com/nytimes/covid-19-data).


```r
covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")
```

Create a variable for days since the number of cases was over 20. Also create some summarized data that will be used later.

```r
covid19_comp_date <- covid19 %>% 
  group_by(state) %>% 
  arrange(date) %>% 
  mutate(cases_over20 = cases > 20,
         min_cases_over20 = which.max(cases_over20),
         days_since_over20 = row_number() - min_cases_over20,
         state_ordered = fct_reorder(as.factor(state), 
                                         cases, 
                                         max, 
                                         .desc = TRUE))

#covid19_comp_date

max_days <- max(covid19_comp_date$days_since_over20)
for_labels <- covid19_comp_date %>% 
  group_by(state_ordered) %>% 
  summarize(max_case = max(cases),
            max_days_since20 = max(days_since_over20))
```


```r
#test plots
covid19_comp_date %>% 
  ggplot(aes(x = days_since_over20, y = cases, group = state)) +
  geom_line() + 
  coord_cartesian(xlim = c(-10, max_days)) +
  geom_text(aes(x = max_days_since20, 
                y = max_case, 
                label = state),
            color = "gray",
            data = for_labels) +
  scale_y_log10() +
#  facet_geo(~ state) #returns an error
  facet_wrap(~ state)
```


Create a `gganimate` plot that shows the number of cases over time for each state. 


```r
covid19_anim <- covid19_comp_date %>% 
  ggplot(aes(x = days_since_over20, y = cases, 
             group = state_ordered)) +
  geom_line() + 
  coord_cartesian(xlim = c(-10, max_days)) +
  geom_text(aes(x = max_days_since20, 
                y = max_case, 
                label = state_ordered),
            data = for_labels) +
  scale_y_log10() +
  labs(title = 'State/Territory: {closest_state}', 
       x = "Days since # of cases greater than 20", 
       y = "Cumulative Cases") +
  # transition_states(states = fct_reorder(as.factor(state), 
  #                                        cases, 
  #                                        max, 
  #                                        .desc = TRUE), 
  #                   transition_length = 1,
  #                   state_length = 5) +
  transition_states(states = state_ordered, 
                    transition_length = 1,
                    state_length = 5) +
  shadow_mark(color = "gray")
```

Create the animation (this takes a bit of time to run). Use code chunk option `eval=FALSE` so this isn't evaluated when the file is knit. 


```r
animate(covid19_anim, nframes = 100, duration = 30)
```

Save the animation.

```r
anim_save("covid19_us.gif")
```

Reload the animation so we can see it here. 

```r
knitr::include_graphics("covid19_us.gif")
```

![](covid19_us.gif)<!-- -->
