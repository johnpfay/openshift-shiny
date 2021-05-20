### App to enable visualization of Water Usage vs Social Vulnerability

#Load packages
library(shiny)
library(tidyverse)

#Import data
the_data <- read_csv('water_svi_data.csv') %>% 
    mutate(FIPS = as_factor(FIPS),
           year = as_factor(year)) 

#Import & wrangle the data dictionary
data_dict <- read_csv('SVIDocumentation_Table_DataDictionary_2018.csv') %>% 
    select(`2018 VARIABLE NAME`, `2018 DESCRIPTION`) %>% 
    filter(str_detect(`2018 VARIABLE NAME`, "\\bE")) %>% 
    rename(name = `2018 VARIABLE NAME`,
           desc = `2018 DESCRIPTION`)

#Get field names
water_fields <-  colnames(select(the_data,contains(".")))
svi_fields <- unlist(data_dict$name)
svi_names <- unlist(data_dict$desc)

#Function to get name from desc
get_fldname <- function(the_desc){
    fld_name <- data_dict %>% 
        filter(desc == !!the_desc) %>%
        select(name)
    return (fld_name[[1]])
    }

#svi_fields <- colnames(select(the_data,starts_with("E_")))

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
                        choices = svi_names,
                        selected = svi_names[1])
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    #Create and show the scatterplot
    output$distPlot <- renderPlot({
        #Translate SVI desc to name
        sviField <- get_fldname(input$DemField)
        ggplot(filter(the_data ,year %in% input$YearSelect), 
               aes_string(x=input$UseField, 
                          y=sviField)) +
            geom_point(aes(color=year)) +
            geom_smooth(method = "lm",aes(color=year))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
