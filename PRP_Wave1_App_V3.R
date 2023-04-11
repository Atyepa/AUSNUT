library(lubridate)
library(openxlsx)
library(readxl)
library(writexl)
library(plotly)
library(highcharter)
library(shiny)
library(shinydashboard)
library(shinyWidgets)

#-------------------
# Import datacube
#-------------------

daturl <- "https://www.abs.gov.au/articles/healthy-food-partnership-reformulation-program-two-year-progress/4316D002_2020_21_ESTIMATES.xlsx"

download.file(daturl, "datacube.xlsx", mode = "wb")

datapath <- "./datacube.xlsx"

options(warn=-1)                                           
`%!in%` = Negate(`%in%`)                                           

# Colours (emulate ABS website colours)
abscol <- c("#336699", "#669966", "#99CC66", "#993366", "#CC9966", "#666666",                                            
            "#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462",                                  
            "#B3DE69", "#FCCDE5","#D9D9D9", "#BC80BD", "#CCEBC5", "#FFED6F")                                  

# Modified palette order to make stronger contrast in certain charts
targetcol <- c("#336699", "#669966", "#993366")
targetcol2 <- c("#669966", "#993366")

# Define table colNames to apply to datacube tables: Note PP = 'participating products' ; AP = 'All products'                                          
T1_1names <- c("Food_category", "n_prods_w_sales", "n_reduced_nutrient", "Pc_prods_red_nut",                                        
               "Target_per100g", "June2020_per100g", "June2022_per100g", "Change_per100g",                                        
               "n_met_target2020", "n_met_target2022", "Pc_met_target2020", "Pc_met_target2022")

T1_2names <- c("Food_category", "June2020TnPP", "June2022TnPP", "ChangeTnPP",
               "June2020_percapPP", "June2022_percapPP", "Change_percapPP",                                       
               "Pc_change_percapPP", "Pc_overall_redPP", "Pc_dietsource_2020PP", "Pc_dietsource_2022PP",
               "June2020_percapAP", "June2022_percapAP", "Change_percapAP",
               "Pc_dietsource_2020AP", "Pc_dietsource_2022AP", "Pc_PP_nutrient_in_AP")


T1_3names <- c("Class_level", "Food_code", "Food_group", "June2020TnAP", "June2022TnAP", "ChangeTnAP",
               "June2020_percapAP", "June2022_percapAP", "Change_percapAP", "Pc_change_percapAP",                                     
               "Pc_overall_redAP", "Pc_dietsource_2020AP", "Pc_dietsource_2022AP")                                             

#------------------------------- 
# Cleaning functions (x, names)                                
#------------------------------- 

#--- For Table 1.1 & 2.1                                  
cleanT1_1 <- function(x,names) {                                             
  
  x %>%                                
    
    setNames(T1_1names) %>%                                 
    
    filter(Food_category != "0") %>%                                        
    
    mutate(                                          
      n_prods_w_sales = as.numeric(n_prods_w_sales),                                    
      n_reduced_nutrient = as.numeric(n_reduced_nutrient),                                        
      Pc_prods_red_nut = as.numeric(Pc_prods_red_nut),                               
      June2020_per100g = as.numeric(June2020_per100g),                                             
      June2022_per100g =as.numeric(June2022_per100g),                                              
      Change_per100g =as.numeric(Change_per100g),                                      
      Target_per100g =as.numeric(Target_per100g),                                          
      n_met_target2020 =as.numeric(n_met_target2020),                               
      n_met_target2022 =as.numeric(n_met_target2022),                               
      Pc_met_target2020 =as.numeric(Pc_met_target2020),                                           
      Pc_met_target2022 =as.numeric(Pc_met_target2022))                                           
  
}                                             

