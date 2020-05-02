## COVID-19 German forecasting tool
## Johannes Ponge, Till sahlmüller European Research Center for Information Systems (ERCIS) at Muenster University (johannes.ponge@uni-muenster.de), March 2020

## includes code adapted from the following sources:
#https://github.com/eparker12/nCoV_tracker/

# load required packages
library(shiny)
library(geojsonio)
library(leaflet)
library(shinyWidgets)
library(shinydashboard)
library(shinyjs)
library(shinythemes)
library(dplyr)
library(rgdal)
library(ggplot2)
library(lubridate)
library(rmapshaper)
library(sp)


### COLORING ###
covid_col = "#cc4c02"

### APP STATE VARIABLES ###
projection_running <<- FALSE # flag to indicate that a projection was started


### DATA PROCESSING ###

# load data
source("data_loader.R")

# load projection model
#source("graph.R")
source("model.R")

# load map
# load simplified geojson
german_districts <- geojson_read("data/geo/json/landkreise-in-germany_small.geojson", what = "sp")

# cases aggregated by day
daily_cases = covid_cases %>%
    group_by(date) %>%
    summarize(cum_infections = sum(new_infections), cum_recoveries = sum(new_recoveries)) %>% 
    mutate(active = cum_infections - cum_recoveries)

casesMinDate = min(daily_cases$date)
casesMaxDate = max(daily_cases$date)


### MAP FUNCTIONS ###
# function to plot cumulative dailyCases cases by date
cumulative_plot = function(daily_cases, plot_date) {
    plot_df = subset(daily_cases, date<=plot_date)
    g1 = ggplot(plot_df, aes(x = date, y = cum_infections, color = covid_col, group = 1)) + geom_line() + geom_point(size = 1, alpha = 0.8) +
        ylab("Daily Cumulative Cases") + theme_bw() + 
        scale_colour_manual(values=c(covid_col)) +
        scale_y_continuous(labels = function(l) {trans = l / 1000; paste0(trans, "K")}) +
        theme(legend.title = element_blank(), legend.position = "", plot.title = element_text(size=10), 
              plot.margin = margin(5, 12, 5, 5))
    g1
}

# map with RKI infection data
rki_basemap <- leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
    setView(lng = 8, lat = 50, zoom = 6) %>%
    addTiles()

# map with projected infection data
projection_basemap <- leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
    setView(lng = 8, lat = 50, zoom = 6) %>%
    addTiles()

# redraw shapes in map with new data
update_map <- function(map_id, cases){
    
    # retrieve map object through leaflet proxy
    map <- leafletProxy(map_id)
    
    # compute cases per county
    district_infections = cases %>%
        group_by(ags) %>%
        summarize(cum_infections = sum(new_infections)) %>%
        mutate(ags = as.character(ags))
    
    # compute visualization
    viz_district = as.data.frame(german_districts$cca_2) %>%
        mutate(ags = as.character(german_districts$cca_2)) %>%
        select(ags) %>%
        left_join(district_infections) %>%
        mutate(cum_infections = replace(cum_infections, is.na(cum_infections), 0)) # replace N/A values with 0
    
    # compute bins for map fill color
    binsNo <- 7
    uniqueCounts <- sort(unique(viz_district$cum_infections))
    uniqueNo <- length(uniqueCounts)
    r <- uniqueNo %% binsNo
    s <- floor(uniqueNo / binsNo)
    
    #compute row numbers of values ot make bins
    if(uniqueNo <= binsNo){
        rows <- c(1:uniqueNo)
    } else {
        rows <- unique(c(seq(0, (s + 1) * r, s + 1), seq((s + 1) * r, uniqueNo, s)))
    }
    
    # filter for rows with pivotal numbers for bins
    bins <- data.frame(bin = uniqueCounts) %>%
        filter(row_number() %in% rows)
    
    if(uniqueNo <= binsNo)
        bins = data.frame(bin = uniqueCounts)
    
    # color palette    
    pal <- colorBin(palette = "Reds", domain = viz_district$cum_infections, bins = unique(c(0,1,bins$bin)))
    
    # remove shapes & controls and redraw them
    map %>%
        clearShapes() %>%
        clearControls() %>%
        addPolygons(data = german_districts, stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.6,
            label = ~paste0(name_2, " (", viz_district$cum_infections, " cases)"), color = ~pal(viz_district$cum_infections)) %>%
        addLegend(pal = pal, values = viz_district$cum_infections, opacity = 0.7, title = "Infections per District",
            position = "bottomright")
}


### PROJECTION FUNTIONS ###

project_spread <- function(start_date, commutes_frac, air_frac, beta, mu, delta_t, days){
    # initial situation based on RKI data on selected date
    # configure dataframe with initial infections to run projection from
    initial_scenario <- init_projection_at_date(covid_cases, start_date)
    
    # run projection
    projected_cases = run_projection(initial_scenario, commutes_frac, air_frac, beta, mu, delta_t, days)

    # add day to projected cases
    projected_cases = projected_cases %>%
        mutate(date = start_date + days(day))
    
    update_map("projection_map", projected_cases)
}




