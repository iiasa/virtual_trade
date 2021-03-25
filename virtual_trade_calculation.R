#'========================================================================================================================================
#' Project:  Moore China
#' Subject:  Script to calculate vurtual trade flows
#' Author:   Hao ZHAO
#' Contact:  haozhao0805@gmail.com
#'========================================================================================================================================


### PACKAGES
if(!require(pacman)) install.packages("pacman")
# Key packages
p_load("tidyverse", "readxl", "stringr", "car", "scales", "RColorBrewer", "rprojroot", "ggthemes", "haven")
# Spatial packages
p_load("rgdal", "ggmap", "raster", "rasterVis", "rgeos", "sp", "mapproj", "maptools", "proj4", "gdalUtils", "maps")
# Additional packages
p_load("quickPlot", "classInt", "countrycode", "viridis", "gdxrrw", "ncdf4")


## read GLOBIOM outputs and set 
setwd("F:/GLOBIOM/paper1")
getwd()

#save.image(file = "virtual_trade.RData")

load("virtual_trade.RData")


### Trade Regions 
region_map <- read.csv("paper1_R/region_map.csv")
### livestock protein content
live_protein <- read.csv("paper1_R/live_protein.csv")

# disaggregate milk and meat from BOVD,SGTD, egg and meat from PTRX
bovd_dis <- live_yield %>%
  filter(animal %in% c("BOVD","SGTD","PTRX")) %>%
  left_join(a6_live_num) %>%
  mutate(prod=LIVE_COMPARE*LIVEDATA_COMPARE)%>%
  left_join(region_map) %>%
  group_by(region,animal,item,scenario,year) %>%
  summarise(prod=sum(prod,na.rm = T)) %>%
  ungroup() %>%
  left_join(live_protein) %>%
  mutate(prod=prod*value) %>% #calculate protein production for different animal
  dplyr::select(-value)%>%
  spread(item,prod)%>%
  mutate(bvmilk_share= BVMILK/(BVMILK+BVMEAT),bvmeat_share= BVMEAT/(BVMILK+BVMEAT),
         chicken_share = PTMEAT/(PTMEAT+PTEGGS), egg_share = PTEGGS/(PTMEAT+PTEGGS),
         sgmilk_share = SGMILK/(SGMILK+SGMEAT), sgmeat_share = SGMEAT/(SGMILK+SGMEAT))%>% # calculate share of each products
  dplyr::select(-unit,-BVMEAT,-BVMILK,-PTMEAT,-PTEGGS,-SGMILK,-SGMEAT) %>%
  rename(BVMILK=bvmilk_share,BVMEAT=bvmeat_share,PTMEAT=chicken_share,PTEGGS=egg_share,SGMILK=sgmilk_share,SGMEAT=sgmeat_share) %>%
  gather(crop,share,-region,-animal,-scenario,-year) %>%
  filter(!is.na(share)) %>% dplyr::rename(from =region)

bovd_dis$from <- as.factor(bovd_dis$from)


### total production emission
# Followers to dariy: BOVF to BOVD
animal_var <- c("BOVF","SGTF")
product_var <- c("BOVD","SGTD")
for (k in 1:length(animal_var)) {
  index <- which(livestock_emission[,2] == animal_var[k])
  livestock_emission[index,2] <- product_var[k]  
}

live_tot_emis1 <- livestock_emission%>%
  group_by(from, animal, scenario, year) %>%
  summarise(emission_li=sum(emission_li))%>%
  left_join(bovd_dis)%>%
  mutate(share = coalesce(share, 1),emission=emission_li*share) %>%
  dplyr::select(-emission_li,-share)

# fill in all products
animal_var <- c("PIGS","SGTO","PTRB","BOVO","PTRH")
product_var <- c("PGMEAT","SGMEAT","PTMEAT","BVMEAT","PTEGGS")
# fill in "crops"
for (k in 1:length(animal_var)) {
  index <- which(live_tot_emis1[,2] == animal_var[k])
  live_tot_emis1[index,5] <- product_var[k]  
}