#--- For Table 1.2 & 2.2                                  
cleanT1_2 <- function(x,names) {                                             
  x %>%
    setNames(T1_2names) %>%                                 
    drop_na() %>%                                           
    mutate(
      June2020TnPP = as.numeric(June2020TnPP),                                
      June2022TnPP = as.numeric(June2022TnPP),                               
      ChangeTnPP = as.numeric(ChangeTnPP),                                       
      June2020_percapPP = as.numeric(June2020_percapPP),                                        
      June2022_percapPP = as.numeric(June2022_percapPP),                                        
      Change_percapPP = as.numeric(Change_percapPP),                                
      Pc_change_percapPP = as.numeric(Pc_change_percapPP),                                   
      Pc_overall_redPP = as.numeric(Pc_overall_redPP),                                   
      Pc_dietsource_2020PP = as.numeric(Pc_dietsource_2020PP),                                             
      Pc_dietsource_2022PP = as.numeric(Pc_dietsource_2022PP),                                             
      June2020_percapAP = as.numeric(June2020_percapAP),                                       
      June2022_percapAP = as.numeric(June2022_percapAP),                                       
      Change_percapAP = as.numeric(Change_percapAP),                                
      Pc_dietsource_2020AP = as.numeric(Pc_dietsource_2020AP),                                             
      Pc_dietsource_2022AP = as.numeric(Pc_dietsource_2022AP),                                             
      Pc_PP_nutrient_in_AP = as.numeric(Pc_PP_nutrient_in_AP))                               
}                                             



# For Table 1.3 & 2.3

cleanT1_3 <- function(x,names) {x %>%                                
    setNames(T1_3names) %>%
    mutate(
      Food_code = as.numeric(Food_code ),
      June2020TnAP = as.numeric(June2020TnAP ),
      June2022TnAP = as.numeric(June2022TnAP ),                                             
      ChangeTnAP = as.numeric(ChangeTnAP),
      June2020_percapAP = as.numeric(June2020_percapAP ),                                      
      June2022_percapAP = as.numeric(June2022_percapAP ),
      Change_percapAP = as.numeric(Change_percapAP ),                           
      Pc_change_percapAP = as.numeric(Pc_change_percapAP),                                   
      Pc_overall_redAP = as.numeric(Pc_overall_redAP),                                  
      Pc_dietsource_2020AP = as.numeric(Pc_dietsource_2020AP ),                                            
      Pc_dietsource_2022AP = as.numeric(Pc_dietsource_2022AP)) %>%                                  
    mutate_if(is.character, funs(replace(.,is.na(.), 0))) %>%                                             
    mutate_if(is.numeric, funs(replace(.,is.na(.), 0))) %>%                               
    filter(Class_level !="0")                                            
  
}                                             

#------------------------------------------------- 
#---- Load Datacube--
#------------------------------------------------- 

# Read in 6 data cube tables:                                     
T1_1 <- read_excel(datapath, sheet = 2, range = "A9:L37") %>%
  cleanT1_1(T1_1names) %>%
  mutate(Nutrient = "Sodium")                                  


T2_1 <- read_excel(datapath, sheet = 5, range = "A9:L15") %>%
  cleanT1_1(T1_1names) %>%
  mutate(Nutrient = "Satfat")                                     

T1_2 <- read_excel(datapath, sheet = 3, range = "A9:Q41") %>%
  cleanT1_2(T1_2names) %>%
  mutate(Nutrient = "Sodium")                                  

T2_2 <- read_excel(datapath, sheet = 6, range = "A9:Q19") %>%
  cleanT1_2(T1_2names) %>%
  mutate(Nutrient = "Satfat")                                     

T1_3 <- read_excel(datapath, sheet = 4, range = "A9:M142") %>%
  cleanT1_3(T1_3names) %>%
  mutate(Nutrient = "Sodium") %>%
  select(Class_level, Food_code, Food_group, Nutrient, everything())                                       

T2_3 <- read_excel(datapath, sheet = 7, range = "A9:M142") %>%
  cleanT1_3(T1_3names) %>%
  mutate(Nutrient = "Satfat") %>%
  select(Class_level, Food_code, Food_group, Nutrient, everything())


# Stack sodium + satfat to make 3 dfs                                     
Tb1 <- T1_1 %>%
  bind_rows(T2_1) %>%
  mutate(Food_category = str_remove(Food_category, ("\\(e\\)"))) %>%
  mutate(Food_category = str_remove(Food_category, ("\\(d\\)")))

Tb2 <- T1_2 %>%
  bind_rows(T2_2) %>%
  mutate(Food_category = str_remove(Food_category, ("\\(e\\)"))) %>%
  mutate(Food_category = str_remove(Food_category, ("\\(d\\)")))                                              

