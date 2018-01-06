############################################
# Creator: Colin Averill <caverill@bu.edu> #
############################################


#function to assign species based on funguild
#takes a taxonomy table with kingdom/phylum/class/order/family/genus/species as separate columns with those names in lower case.
#returns a vector of FunGuild functional assignments.
#depends on R packages rvest, jsonlite.

##Testing the function - generate some artifical data to assign guild to.
#tax_table <- structure(list(taxonomy = "k__Fungi; p__Ascomycota; c__Pezizomycetes; o__Pezizales; f__Tuberaceae; g__Tuber; s__Tuber melosporum", 
#kingdom = "Fungi", phylum = "Ascomycota", class = "Pezizomycetes", 
#order = "Pezizales", family = "Tuberaceae", genus = "Tuber", 
#species = "Tuber melosporum"), .Names = c("taxonomy", "kingdom", 
#                                          "phylum", "class", "order", "family", "genus", "species"), row.names = 4L, class = "data.frame")
##Test the function.
#test <- fg_assign(tax_table)

library(rvest)
library(jsonlite)
library(dplyr)


fg_assign <- function(tax_table){
  #path to FUNGuild database
  url <- "http://www.stbates.org/funguild_db.php"
  
  #download database, convert it to something R interpretable.
  fg <- url %>% 
    xml2::read_html() %>%
    rvest::html_text() 
  fg <- jsonlite::fromJSON(gsub("funguild_db", "", fg))
  
  #There are 9 unique levels of taxonomic resolution actually in FUNGuild (though 24 potential levels)
  #0-keyword, 3-Phylum, 7-Order, 9-Family, 13-genus, 20species, 21-subspecies, 24-Form
  #I only have data on k/c/p/o/f/g/s, so only going to deal with levels 3,7,9,13,20
  #What follows is a series of if statements to assign function
  #start with highest level of taxonomy and go down.
  
  #there is almost certainly a better and faster way to do this. But this works and is fast enough.
  tax_table$guild <- NA
  #phylum level match.
  tax_table$guild <- ifelse(tax_table$phylum %in% fg$taxon,
                            fg[match(tax_table$phylum, fg$taxon),5],
                            tax_table$guild)
  #class level match.
  tax_table$guild <- ifelse(tax_table$class %in% fg$taxon,
                            fg[match(tax_table$class, fg$taxon),5],
                            tax_table$guild)
  #order level match.
  tax_table$guild <- ifelse(tax_table$order %in% fg$taxon,
                            fg[match(tax_table$order, fg$taxon),5],
                            tax_table$guild)
  #family level match.
  tax_table$guild <- ifelse(tax_table$family %in% fg$taxon,
                            fg[match(tax_table$family, fg$taxon),5],
                            tax_table$guild)
  #genus level match.
  tax_table$guild <- ifelse(tax_table$genus %in% fg$taxon,
                            fg[match(tax_table$genus, fg$taxon),5],
                            tax_table$guild)
  #species level match.
  tax_table$guild <- ifelse(tax_table$species %in% fg$taxon,
                            fg[match(tax_table$species, fg$taxon),5],
                            tax_table$guild)
  
  #report and return output.
  cat(sum(!is.na(tax_table$guild))/(nrow(tax_table))*100,'% of fungal taxa assigned a functional guild.', sep = '')
  return(tax_table$guild)
}