# sum bovine milk and sheep milk 
live_tot_emis <- live_tot_emis1 %>%
  group_by(from, year, scenario,crop) %>%
  summarise(emission=sum(emission)) %>%
  ungroup() %>%
  spread(crop,emission)%>%
  mutate(SGMILK = coalesce(SGMILK, 0), ALMILK = SGMILK+BVMILK) %>%
  gather(crop,emission,-from,-scenario,-year) %>%
  filter(!crop %in% c("SGMILK","BVMILK","<NA>"))

live_tot_emis$year <- factor(live_tot_emis$year)
live_tot_emis$crop <- factor(live_tot_emis$crop)
rm(live_tot_emis1)


####******************************virtual crop land (yield)**************************####
# virtual crop area 1000ha
virtual_crp_land <- trade_data_row %>%
  left_join(yield) %>%
  mutate(trade_area = value/OUTPUT)%>%
  filter(to=="ChinaReg")%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_area = sum(trade_area, na.rm = T)) %>%
  filter(trade_area != 0) %>% dplyr::rename(value = trade_area) %>%
  mutate(item="trade_area")

####***************************** virtual crop N and water *************************####
# virtual N, here the N use need to be rescaled 
virtual_N <- trade_data_row %>%
  left_join(fertilizer_N) %>%
  mutate(trade_N=value*OUTPUT/prod/1000)%>%
  filter(to=="ChinaReg")%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_N = sum(trade_N, na.rm = T)) %>%
  filter(trade_N != 0) %>% dplyr::rename(value = trade_N) %>%
  mutate(item="trade_N") %>%
  left_join(a6_ghg_rescale) %>%
  mutate(value = value/GHG_Rescale) %>%
  dplyr::select(-GHGAccount, -GHG_Rescale)

# virtual water
virtual_water <- trade_data_row %>%
  left_join(water) %>%
  mutate(trade_water = value*OUTPUT/prod) %>%
  filter(to=="ChinaReg")%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_water = sum(trade_water, na.rm = T)*10) %>%
  filter(trade_water != 0) %>% dplyr::rename(value = trade_water) %>%
  mutate(item="trade_water")

####***************************** virtual emission *************************####
# crop emission
virtual_emis_crop <- trade_data_row %>%
  left_join(production) %>%
  left_join(crop_emission) %>%
  mutate(trade_cropemis = value*emission_cr/prod)%>%
  filter(to=="ChinaReg")%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_cropemis = sum(trade_cropemis, na.rm = T))%>%
  filter(trade_cropemis != 0) %>% dplyr::rename(value = trade_cropemis) %>%
  mutate(item="trade_cropemis")

#livestock
# livestock production 1000 tonnes or read from output.gdx
live_data <- live_yield %>%
  left_join(a6_live_num) %>%
  mutate(prod=LIVE_COMPARE*LIVEDATA_COMPARE) %>%
  left_join(region_map) %>%
  group_by(region,item,scenario,year) %>%
  summarise(prod=sum(prod,na.rm = T))%>%
  ungroup()%>%
  dplyr::rename(from = region, crop=item) %>%
  spread(crop,prod) %>% 
  mutate(SGMILK = coalesce(SGMILK, 0), ALMILK = BVMILK+SGMILK) %>% # remove NA combine milks
  dplyr::select(-BVMILK,-SGMILK) %>% gather(crop,prod,-from,-year,-scenario)

virtual_emis_live <- trade_data_row %>%
  left_join(live_data) %>% #livestock production
  filter(crop %in% c("BVMEAT","PTMEAT","SGMEAT","ALMILK","PTEGGS","PGMEAT"))%>%
  left_join(live_tot_emis) %>%
  mutate(real_emis = value*emission/prod) %>%
  filter(to=="ChinaReg")%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_liveemis = sum(real_emis, na.rm = T))%>%
  filter(trade_liveemis != 0) %>% dplyr::rename(value = trade_liveemis) %>%
  mutate(item="trade_liveemis")