Tb3 <- T1_3 %>%                                            
  bind_rows(T2_3) %>%                               
  mutate(Class_level = case_when(Class_level == "Total" ~ "Major", TRUE ~ Class_level))                                

# Combine Tb1 & Tb2                                    

Tb1_Tb2 <- Tb2 %>%                     
  left_join(Tb1, by = c("Nutrient", "Food_category")) %>%   
  mutate(Pc_chg_per100g = round(Change_per100g / June2020_per100g*100,1)) %>%  # Make Pc_chg_per100g   
  select(Food_category, Nutrient,  n_prods_w_sales,   n_reduced_nutrient,   Pc_prods_red_nut,     Target_per100g,                        
         June2020_per100g,     June2022_per100g,   Change_per100g, n_met_target2020,  n_met_target2022,  Pc_met_target2020,            
         Pc_met_target2022,    June2020TnPP,  June2022TnPP,  ChangeTnPP,    June2020_percapPP,    June2022_percapPP,                      
         Change_percapPP,      Pc_change_percapPP,   Pc_overall_redPP,     Pc_dietsource_2020PP, Pc_dietsource_2022PP, June2020_percapAP,
         June2022_percapAP,    Change_percapAP,      Pc_dietsource_2020AP,  Pc_dietsource_2022AP,  Pc_PP_nutrient_in_AP, Pc_chg_per100g)


# Load Food_cat ordering table to attach shorter labels                                 
food_cat_labels <- read.xlsx("https://github.com/Atyepa/AUSNUT/raw/master/ShortNames.xlsx") %>%
  select(Food_category,Shortname, Code)                                        

Tb1_Tb2 <- Tb1_Tb2 %>%
  left_join(food_cat_labels, by = "Food_category") %>%
  select(Shortname, Code, everything(), -Food_category) %>%
  rename(Food_category = Shortname)


# For Tb1_Tb2 (equiv to datacube Tables 1.1, 1.2, 2.1, 2.2) we pivot the periods (2020 / 2022) long for each pair of period variables:                                              
Foodcat1 <- Tb1_Tb2 %>%                                          
  select(1:3, 8,9) %>%                                    
  rename(June2020 = June2020_per100g,
         June2022 = June2022_per100g) %>%
  pivot_longer(4:5, names_to = "Period", values_to = "Amt_per100g")

Foodcat2 <- Tb1_Tb2 %>%
  select(1:3,11:12)%>%
  rename(June2020 = n_met_target2020,
         June2022 = n_met_target2022) %>%
  pivot_longer(4:5, names_to = "Period", values_to = "n_met_target")

Foodcat3 <- Tb1_Tb2 %>%
  select(1:3,13:14)%>%
  rename(June2020 = Pc_met_target2020,
         June2022 = Pc_met_target2022) %>%
  pivot_longer(4:5, names_to = "Period", values_to = "Pc_met_target")                                  


Foodcat4 <- Tb1_Tb2 %>%
  select(1:3,15:16)%>%                                 
  rename(June2020 = June2020TnPP,
         June2022 = June2022TnPP) %>%
  pivot_longer(4:5, names_to = "Period", values_to = "Tonnes_PP")                                         


Foodcat5 <- Tb1_Tb2 %>%                                          
  select(1:3,18:19)%>%                                 
  rename(June2020 = June2020_percapPP,                                          
         June2022 = June2022_percapPP) %>%                                        
  pivot_longer(4:5, names_to = "Period", values_to = "Amt_percap_PP")                               


Foodcat6 <- Tb1_Tb2 %>%                                          
  select(1:3,23:24)%>%                                 
  rename(June2020 = Pc_dietsource_2020PP,                                     
         June2022 = Pc_dietsource_2022PP) %>%                                   
  pivot_longer(4:5, names_to = "Period", values_to = "Pc_source_PP")                                   


Foodcat7 <- Tb1_Tb2 %>%                                          
  select(1:3,25:26)%>%                                 
  rename(June2020 = June2020_percapAP,                                
         June2022 = June2022_percapAP) %>%                                        
  pivot_longer(4:5, names_to = "Period", values_to = "Amt_percap_AP")