# create Shiny ui
ui <- navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
     "CoViz Germany 1.0", id="nav",

     # Reported Cases
     tabPanel(
        title = "Reported Cases",
        value = "reported",
        div(class="outer",
            tags$head(includeCSS("styles.css")),
            leafletOutput("rki_map", width="100%", height="100%"),
            
            absolutePanel(id = "reported_controls", class = "panel panel-default",
                top = 80, left = 20, width = 250, fixed=TRUE,
                draggable = TRUE, height = "auto",
                h3("Quick Info", align = "left"),
                plotOutput("cumulative_plot", height="130px", width="100%"),
              
                sliderInput("plot_date",
                    label = h5("Select Mapping Date"),
                    min = casesMinDate,
                    max = casesMaxDate,
                    value = casesMaxDate,
                    timeFormat = "%d %b"
                ),
                h5("Project spread from here..."),
                actionButton("switch_tab_projection", "Switch to Projection")
            )
        )
    ),
     
    # Projected Cases
    tabPanel(shinyjs::useShinyjs(),
        title =  "Projection",
        value = "projected",
        div(class="outer",
            tags$head(includeCSS("styles.css")),
            leafletOutput("projection_map", width="100%", height="100%"),
          
            absolutePanel(id = "projection_controls", class = "panel panel-default",
                top = 80, left = 20, width = 250, fixed=TRUE,
                draggable = TRUE, height = "auto",
                h3("Configuration", align = "left"),
                
                sliderInput("projection_start_date",
                    label = h5("Projection Start Date (Based on RKI Data)"),
                    min = casesMinDate,
                    max = casesMaxDate,
                    value = casesMaxDate,
                    timeFormat = "%d %b"
                ),
                
                sliderInput("projection_duration",
                    label = h5("Projection Duration (Days)"),
                    min = 0,
                    max = 15,
                    value = 5
                ),
                
                sliderInput("beta",
                    label = h5("Infection Rate β"),
                    min = 0,
                    max = 1,
                    value = 0.53
                ),
                
                sliderInput("mu",
                    label = h5("Recovery Rate μ"),
                    min = 0,
                    max = 1,
                    value = 0.02
                ),
                
                sliderInput("commutes_frac",
                            label = h5("Fraction of Commutes"),
                            min = 0,
                            max = 1,
                            value = 1
                ),
                
                sliderInput("air_frac",
                            label = h5("Fraction of Air-Travel"),
                            min = 0,
                            max = 1,
                            value = 1
                ),
                
                sliderInput("delta_t",
                            label = h5("Fraction of time at home"),
                            min = 0,
                            max = 1,
                            value = 0.5
                ),
                
                actionButton("toggle_run_projection", "Run Projection")
                
            )
        )
    ),
    
    tabPanel(
        title = "About",
        value = "About",
        div(class="about",
            tags$head(includeCSS("styles.css")),
            withMathJax(includeMarkdown("about.md"))
        )
    )

)
    

# Define server logic required to draw a histogram
server <- function(input, output, session) {

    ## MAPS ##
    
    # map with RKI data
    output$rki_map <- renderLeaflet({ 
        rki_basemap
    })
    
    # projection map
    output$projection_map <- renderLeaflet({ 
        projection_basemap
    })

    
    ## PLOTS ##
    
    # plot daily cumulative cases
    output$cumulative_plot <- renderPlot({
        cumulative_plot(daily_cases, input$plot_date)
    })
    
    
    ## BUTTONS ##
    
    # switch to projection
    observeEvent(input$switch_tab_projection, {
        updateTabsetPanel(session, "nav", selected = "projected")
        
        # copy current plot date
        updateSliderInput(session, "projection_start_date", value = input$plot_date, timeFormat = "%d %b")
    })
    
    
    # run projection
    observeEvent(input$toggle_run_projection, {
        projection_running <<- !projection_running
        
        if(projection_running){
            # disable all controls
            shinyjs::disable("projection_start_date")
            shinyjs::disable("projection_duration")
            shinyjs::disable("beta")
            shinyjs::disable("mu")
            shinyjs::disable("commutes_frac")
            shinyjs::disable("air_frac")
            shinyjs::disable("delta_t")

            # relable run projection button
            updateActionButton(session, "toggle_run_projection", label = "Reset Projection")
            
            # run projection
            project_spread(start_date = input$projection_start_date,
                           commutes_frac = input$commutes_frac,
                           air_frac = input$air_frac,
                           beta = input$beta,
                           mu = input$mu,
                           delta_t = input$delta_t,
                           days = input$projection_duration)
            }
        
        else {
            
            # enable all controls
            shinyjs::enable("projection_start_date")
            shinyjs::enable("projection_duration")
            shinyjs::enable("beta")
            shinyjs::enable("mu")
            shinyjs::enable("commutes_frac")
            shinyjs::enable("air_frac")
            shinyjs::enable("delta_t")

            # relable run projection button
            updateActionButton(session, "toggle_run_projection", label = "Run Projection")
        }
        
        
    })
    
    
    ## SLIDERS ##
    
    # reported cases slider
    observeEvent(input$plot_date, {
        
        # update map on slider change
        filtered_cases = covid_cases %>% filter(as.POSIXct(date) < input$plot_date)
        update_map("rki_map", filtered_cases)
    })
    
    
    # projected cases slider
    observeEvent(input$projection_start_date, {
        
        # update map on slider change
        filtered_cases = covid_cases %>% filter(as.POSIXct(date) < input$projection_start_date)
        update_map("projection_map", filtered_cases)
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)