####*************************indirect trade impact***************************####
##**** virtual pasture area *****##
grass_rqr <- grass_rqr1 %>%
  group_by(region,animal,scenario,year) %>%
  summarise(grass= sum(grass, na.rm = T)) %>%
  ungroup() %>%
  dplyr::rename(from=region)%>%
  left_join(bovd_dis) 

# fill in all products
animal_var <- c("SGTO","BOVO")
product_var <- c("SGMEAT","BVMEAT")
# fill in "crops"
for (k in 1:length(animal_var)) {
  index <- which(grass_rqr[,2] == animal_var[k])
  grass_rqr[index,6] <- product_var[k] 
  grass_rqr[index,7] <- 1
}

grass_rqr1 <-grass_rqr %>%
  filter(!is.na(crop))%>%
  mutate(gras_need = grass*share) %>%
  group_by(from,scenario,year,crop) %>%
  summarise(gras_need=sum(gras_need,na.rm = T)) %>%
  ungroup() %>%
  spread(crop,gras_need) %>%
  mutate(SGMILK = coalesce(SGMILK,0),ALMILK =SGMILK+BVMILK )%>%
  gather(crop,gras_need,-from,-scenario,-year) %>%
  filter(!crop %in% c("SGMILK","BVMILK")) %>%
  left_join(gras_yild)%>%
  mutate(grass_area=gras_need/gras_yild) %>%
  left_join(grassland)

reserve_tot <- grass_rqr1 %>%
  filter(year == "2000")%>%
  group_by(from,scenario,year,gras_yild,grassland)%>%
  summarise(grass_area=sum(grass_area,na.rm = T),tot_gras_need= sum(gras_need,na.rm=T))%>%
  ungroup()%>%
  mutate(reserve_tot_area = grass_area- grassland, reserve_tot_prod = gras_yild*reserve_tot_area)%>%
  dplyr::select(-grass_area,-grassland)%>%
  dplyr::rename(reserve_yild=gras_yild)

reserve <- grass_rqr1 %>%
  filter(year == "2000")%>%
  left_join(reserve_tot)%>%
  mutate(reserve_prod=gras_need/tot_gras_need*reserve_tot_prod,reserve_area= reserve_prod/reserve_yild)%>%
  dplyr::select(-grass_area,-grassland,-reserve_yild,-reserve_tot_prod,-reserve_tot_area,-gras_yild,-variable,
                -year,-gras_need,-scenario,-tot_gras_need)

real_gras <- grass_rqr1 %>%
  left_join(reserve)%>%
  mutate(real_gras_need = gras_need - reserve_prod, real_grass_area = real_gras_need/gras_yild+reserve_area)%>%
  dplyr::select(-real_gras_need,-reserve_area,-reserve_prod,-gras_need,-grassland,-grass_area,-gras_yild,-variable)
real_gras <- distinct(real_gras)

virtual_pasture <-  trade_data_row %>%
  left_join(live_data) %>%
  filter(crop %in% c("BVMEAT","PTMEAT","SGMEAT","ALMILK","PTEGGS","PGMEAT"))%>%
  left_join(real_gras) %>%
  mutate(real_grass_area = value*real_grass_area/prod) %>%
  filter(to=="ChinaReg")%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_pasture = sum(real_grass_area, na.rm = T))%>%
  filter(trade_pasture != 0) %>% dplyr::rename(value = trade_pasture) %>%
  mutate(item="trade_pasture")


##**** virtual feed crops *****##

# Followers to dariy: BOVF to BOVD
animal_var <- c("BOVF","SGTF")
product_var <- c("BOVD","SGTD")
for (k in 1:length(animal_var)) {
  index <- which(feed_crops1[,3] == animal_var[k])
  feed_crops1[index,3] <- product_var[k]  
}
feed_crops <- feed_crops1%>%
  group_by(region,animal,crop,scenario,year)%>%
  summarise(feed=sum(feed,na.rm = T))%>%
  ungroup()%>%
  dplyr::rename(from=region,feed_crop=crop) %>%
  left_join(bovd_dis)
rm(feed_crops1)