Foodcat8 <- Tb1_Tb2 %>%
  select(1:3,28:29)%>%
  rename(June2020 = Pc_dietsource_2020AP,
         June2022 = Pc_dietsource_2022AP) %>%
  pivot_longer(4:5, names_to = "Period", values_to = "Pc_source_AP")


# Join by Food_category + Nutrient + Period                                       
Foodcat_period <- Foodcat1 %>%                                            
  left_join(Foodcat2, by = c("Food_category", "Nutrient", "Code", "Period")) %>%  
  left_join(Foodcat3, by = c("Food_category", "Nutrient", "Code", "Period")) %>%  
  left_join(Foodcat4, by = c("Food_category", "Nutrient", "Code", "Period")) %>%                               
  left_join(Foodcat5, by = c("Food_category", "Nutrient", "Code", "Period")) %>%                               
  left_join(Foodcat6, by = c("Food_category", "Nutrient", "Code", "Period")) %>%                               
  left_join(Foodcat7, by = c("Food_category", "Nutrient", "Code", "Period")) %>%                               
  left_join(Foodcat8, by = c("Food_category", "Nutrient", "Code", "Period"))

# Non-timebound variables                                        
Foodcat_np <- Tb1_Tb2 %>%
  select(1:7, 10,17,20,27,30,31)

# For Tb3 (equiv to datacube Tables 1.3, 2.3) we pivot the periods (2020 / 2022) long for each pair of period variables:                                               

# Join non-period to period dfs:
Foodcat_df01 <- Foodcat_period %>%
  left_join(Foodcat_np, by = c("Food_category", "Nutrient", "Code")) %>%
  mutate(Unit =
           case_when(Nutrient == "Sodium" ~ "mg",
                     Nutrient == "Satfat" ~ "g",
                     TRUE ~ ""))

#--------------------------------------------                                          
# ---Make categoricals into factors---                                      
#--------------------------------------------                                          

# Define Foodcategory levels                                     
foodcat_lvl <- c("Leavened breads",
                 "Flat breads",                       
                 "Cakes, Muffins and Slices",
                 "Flavoured savoury biscuits/crackers",
                 "Plain corn/rice cakes", 
                 "Plain savoury biscuits/crackers",
                 "Dry savoury pastries",     
                 "Wet savoury pastries",                
                 "Coated Meat and Poultry",             
                 "Coated Seafood",             
                 "Pizza",                      
                 "Cheddar/cheddar style cheese products",
                 "Processed cheeses",
                 "Asian style cooking sauces",
                 "Gravies + finishing sauces",        
                 "Pesto",         
                 "Other savoury sauces",
                 "Bacon",                
                 "Frankfurts and Saveloys",
                 "Ham",             
                 "Processed deli meat",
                 "Sausages",                 
                 "Potato snacks",
                 "Salt and vinegar snacks",
                 "Extruded and pelleted snacks",
                 "Vegetable, grain and other snacks",
                 "Soups",   
                 "Total of PRP categories",
                 "Out of PRP scope",
                 "Total foods and beverages")                                 

Foodcat_df <- Foodcat_df01 %>%                                           
  # mutate(Food_category = factor(Food_category, levels = foodcat_lvl),  ??
  mutate(Food_category = factor(Food_category),                                            
         Nutrient = factor(Nutrient, levels = c("Sodium", "Satfat")),
         Unit = factor(Unit, levels= c("mg", "g")),
         Period = factor(Period, labels = c("June, 2020", "June, 2022"))) %>%
  select(Food_category, Code, Period, Nutrient, Unit, 
         n_prods_w_sales,  n_reduced_nutrient,  Pc_prods_red_nut , 
         Amt_per100g , Change_per100g, Pc_chg_per100g, Target_per100g,  n_met_target ,  Pc_met_target,
         Tonnes_PP,   ChangeTnPP,  Amt_percap_PP,  Amt_percap_AP, 
         Change_percapPP,  Change_percapAP, Pc_source_PP, Pc_source_AP,  Pc_PP_nutrient_in_AP) 


food_cat <- Foodcat_df %>% 
  select(Food_category) %>% 
  distinct()

food_cat <- as.list(as.character(food_cat$Food_category))

