# Advanced Analysis

Complex analytical queries for business intelligence and market research.

## Premium phones with top specifications

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
MATCH (d)-[:HAS_CAMERA]->(cam:Camera {type: 'Back'})
MATCH (d)-[:PRODUCED_BY]->(c:Company)
WHERE ram.capacity_gb >= 12 AND storage.capacity_gb >= 256 AND cam.megapixels >= 50
RETURN c.name, d.model, ram.capacity_gb, storage.capacity_gb, cam.megapixels
ORDER BY ram.capacity_gb DESC
LIMIT 10;
```

## Brand comparison - average specifications

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:PRODUCED_BY]->(c:Company)
MATCH (d)-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
MATCH (d)-[:HAS_BATTERY]->(battery:Battery)
WITH c.name as Company, d,
     max(ram.capacity_gb) as max_ram,
     max(storage.capacity_gb) as max_storage,
     battery.capacity_mah as battery_capacity
RETURN Company,
       count(d) as Phone_Count,
       round(avg(max_ram), 1) as Avg_RAM,
       round(avg(max_storage), 0) as Avg_Storage,
       round(avg(battery_capacity), 0) as Avg_Battery
ORDER BY Phone_Count DESC;
```

## Samsung devices with multiple memory options

```cypher
MATCH (d:Device)-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
MATCH (d)-[:PRODUCED_BY]->(c:Company {name: 'Samsung'})
WHERE d.release_date CONTAINS '2024'
WITH d, c, 
     collect(DISTINCT ram.capacity_gb) as ram_options,
     collect(DISTINCT storage.capacity_gb) as storage_options
WHERE size(ram_options) > 1 OR size(storage_options) > 1
RETURN c.name, d.model, d.release_date, ram_options, storage_options
ORDER BY size(ram_options) DESC
LIMIT 8;
```

## AMOLED phones from 2023 with large screens

```cypher
MATCH (d:Device)-[:HAS_SCREEN]->(s:Screen)
MATCH (d)-[:PRODUCED_BY]->(c:Company)
WHERE s.type CONTAINS 'AMOLED' AND d.release_date CONTAINS '2023'
  AND d.device_type = 'Phone'
RETURN c.name, d.model, d.release_date, s.diagonal_inch, s.type, s.resolution
ORDER BY s.diagonal_inch DESC
LIMIT 10;
```

## High-end tablets with premium batteries

```cypher
MATCH (d:Device {device_type: 'Tablet'})-[:HAS_BATTERY]->(battery:Battery)
MATCH (d)-[:HAS_SCREEN]->(screen:Screen)
WHERE battery.fast_charging = true AND screen.diagonal_inch >= 10
  AND battery.capacity_mah >= 7000
RETURN d.model, d.release_date, battery.capacity_mah, battery.type, screen.diagonal_inch
ORDER BY battery.capacity_mah DESC;
```

## Processor popularity analysis

```cypher
MATCH (d:Device)-[:PRODUCED_BY]->(c:Company)
MATCH (d)-[:HAS_PROCESSOR]->(p:Processor)
WITH c.name as Brand, p.model as Processor, count(d) as DeviceCount
WHERE DeviceCount >= 5
RETURN Brand, Processor, DeviceCount
ORDER BY Brand, DeviceCount DESC;
```

## Memory configuration trends by year

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:HAS_RAM]->(ram:RAM)
MATCH (d)-[:HAS_STORAGE]->(storage:Storage)
WHERE d.release_date CONTAINS '2023' OR d.release_date CONTAINS '2024'
WITH d.release_date as Year, 
     max(ram.capacity_gb) as max_ram,
     max(storage.capacity_gb) as max_storage
RETURN Year,
       round(avg(max_ram), 1) as Avg_RAM_GB,
       round(avg(max_storage), 0) as Avg_Storage_GB,
       count(*) as Phone_Count
ORDER BY Year;
```

## Battery technology distribution

```cypher
MATCH (d:Device)-[:HAS_BATTERY]->(battery:Battery)
MATCH (d)-[:PRODUCED_BY]->(c:Company)
RETURN c.name as Company,
       battery.type as Battery_Type,
       count(d) as Device_Count,
       round(avg(battery.capacity_mah), 0) as Avg_Capacity_mAh
ORDER BY Company, Device_Count DESC;
```

## Camera specifications by device type

```cypher
MATCH (d:Device)-[:HAS_CAMERA]->(cam:Camera)
WHERE cam.type = 'Back'
RETURN d.device_type as Device_Type,
       round(avg(cam.megapixels), 1) as Avg_Back_Camera_MP,
       min(cam.megapixels) as Min_MP,
       max(cam.megapixels) as Max_MP,
       count(d) as Device_Count
ORDER BY Device_Type;
```

## Screen technology trends

```cypher
MATCH (d:Device {device_type: 'Phone'})-[:HAS_SCREEN]->(screen:Screen)
WHERE d.release_date CONTAINS '2023' OR d.release_date CONTAINS '2024'
WITH screen.type as Screen_Type, d.release_date as Year, screen.diagonal_inch as Size
RETURN Screen_Type, Year,
       count(*) as Phone_Count,
       round(avg(Size), 2) as Avg_Screen_Size
ORDER BY Year, Phone_Count DESC;
```