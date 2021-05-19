

library(shiny)
library(tidyverse)

#import data
the_data <- read_csv('water_data.csv') %>% 
    mutate(FIPS = as_factor(FIPS),
           year = as_factor(year)) 

#Get field names
water_fields <-  colnames(select(the_data,contains(".")))
svi_fields <- colnames(select(the_data,starts_with("E")))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Water Explorer"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            checkboxGroupInput(
                inputId = "YearSelect",
                label = "Select the years",
                choices = unique(the_data$year),
                selected = "2015"
            ),
            selectInput("UseField",
                        "Select the water use field:",
                        choices = water_fields,
                        selected = water_fields[1]
            ),
            selectInput("DemField",
                        "Select SVI field",
                        choices = svi_fields,
                        selected = svi_fields[1])
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    #Collect inputs
    #the_year = input$YearSelect
    x_col = "Household.TotalUse"
    y_col = "E_POV"
    
    output$distPlot <- renderPlot({
        ggplot(filter(the_data ,year %in% input$YearSelect), 
               aes_string(x=input$UseField, 
                          y=input$DemField)) +
            geom_point(aes(color=year)) +
            geom_smooth(method = "lm",aes(color=year))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
