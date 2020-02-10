//The blocks work, but cannot all be run at once

CREATE (p:Program:CanVotes {
    name: 'DataCol2016', 
    language: 'Python',
    description: 'Extracts 2016 census data for each electoral district and creates a file for further analysis''
    function: 'Data extraction'})
RETURN p.name

//Using Merge instead of create to avoid double-creation of nodes. this has qa computational cost (not important her)
MERGE (p:Program:CanVotes {
    name: 'DataExtractionOneDistrict', 
    language: 'Python, notebook',
    description: 'Extracts 2016 census data for one electoral district - background information for data handling',
    function: 'Data extraction, example'})
RETURN p.name

MERGE (p:DataExt:CanVotes {
    name: 'ElectoralDistrictList', 
    file: 'External file provided by Statscan',
    description: 'List of Electoral Districts based on 2016 census data',
    function: 'List of electoral districts is required for further data retrieval'})
RETURN p.name

MERGE (p:DataExt:CanVotes {
    name: 'CensusData2016', 
    file: 'External file provided by Statscan',
    description: '2016 census data for electoral districts.',
    comment: 'Data is per district, one API call per district is required for retrieval',
    function: 'Provides census data for electoral districts for further analysis'})
RETURN p.name;

MATCH (p:Program), (m:DataExt)
WHERE p.name = 'DataCol2016' AND m.name = 'CensusData2016'
MERGE (p)-[:retrieved]->(m)
RETURN p, m

MATCH (p:Program), (m:DataExt)
WHERE p.name = 'DataCol2016' AND m.name = 'ElectoralDistrictList'
MERGE (p)-[:retrieved]->(m)
RETURN p, m

MATCH (p:Program), (m:DataExt)
WHERE p.name = 'DataExtractionOneDistrict' AND m.name = 'CensusData2016'
MERGE (p)-[:retrieved {comment:'Only for one Elect. District.'}]->(m)
RETURN p, m

MERGE (d:DataInt:CanVotes {
    name: 'StatsCan_2016_ElectDist',
    type: 'csv-file',
    comment: 'For review and Analysis',
    n_exact: 'StatsCan_2016_ElecDist.csv'
})
RETURN d

MATCH (p:Program), (m:DataInt)
WHERE p.name = 'DataCol2016' AND m.name = 'StatsCan_2016_ElectDist'
MERGE (p)-[:write]->(m)

MERGE (d:DataInt:CanVotes {
    name: 'Census2016Dist',
    type: 'pkl-file',
    comment: 'Transfer file for further processing in Python',
    n_exact: 'Census2016ElectoralDistrictsInfo.pkl' 
})

MATCH (p:Program), (m:DataInt)
WHERE p.name = 'DataCol2016' AND m.name = 'Census2016Dist'
MERGE (p)-[:write]->(m)
RETURN p, m;

MERGE (p:Program:CanVotes {
    name: '2019ElecResults', 
    language: 'Python, notebook',
    description: 'Loads 2019 voting results and creates file for further processing.',
    function: 'Data extraction and transformation.'})
RETURN p.name

MERGE (d:DataInt:CanVotes {
    name: '2019_Election_Results',
    type: 'csv-file',
    comment: 'This is the file downloaded from Elections Canada. It contains preliminary and validated results.',
    n_exact: '2019_Election_Results.csv'
})
RETURN d

MATCH (p:Program), (m:DataInt)
WHERE p.name = '2019ElecResults' AND m.name = '2019_Election_Results'
MERGE (p)-[:loads]->(m)
RETURN p, m

MERGE (d:DataInt:CanVotes {
    name: '2019_Election_Results',
    type: 'csv-file',
    comment: 'This is the file downloaded from Elections Canada. It contains preliminary and validated results.',
    n_exact: '2019_Election_Results.csv'
})
RETURN d

MERGE (d:DataInt:CanVotes {
    name: '2019_Complete',
    type: 'csv-file',
    comment: 'Complete 2019 Election Results, saved for further processing.',
    n_exact: '2019_Results_Complete.csv'
})
RETURN d

MERGE (d:DataInt:CanVotes {
    name: '2019_Simp',
    type: 'csv-file',
    comment: '2019 Election Results - winning party and % only.',
    n_exact: '2019_Results.csv'
})
RETURN d

MATCH (p:Program), (m:DataInt)
WHERE p.name = '2019ElecResults' AND m.name = '2019_Complete'
MERGE (p)-[:write]->(m)
RETURN p, m

MATCH (p:Program), (m:DataInt)
WHERE p.name = '2019ElecResults' AND m.name = '2019_Simp'
MERGE (p)-[:write]->(m)
RETURN p, m

MERGE (p:Program:CanVotes {
    name: 'Data_Conversion', 
    language: 'Python, notebook',
    description: 'Changes the Electoral District Data into a json file for use in JavaScript.',
    function: 'Data extraction and transformation.'})
