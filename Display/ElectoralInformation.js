// Electoral Information



//Function to build the map with electoral districts
function build_map_comp() {

    var overlayMaps = {};
    d3.json("/assets/data/data_upd.geojson")
        .then(function(data) {
            createFeatures(data.features)
        })   
        .catch(function(error){
            console.log(error)
        });
};
        
function createFeatures(district_data){
 
    var districts = L.geoJSON(district_data, {
        onEachFeature: function(feature, layer) {
            layer.bindTooltip(feature.properties.NAME)
            layer.bindPopup("<h3>" + feature.properties.NAME + 
            "</h3><hr><p>" + "Population: " + feature.properties.Population_2016 + "</p>" +
            "<p>" + "Population density: " + feature.properties.Population_density + "</p>" +
            "<p>" + "Average age: " + feature.properties.Average_age + "</p>" +
            "<p>" + "Avg. Household Size: " + feature.properties.Average_household_size + "</p>" +
            "<p>" + "Avg. total income: " + feature.properties.Average_total_income + "</p>" +
            "<p>" + "Poverty rate: " + feature.properties.poverty_rate + "</p>" +
            "<p>" + "Mother tongue English: " + feature.properties.English + "</p>" +
            "<p>" + "Mother tongue French: " + feature.properties.French + "</p>" +
            "<p>" + "Mother tongue non-official language: " + feature.properties.Non_official_languages + "</p>" +
            "<p>" + "Canadian born: " + feature.properties.Non_immigrants + "</p>" +
            "<p>" + "Immigrants: " + feature.properties.Immigrants + "</p>")
        }
    });
      
    overlayMaps = {
        "Electoral_Districts": districts
    };

    lightMap=L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
        attribution: "Map data &copy; <a href=\"https://www.openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>,\
        Imagery © <a href=\"https://www.mapbox.com/\">Mapbox</a>",
        maxZoom: 18,
        id: "mapbox.light",
        accessToken: API_KEY
        });
    
        // Building the basic map
    map = L.map("map", {
        center: [47.530367, -80.346771],
        zoom: 6,
        layers: [lightMap, districts]
        });

    L.easyButton('<span class="info">Information about the Data</span>', function(){alert('Data for Electoral Districts from Statscan. Still working on formatting and details.')}).addTo(map); 
                 
};

build_map_comp();
