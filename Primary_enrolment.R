# Load Required librabries using pacman ( I use pacman since it installs any packages that are missing and loads them at the same time)
pacman::p_load(tidyverse, rio, RSQL, RSQLite, DBI , shiny, reshape2)


 # Load data into r Environment (I use rio to import the data set in R environment)
# The alternative would be to use read,csv but rio automatically impiorts the file without specifying the file extension
PriData <- import("C:/Users/vmwangi/OneDrive - CGIAR/Documents/R/Primary_School_data/Data/primary_enrollment_sctypesex.csv")


# View the first six lines of the data

head(PriData)


# View the data as a spreedsheet

View(PriData)


# View the data structure

str(PriData)

# Get the names of the varibles in the data frame

names(PriData)



# Use the melt (from reshape/reshape2) funtion to orinet the data from a wide into a long formart 
New.PriData <-  melt(PriData, id.vars = "subcounty", 
                     measure.vars = c("public_Boys_2017",   "public_Girls_2017",  
                                      "private_Boys_2017","private_Girls_2017", 
                                      "public_Boys_2018", "public_Girls_2018", 
                                      "private_Boys_2018",  "private_Girls_2018", 
                                      "public_Boys_2019", "public_Girls_2019",  
                                      "private_Boys_2019", "private_Girls_2019"),
     variable.name = "Category", value.name = "Count")

# New.PriData <- melt(PriData, id = "subcounty")  # this line is a simplified way of doing the same as above

head(New.PriData)


#Using mutate to create new variables,Sex and Year, using ifelse function and str_extract from Stringr
New.PriData2 <- New.PriData %>%
  mutate(Sex = ifelse(str_detect(Category, "Boys"), "Boys", "Girls")) %>%
  mutate(Year = str_extract(Category,"(1|2)\\d{3}") ) # "(1|2)\\d{3}" = regular expression for extracting year from a string


head(New.PriData2)

# "(1|2)\\d{3}" = regular expression for extracting year from a string

#grouping the data using dplyr
Primary_school_enrolment <-  New.PriData2 %>%
  group_by(Year, Sex) %>%
  summarise(tot_enrolment = sum(Count))


head(Primary_school_enrolment)

# Create an SQLite database
con <- dbConnect(drv = RSQLite::SQLite(),
                 dbname = ":memory:")



# load the "Primary_school_enrollment" object into the database
dbWriteTable(con, "Primary_school_enrolment", Primary_school_enrolment)


# View/List the tables in the database
dbListTables(con)