RETURN p.name

MATCH (p:Program), (m:DataInt)
WHERE p.name = 'Data_Conversion' AND m.name = 'StatsCan_2016_ElectDist'
MERGE (p)-[:loads]->(m)
RETURN p, m

MERGE (d:DataInt:CanVotes {
    name: 'Conv_Dist_Data',
    type: 'geojson',
    comment: 'Contains the Electoral District Data as a geojson. this data can be used by javascript 
    to be displayed on a website.',
    n_exact: 'data_upd.geojson'
})
RETURN d

MATCH (p:Program), (m:DataInt)
WHERE p.name = 'Data_Conversion' AND m.name = 'Conv_Dist_Data'
MERGE (p)-[:write]->(m)
RETURN p, m

//This program name needs to be changed. Also add exact name for program
MERGE (p:Frontend:CanVotes {
    name: 'Electoral_Info-Display', 
    language: 'Javascript',
    description: 'Creates map overlay with the district lines and the detail information for each 
    electoral district.',
    function: 'Data extraction and transformation.'})
RETURN p.name

MERGE (d:DataInt:CanVotes {
    name: 'Conv_Dist_Data',
    type: 'geojson',
    comment: 'Contains the Electoral District Data and boundaries as a geojson. 
    This data is used by a javascript program to generate the website display.',
    n_exact: 'data_upd.geojson'
})
RETURN d

MATCH (p:Frontend), (m:DataInt)
WHERE p.name = 'Electoral_Info-Display' AND m.name = 'Conv_Dist_Data'
MERGE (p)-[:loads]->(m)
RETURN p, m

//I want to change a name because I used the wrong nomenclature
MATCH (m:CanVotes)
WHERE m.name = 'Electoral_Info-Display'
SET m.name = 'Electoral_Info_Display'
RETURN m


//I want to add a label to a node - script for the javascript (or similar) parts of the frontend
MATCH (m:CanVotes)
WHERE m.name = 'Electoral_Info_Display'
SET m:Script
RETURN labels(m)

//Forgot to set the exact name
MATCH (m:CanVotes)
WHERE m.name = 'Electoral_Info_Display'
SET m.n_exact='ElectoralInformation.js'
RETURN  m.n_exact

MERGE (p:Frontend:CanVotes:html {
    name: 'Electoral_Districts', 
    language: 'html',
    description: 'Display of all electoral districts with key information on website. In Website repository.', 
    function: 'Display of Information',
    n_exact: 'Electmap.html'})
RETURN p.name;

//Referencing the key external scripts used by the website.
//These scripts have to be run one by one. If all should be run at once:
//RETURN only at the end and use of different variable names (i.e. not all 'p') 

MERGE (p:Frontend:Script_Ext {
    name: 'Bootstrap', 
    language: 'Javascript',
    description: 'Scripts related to Bootstrap.', 
    function: 'Formatting of Website'})
RETURN p.name;

MERGE (p:Frontend:Script_Ext {
    name: 'D3', 
    language: 'Javascript',
    description: 'Scripts related to D3.', 
    function: 'Display of data on website.'})
RETURN p.name;

MERGE (p:Frontend:Script_Ext {
    name: 'Mapbox', 
    language: 'Javascript',
    description: 'Display of Maps. Key needed in config-file.', 
    function: 'Map display'})
RETURN p.name;

MERGE (p:Frontend:Script_Ext {
    name: 'Leaflet', 
    language: 'Javascript',
    description: 'Display of information on maps. Needs mapbox to work.', 
    function: 'Display of information on maps.'})
RETURN p.name;

//Creating multiple relationshi based on a list of indices:
MATCH (m:html), (p:Script_Ext)
    WHERE id(m) = 31 AND id(p) IN [72, 71, 51, 73]
CREATE (m) - [:runs] -> (p)

MATCH (m:html), (p:Frontend)
    WHERE id(m) = 31 AND id(p) IN [30]
CREATE (m) - [:runs] -> (p)

//Creating the nodes for the standard scripts
MERGE (p:Frontend:Script_Int {
    name: 'Config', 
    language: 'Javascript',
    description: 'Configuration File with passwords.', 
    function: 'To provide passwords for the websites. Hidden'})
RETURN p.name; 

MERGE (p:Frontend:Script_Int {
    name: 'Style', 
    language: 'CSS',
    description: 'My stylesheet', 
    function: 'To provide basic settings for the websites.'})
RETURN p.name; 

MERGE (p:Frontend:Script_Int {
    name: 'Reset', 
    language: 'CSS',
    description: 'Sheet for reset.', 
    function: 'To reset HTML before running the website.'})
RETURN p.name; 

MATCH (m:html), (p:Script_Int)
    WHERE id(m) = 31 AND id(p) IN [75, 74, 32]
CREATE (m) - [:runs] -> (p)