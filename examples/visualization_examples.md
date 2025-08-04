# Visualization Examples

Queries designed for creating graphs and visual representations in Neo4j Browser.

## Samsung Galaxy S21 family structure

```cypher
MATCH (d:Device)-[:PRODUCED_BY]->(c:Company {name: 'Samsung'})
WHERE d.model STARTS WITH 'SAMSUNG GALAXY S21'
OPTIONAL MATCH (d)-[:HAS_RAM]->(ram:RAM)
OPTIONAL MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
OPTIONAL MATCH (d)-[:HAS_BATTERY]->(battery:Battery)
OPTIONAL MATCH (d)-[:HAS_PROCESSOR]->(processor:Processor)
RETURN d, c, ram, storage, battery, processor
LIMIT 15;
```

## Samsung phones with Snapdragon processors

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:PRODUCED_BY]->(c:Company {name: 'Samsung'})
MATCH (d)-[:HAS_PROCESSOR]->(p:Processor)
MATCH (d)-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
WHERE p.model CONTAINS 'Snapdragon' AND d.release_date CONTAINS '2024'
  AND ram.capacity_gb >= 8
RETURN d, c, p, ram, storage;
```

## Device with complete specifications

```cypher
MATCH (d:Device {model: 'SAMSUNG GALAXY F55'}) 
OPTIONAL MATCH (c:Company)<-[:PRODUCED_BY]-(d)
OPTIONAL MATCH (d)-[:HAS_RAM]->(ram:RAM) 
OPTIONAL MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
OPTIONAL MATCH (d)-[:HAS_BATTERY]->(battery:Battery) 
OPTIONAL MATCH (d)-[:HAS_CAMERA]->(camera:Camera) 
OPTIONAL MATCH (d)-[:HAS_SCREEN]->(screen:Screen) 
OPTIONAL MATCH (d)-[:HAS_PROCESSOR]->(processor:Processor) 
OPTIONAL MATCH (d)-[:HAS_PHYSICAL_PROPERTIES]->(pp:PhysicalProperties)
RETURN d, c, ram, storage, battery, camera, screen, processor, pp;
```

## Premium devices network

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
MATCH (d)-[:PRODUCED_BY]->(c:Company)
WHERE ram.capacity_gb >= 12 AND storage.capacity_gb >= 512
RETURN d, c, ram, storage
LIMIT 20;
```

## RAM and Storage combinations

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
WITH ram.capacity_gb as RAM_GB, storage.capacity_gb as Storage_GB, count(d) as combinations
WHERE combinations >= 5
MATCH (d2:Device)-[:HAS_RAM]->(ram2:RAM {capacity_gb: RAM_GB})
MATCH (d2)-[:HAS_STORAGE]->(storage2:Storage {capacity_gb: Storage_GB})
RETURN d2, ram2, storage2
LIMIT 30;
```

## Battery technology distribution graph

```cypher
MATCH (d:Device)-[:HAS_BATTERY]->(battery:Battery)
MATCH (d)-[:PRODUCED_BY]->(c:Company)
WHERE battery.capacity_mah >= 4000
RETURN d, c, battery
LIMIT 25;
```

## High-end camera network

```cypher
MATCH (d:Device)-[:HAS_CAMERA]->(cam:Camera {type: 'Back'})
MATCH (d)-[:PRODUCED_BY]->(c:Company)
WHERE cam.megapixels >= 50
OPTIONAL MATCH (d)-[:HAS_CAMERA]->(front_cam:Camera {type: 'Front'})
RETURN d, c, cam, front_cam
LIMIT 20;
```

## Screen technology clusters

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:HAS_SCREEN]->(screen:Screen)
MATCH (d)-[:PRODUCED_BY]->(c:Company)
WHERE screen.type CONTAINS 'AMOLED' AND screen.diagonal_inch >= 6.5
RETURN d, c, screen
LIMIT 25;
```

## Device variants with multiple configurations

```cypher
MATCH (d:Device)-[:PRODUCED_BY]->(c:Company {name: 'Samsung'})
MATCH (d)-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
WHERE d.release_date CONTAINS '2024'
WITH d, c, collect(DISTINCT ram) as rams, collect(DISTINCT storage) as storages
WHERE size(rams) > 1 OR size(storages) > 1
UNWIND rams as ram
UNWIND storages as storage
RETURN d, c, ram, storage
LIMIT 30;
```