# covid-19 cases in the US

Like many peole, I have been stressed out about the covid-19 pandemic. Somehow analyzing data helps relieve my stress. So, I put together some quick `gganimate` plots to illustrate the cases of covid-19 in the US by state/territory.

* The covid19_us.gif plot shows cumulative (total) cases by number of days since 20 cases for each state/territory.  
* The covid_us_barplot.gif shows a "racing" barplot of cumulative cases by state/territory for the top 10 states/terrritories in the US.  
* The covid_trajectory.gif shows new cases in the last three days by total cases for US states/territories. This plot was inspired by [Aatish Bhatia](https://aatishb.com/covidtrends/).

See the covid_US_updated.md file for the most up to date information. I switched to using data from the [NYT](https://github.com/nytimes/covid-19-data). The covid_cases_US.md file is out of date. 

The app (in the shiny_app folder) allows you to choose states/territories and compare curves. You can access the app directly at [https://lisalendway.shinyapps.io/covid-19_app/](https://lisalendway.shinyapps.io/covid-19_app/).