food_cat_select <- Foodcat_df %>% 
  select(Food_category, Code) %>% 
  filter(Code %!in% c(28, 29,30)) %>% 
  select(Food_category) %>% 
  distinct()

food_cat_select <- as.list(as.character(food_cat_select$Food_category))


# Levels for measures: 
lvls <- c("n_prods_w_sales",  "n_reduced_nutrient", "Pc_prods_red_nut", 
          "Amt_per100g", "Change_per100g", "Target_per100g", "n_met_target", "Pc_met_target",  
          "Pc_PP_nutrient_in_AP", "Pc_chg_per100g", "Tonnes_PP",
          "ChangeTnPP",  "Amt_percap_PP",  "Amt_percap_AP",   
          "Change_percapPP", "Change_percapAP", "Pc_source_PP", "Pc_source_AP" )

labels <- c("n products", "n prods reducing", "% prods reducing",
            "Amt per 100g", "Change per 100g", "Target per100g", "n prods met target", "% prods met target",
            "Coverage % (partic. prods of all prods)", "% change per 100g", "Tonnes (partic. prods)",
            "Change in tonnes (partic. prods)", "Percapita amount (partic. prods)", "Percapita amount (all prods)",
            "Percapita change  (partic. prods)", "Percapita change  (all prods)", "Dietary source % (partic. prods)",
            "Dietary source % (all prods)")


Foodcat_dfL <- Foodcat_df %>% 
  pivot_longer(6:23, names_to = "measure", values_to = "val") %>% 
  mutate(Unit = case_when(measure %in% c("n_prods_w_sales", "n_reduced_nutrient", "n_met_target") ~ "Count", 
                          measure %in% c("Pc_prods_red_nut", "Pc_met_target", "Pc_source_PP",
                                         "Pc_source_AP", "Pc_PP_nutrient_in_AP", "Pc_chg_per100g") ~ "%", 
                          measure %in% c("Amt_per100g", "Change_per100g", "Target_per100g") ~ Unit, 
                          measure %in% c("Tonnes_PP", "ChangeTnPP") ~ "Tonnes", TRUE ~ Unit)) 

# type = 1 ~ non-time based, type = 2 ~ time-based.
Foodcat_dfL <- Foodcat_dfL %>% 
  mutate(type = case_when(measure %in% c("n_prods_w_sales", "n_reduced_nutrient", "Pc_prods_red_nut",  
                                         "Change_per100g",  "ChangeTnPP",  "Change_percapPP", "Pc_PP_nutrient_in_AP",
                                         "Pc_chg_per100g", 
                                         "Change_percapAP", "Target_per100g")~ 1, 
                          measure %in% c(
                            "Amt_per100g", "n_met_target", "Pc_met_target",           
                            "Tonnes_PP", "Amt_percap_PP", "Amt_percap_AP",         
                            "Pc_source_AP", "Pc_source_PP") ~ 2, TRUE ~ 0)) %>% 
  mutate(measure = factor(measure, levels = lvls, labels = labels))



#---Today's date 
now <- format(today(),"%d %B %Y")

