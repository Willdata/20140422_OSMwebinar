library(rCharts)
library(plyr)

cList <- read.csv("cList.csv")

grouplist <- levels(cList$groupName)

#from data.frame to list
getList <- function (df) {
  #for color
  groupPool <<- levels(droplevels(df$groupName))
  groupNum <<- length(groupPool)
  colorPal <<- hue_pal()(groupNum)
  L2 <- dlply(df, .(X),.drop=TRUE,
              summarize,
              Name = clinicName,
              Addr = clinicAddr,
              group = groupName,
              groupRef = groupRef,
              longitude=lon, latitude=lat,
              fillColor = colorPal[match(groupName, groupPool)],
              popup = sprintf("%s <br/> %s", clinicName, groupName)
  )
  
  for(i in 1:length(L2)) {
    L2[[i]] <- as.list(L2[[i]])
  }
  
  return(L2)
}

#get center
getCenter <- function(data) {
  center <- c(mean(data$lat), mean(data$lon))
  return(center)
}

plotMap <- function(data) {
  center <- getCenter(data)
  list <- getList(data)
  L3 <- Leaflet$new()
  L3$set(width=800, height=500)
  L3$setView(center,11)
  L3$tileLayer(provider = 'MapQuestOpen.OSM')
  L3$geoJson(toGeoJSON(list),
             onEachFeature = '#! function(feature, layer){
             layer.bindPopup(feature.properties.popup)
             } !#',
             pointToLayer = "#! function(feature, latlng){
             return L.circleMarker(latlng, {
             radius: 8,
             fillColor: feature.properties.fillColor || 'red',
             color: '#000',
             weight: 0.5,
             fillOpacity: 0.7
             })
             } !#")
  L3$legend(position="bottomright", colors = colorPal, labels=groupPool)
  L3$fullScreen(TRUE)
  return(L3)
  }

glist <- getList(cList)

plotMap(cList)