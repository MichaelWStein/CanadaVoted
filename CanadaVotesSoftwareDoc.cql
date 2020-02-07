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