# dashboardHeader(title = "HFP Reformulation progress, Wave 1 progress (June 2020 to June 2020)"),
# UI --------------
ui <- dashboardPage(
  dashboardHeader(title = "HFP Reformulation:"),
  dashboardSidebar(
    width = 300,
    selectInput("nutrient_select", "Choose a nutrient:", 
                choices = c("Sodium", "Saturated fat" = "Satfat")),
    
    pickerInput("Food_category", "Choose a food category:", choices = c(food_cat), 
                selected = c(food_cat_select), multiple = TRUE, options = list(`actions-box` = TRUE)), 
    
    selectInput("meas_prod_select", "Participating product information:", 
                choices = c("n products",
                            "n prods reducing", 
                            "% prods reducing", 
                            "Amt per 100g", 
                            "Change per 100g", 
                            "% change per 100g",
                            "n prods met target", 
                            "% prods met target", 
                            "Coverage % (partic. prods of all prods)"), 
                selected = "n products"),
    
    selectInput("meas_cons_select", "Consumption impact information:", 
                choices = c("Tonnes (partic. prods)",
                            "Change in tonnes (partic. prods)",
                            "Percapita amount (partic. prods)", 
                            "Percapita amount (all prods)", 
                            "Percapita change  (partic. prods)", 
                            "Percapita change  (all prods)", 
                            "Dietary source % (partic. prods)", 
                            "Dietary source % (all prods)"), 
                selected = "Percapita amount (partic. prods)")
    
  ), 
  
  dashboardBody(
    tags$head(tags$style(HTML(
      '.myClass { 
        font-size: 20px;
        line-height: 50px;
        text-align: left;
        font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
        padding: 0 15px;
        overflow: hidden;
        color: white;
      }
    '))),
    tags$script(HTML('
      $(document).ready(function() {
        $("header").find("nav").append(\'<span class="myClass"> Wave 1 progress (June 2020 to June 2020) </span>\');
      })
     ')),
    tabBox(height = "740px", width = "850px",
           
           tabPanel("Products", 
                    fluidRow(
                      column(12,highchartOutput("hcontainer1b",height = "720px", width = "1000px")))),
           
           tabPanel("Consumption impact", 
                    fluidRow(
                      column(12,highchartOutput("hcontainer2b",height = "720px", width = "1000px")))),
           
           tabPanel("Products v consumption", 
                    fluidRow(
                      column(6,highchartOutput("hcontainer1",height = "720px", width = "740px")),
                      column(6,highchartOutput("hcontainer2",height = "720px", width = "740px")))),
           
           tabPanel("Table", DT::dataTableOutput("table"))),
    
    # adding the div tag to the mainpanel
    tags$div(class="header", checked=NA,
             tags$p("Source: ", tags$a(href="https://www.abs.gov.au/articles/healthy-food-partnership-reformulation-program-two-year-progress",
                                       target="_blank", "Healthy Food Partnership Reformulation Program: Wave 1, two-year progress")),
             tags$p(paste0("Data retrieved from abs.gov.au, ", now))),
    
    downloadButton("downloadTb", "Download graph/table selection:"),
  ))


server <- function(input, output) {
  
  nutrient <- reactive({
    list(nutrient_select = input$nutrient_select)
  })
  
  food_cat <- reactive({
    list(Food_category = input$Food_category)
  })
  
  
  measure_prod <- reactive({
    list(meas_prod_select = input$meas_prod_select)
  })
  
  measure_cons <- reactive({
    list(meas_cons_select = input$meas_cons_select)
  })
  
  # Perform some ordering 
  df_prod <- reactive({Foodcat_dfL %>% 
      filter(Nutrient %in% nutrient()$nutrient_select) %>% 
      filter(Food_category %in% food_cat()$Food_category) %>% 
      filter(measure == measure_prod()$meas_prod_select) %>% 
      group_by(Code) %>% 
      mutate(avg = mean(val)) %>% 
      arrange(desc(val)) %>% 
      ungroup() 
  })
  
df_cons <- reactive({Foodcat_dfL %>% 
      filter(Nutrient %in% nutrient()$nutrient_select) %>% 
      filter(Food_category %in% food_cat()$Food_category) %>% 
      filter(measure == measure_cons()$meas_cons_select)
  })
  
  # Matched order to df_prod  
df_consm <- reactive({
    df_cons()[order(match(df_cons()$Code, df_prod()$Code)), ]  
  })
  
  type_prod <- reactive({
    df_prod() %>% 
      group_by(type) %>% 
      summarise(type = max(type))
  })
  
  type_cons <- reactive({
    df_cons() %>% 
      group_by(type) %>% 
      summarise(type = max(type))
  })
  
  
  U_prod <- reactive({
    df_prod() %>% 
      group_by(Unit) %>% 
      summarise(Unit = max(Unit))
  })
  
  U_cons <- reactive({
    df_cons() %>% 
      group_by(Unit) %>% 
      summarise(Unit = paste0("_",max(Unit), "_"))
  })  
  
  # Combination table
  table <- reactive({
    df_prod() %>%
      left_join(df_cons(), by = c("Period", "Food_category", "Nutrient")) %>%
      select(-c("Code.x", "Unit.x", "Unit.y", "Code.y", "type.x", "type.y")) %>%
      rename(`Products measure` = measure.x, `Consumption measure` = measure.y) %>% 
      rename(!!U_prod()$Unit := val.x, !!U_cons()$Unit := val.y)
  })
  
  
  output$hcontainer1 <- renderHighchart({
    
    if(type_prod()$type == 2) {
      
      hc1 <- df_prod() %>% 
        drop_na() %>% 
        arrange(desc(val)) %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val,
                     group = Period)) %>%
        hc_title(text = paste0("Participating products: ", input$meas_prod_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_prod()$Unit))) %>%
        hc_colors(abscol)  
      
    }
    
    if(type_prod()$type == 1) {
      
      hc1 <- df_prod() %>% 
        select(-Period) %>% 
        distinct() %>% 
        drop_na() %>% 
        arrange(desc(val)) %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val,
                     group = measure)) %>%
        hc_title(text = paste0("Participating products: ", input$meas_prod_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_prod()$Unit))) %>%
        hc_colors(abscol)  
      
    }            
    hc1
  })
  
  output$hcontainer1b <- renderHighchart({
    
    if(type_prod()$type == 2) {
      
      hc1b <- df_prod() %>% 
        drop_na() %>% 
        group_by(Code) %>% 
        mutate(avg = mean(val)) %>% 
        arrange(desc(val)) %>% 
        ungroup() %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val,
                     group = Period)) %>%
        hc_title(text = paste0("Participating products: ", input$meas_prod_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_prod()$Unit))) %>%
        hc_colors(abscol)    
      
    }
    
    if(type_prod()$type == 1) {
      
      hc1b <- df_prod() %>% 
        select(-Period) %>% 
        distinct() %>% 
        drop_na() %>% 
        arrange(desc(val)) %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val,
                     group = measure)) %>%
        hc_title(text = paste0("Participating products: ", input$meas_prod_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_prod()$Unit))) %>%
        hc_colors(abscol)  
      
    }            
    hc1b
  })
  
  #  Consumption  - uses df_consm() as that's arranged according to order used prods 
  output$hcontainer2 <- renderHighchart({  
    
    if(type_cons()$type == 2) {
      
      hc2 <- df_consm() %>% 
        drop_na() %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val,
                     group = Period)) %>%
        hc_title(text = paste0("2020-21 ", input$nutrient_select, " consumption: ", input$meas_cons_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_cons()$Unit))) %>%
        hc_colors(abscol)  
      
    }
    
    if(type_cons()$type == 1) {
      
      hc2 <- df_consm() %>% 
        select(-Period) %>% 
        distinct() %>% 
        drop_na() %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val, 
                     group = measure)) %>%
        hc_title(text = paste0("2020-21 ", input$nutrient_select, " consumption: ", input$meas_cons_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_cons()$Unit))) %>%
        hc_colors(abscol)  
      
    }        
    
    
    hc2
    
  })
  
  output$hcontainer2b <- renderHighchart({  
    
    if(type_cons()$type == 2) {
      
      hc2b <- df_cons() %>% 
        drop_na() %>% 
        arrange(desc(val)) %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val,
                     group = Period)) %>%
        hc_title(text = paste0("2020-21 ", input$nutrient_select, " consumption: ", input$meas_cons_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_cons()$Unit))) %>%
        hc_colors(abscol)  
      
    }
    
    if(type_cons()$type == 1) {
      
      hc2b <- df_cons() %>% 
        select(-Period) %>% 
        distinct() %>% 
        drop_na() %>% 
        arrange(desc(val)) %>% 
        hchart(.,
               type = "column",
               hcaes(x = Food_category,
                     y = val, 
                     group = measure)) %>%
        hc_title(text = paste0("2020-21 ", input$nutrient_select, " consumption: ", input$meas_cons_select)) %>% 
        hc_xAxis(title = list(text = paste0("Food category"))) %>%
        hc_yAxis(title = list(text = paste0(U_cons()$Unit))) %>%
        hc_colors(abscol)  
      
    }        
    
    
    hc2b
    
  })
  
  # Table for DT display
  output$table = DT::renderDataTable({
    tab <- table()
    
    tab
  })
  
  
  # Downloadable xlsx --
  output$downloadTb <- downloadHandler(
    filename = function() { paste("PRP Wave 1 data selection", ".xlsx") },
    content = function(file) { write_xlsx(table(), path = file) }
  )
  
}

shinyApp(ui, server)


