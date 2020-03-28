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
theme_set(theme_minimal())
```

The data come from the New York Times covid-19 data [github repo](https://github.com/nytimes/covid-19-data).


```r
covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")
```

Create a variable for days since the number of cases was over 20.

```r
covid19_comp_date <- covid19 %>% 
  group_by(state) %>% 
  arrange(date) %>% 
  mutate(cases_over20 = cases > 20,
         min_cases_over20 = which.max(cases_over20),
         days_since_first = row_number() - min_cases_over20
         ) 

#covid19_comp_date
```

Create a `gganimate` plot that shows the number of cases over time for each state. 


```r
covid19_anim <- covid19_comp_date %>% 
  ggplot(aes(x = days_since_first, y = cases, group = state)) +
  geom_line() + 
  scale_y_log10() +
  labs(title = 'State/Territory: {closest_state}', 
       x = "Days since # of cases greater than 20", 
       y = "Cumulative Cases") +
  transition_states(states = fct_reorder(as.factor(state), cases, max, .desc = TRUE), 
                    transition_length = 1,
                    state_length = 5) +
  shadow_trail(color = "gray")
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