# fill in meat products
animal_var <- c("PIGS","SGTO","PTRB","BOVO")
product_var <- c("PGMEAT","SGMEAT","PTMEAT","BVMEAT")
for (k in 1:length(animal_var)) {
  index <- which(feed_crops[,2] == animal_var[k])
  feed_crops[index,7] <- product_var[k] 
  feed_crops[index,8] <- 1
}

live_trade_share <- trade_data_row %>%
  left_join(live_data) %>%
  filter(crop %in% c("BVMEAT","PTMEAT","SGMEAT","ALMILK","PTEGGS","PGMEAT"))%>%
  mutate(trade_share=value/prod)

# livestock related feed trade
feed_rqr <- feed_crops %>%
  drop_na() %>%
  mutate(feed=feed*-1*share)%>%
  group_by(from,scenario,year,crop,feed_crop)%>%
  summarise(feed=sum(feed,na.rm = T))%>%
  ungroup()%>%
  left_join(live_trade_share) %>%
  filter(to=="ChinaReg") %>%
  mutate(trade_feed = trade_share*feed)%>%
  group_by(from,to,scenario,year,feed_crop)%>%
  summarise(trade_feed=sum(trade_feed,na.rm = T))%>%
  ungroup()%>%
  dplyr::rename(crop=feed_crop)

# trase the feed crops from domestic or the rest of world,in this study we only considered domestic impacts
feed_impo <- feed_rqr %>%
  left_join(domestic_share) %>%
  mutate(trade_feed=trade_feed*dom_share)%>%
  dplyr::select(-dom_share) 

## calculations of indirect N land water 
virtual_ind_N <- feed_impo%>%
  left_join(fertilizer_N)%>%
  drop_na() %>%
  mutate(trade_ind_N=trade_feed*OUTPUT/prod/1000)%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_ind_N = sum(trade_ind_N, na.rm = T)) %>%
  ungroup()%>%
  filter(trade_ind_N != 0) %>% dplyr::rename(value = trade_ind_N) %>%
  mutate(item="trade_ind_N") %>%
  left_join(a6_ghg_rescale) %>%
  mutate(value = value/GHG_Rescale) %>%
  dplyr::select(-GHGAccount, -GHG_Rescale)


virtual_ind_water <- feed_impo %>%
  left_join(water) %>%
  mutate(trade_ind_water = trade_feed*OUTPUT/prod) %>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_ind_water = sum(trade_ind_water, na.rm = T)*10) %>%
  ungroup()%>%
  filter(trade_ind_water != 0) %>% dplyr::rename(value = trade_ind_water) %>%
  mutate(item="trade_ind_water")

# 1000ha
virtual_ind_land <- feed_impo %>%
  left_join(yield) %>%
  mutate(trade_ind_area = trade_feed/OUTPUT)%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_ind_area = sum(trade_ind_area, na.rm = T)) %>%
  ungroup()%>%
  filter(trade_ind_area != 0) %>% dplyr::rename(value = trade_ind_area) %>%
  mutate(item="trade_ind_area")


virtual_ind_emis_crop <- feed_impo %>%
  left_join(production) %>%
  left_join(crop_emission) %>%
  mutate(trade_ind_cropemis = trade_feed*emission_cr/prod)%>%
  group_by(crop,from,to,scenario,year)%>%
  summarise(trade_ind_cropemis = sum(trade_ind_cropemis, na.rm = T))%>%
  ungroup()%>%
  filter(trade_ind_cropemis != 0) %>% dplyr::rename(value = trade_ind_cropemis) %>%
  mutate(item="trade_ind_cropemis")

# sum of indirect trade flows
virtual_ind_all <- bind_rows(virtual_ind_land,virtual_ind_emis_crop,virtual_ind_N,virtual_ind_water) %>%
  group_by(from, to, scenario, year, item) %>%
  summarise(value = sum(value, na.rm = T)) %>%
  ungroup() %>%
  mutate(crop="livestock_embodied")

## sum of virtual direct and in-direct trade ##
virtual_all <- bind_rows(virtual_crp_land,virtual_pasture,virtual_emis_crop,virtual_emis_live,
                         virtual_N,virtual_water,virtual_ind_all)
