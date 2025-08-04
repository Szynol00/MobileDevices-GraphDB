// Mobile Devices Graph Database Import Script
// Creates a comprehensive graph database of mobile devices with specifications

// Clear existing data
MATCH (n) DETACH DELETE n;

// Create constraints and indexes for performance
CREATE CONSTRAINT company_name IF NOT EXISTS FOR (c:Company) REQUIRE c.name IS UNIQUE;
CREATE CONSTRAINT device_model IF NOT EXISTS FOR (d:Device) REQUIRE d.model IS UNIQUE;
CREATE CONSTRAINT processor_model IF NOT EXISTS FOR (p:Processor) REQUIRE p.model IS UNIQUE;

CREATE INDEX device_type_idx IF NOT EXISTS FOR (d:Device) ON (d.device_type);
CREATE INDEX device_release_idx IF NOT EXISTS FOR (d:Device) ON (d.release_date);
CREATE INDEX ram_capacity_idx IF NOT EXISTS FOR (r:RAM) ON (r.capacity_gb);
CREATE INDEX storage_capacity_idx IF NOT EXISTS FOR (s:Storage) ON (s.capacity_gb);
CREATE INDEX battery_capacity_idx IF NOT EXISTS FOR (b:Battery) ON (b.capacity_mah);
CREATE INDEX camera_type_idx IF NOT EXISTS FOR (c:Camera) ON (c.type);
CREATE INDEX camera_mp_idx IF NOT EXISTS FOR (c:Camera) ON (c.megapixels);
CREATE INDEX screen_diagonal_idx IF NOT EXISTS FOR (s:Screen) ON (s.diagonal_inch);

// Import companies and devices
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MERGE (c:Company {name: row.Company}) 
MERGE (d:Device {model: row.Model}) 
ON CREATE SET 
  d.release_date = row.Release_Date, 
  d.device_type = row.Device_Type 
MERGE (d)-[:PRODUCED_BY]->(c);

// Process RAM specifications - separate nodes for each capacity
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.RAM IS NOT NULL AND trim(row.RAM) <> "" 
WITH row, d, [x IN split(row.RAM, ', ') | toInteger(replace(trim(x), ' GB', ''))] AS ramVariants 
WHERE size(ramVariants) > 0 AND all(x IN ramVariants WHERE x IS NOT NULL AND x > 0) 
UNWIND ramVariants AS capacity 
MERGE (ram:RAM {capacity_gb: capacity}) 
MERGE (d)-[:HAS_RAM]->(ram);

// Process storage specifications - separate nodes for each capacity
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.Storage IS NOT NULL AND trim(row.Storage) <> "" 
WITH row, d, [x IN split(row.Storage, ', ') | 
  CASE 
    WHEN trim(x) CONTAINS ' TB' THEN toInteger(replace(trim(x), ' TB', '')) * 1024 
    ELSE toInteger(replace(trim(x), ' GB', '')) 
  END
] AS storageVariants 
WHERE size(storageVariants) > 0 AND all(x IN storageVariants WHERE x IS NOT NULL AND x > 0) 
UNWIND storageVariants AS capacity 
MERGE (storage:Storage {capacity_gb: capacity}) 
MERGE (d)-[:HAS_STORAGE]->(storage);

// Process battery specifications
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.Battery IS NOT NULL AND trim(row.Battery) <> "" 
WITH row, d, 
  CASE 
    WHEN row.Battery CONTAINS 'Li-Ion' THEN 'Li-Ion' 
    WHEN row.Battery CONTAINS 'Li-Po' THEN 'Li-Po' 
    ELSE 'Unknown' 
  END AS batteryType, 
  CASE 
    WHEN row.Battery CONTAINS 'Fast charging' THEN true 
    ELSE false 
  END AS hasFastCharging, 
  toInteger(split(split(row.Battery, ' mAh')[0], ' ')[-1]) AS capacityMah 
WHERE capacityMah IS NOT NULL AND capacityMah > 0 
MERGE (battery:Battery {
  type: batteryType, 
  capacity_mah: capacityMah, 
  fast_charging: hasFastCharging
}) 
MERGE (d)-[:HAS_BATTERY]->(battery);

// Process back camera specifications
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.Back_Camera_MP IS NOT NULL AND toFloat(row.Back_Camera_MP) > 0 
MERGE (backCamera:Camera {
  type: 'Back', 
  megapixels: toInteger(toFloat(row.Back_Camera_MP))
}) 
MERGE (d)-[:HAS_CAMERA]->(backCamera);

// Process front camera specifications
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.Front_Camera_MP IS NOT NULL AND toFloat(row.Front_Camera_MP) > 0 
MERGE (frontCamera:Camera {
  type: 'Front', 
  megapixels: toInteger(toFloat(row.Front_Camera_MP))
}) 
MERGE (d)-[:HAS_CAMERA]->(frontCamera);

// Process screen specifications
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.Screen IS NOT NULL AND trim(row.Screen) <> "" 
WITH row, d, split(row.Screen, ' ') AS screenParts 
WITH row, d, screenParts, 
  toFloat(replace(screenParts[0], '"', '')) AS diagonal, 
  [i IN range(0, size(screenParts)-1) WHERE screenParts[i] = 'x'][0] AS x_position 
WHERE diagonal IS NOT NULL AND x_position IS NOT NULL 
WITH row, d, screenParts, diagonal, x_position, 
  screenParts[x_position-1] + ' x ' + screenParts[x_position+1] AS resolution, 
  reduce(type = '', i IN range(1, x_position-2) | 
    CASE WHEN type = '' THEN screenParts[i] ELSE type + ' ' + screenParts[i] END
  ) AS screenType 
WHERE resolution IS NOT NULL AND screenType <> "" 
MERGE (screen:Screen {
  diagonal_inch: diagonal, 
  type: trim(screenType), 
  resolution: resolution
}) 
MERGE (d)-[:HAS_SCREEN]->(screen);

// Process processor specifications
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.Processor IS NOT NULL AND trim(row.Processor) <> "" 
MERGE (processor:Processor {model: trim(row.Processor)}) 
MERGE (d)-[:HAS_PROCESSOR]->(processor);

// Process physical properties
LOAD CSV WITH HEADERS FROM 'file:///phone_data.csv' AS row 
MATCH (d:Device {model: row.Model}) 
WHERE row.Dimensions_Weight IS NOT NULL AND trim(row.Dimensions_Weight) <> "" 
WITH row, d, split(row.Dimensions_Weight, ',') AS dimensionParts 
WITH row, d, 
  trim(dimensionParts[0]) AS dimensions, 
  CASE WHEN size(dimensionParts) > 1 THEN trim(dimensionParts[1]) ELSE null END AS weight 
MERGE (pp:PhysicalProperties {
  dimensions: dimensions, 
  weight: weight
}) 
MERGE (d)-[:HAS_PHYSICAL_PROPERTIES]->(pp);

// Verify import results
MATCH (n) 
RETURN labels(n)[0] as NodeType, count(n) as Count 
ORDER BY Count DESC;