# Basic Queries

Simple, everyday queries for exploring the mobile devices database.

## Find all devices by company

```cypher
MATCH (d:Device)-[:PRODUCED_BY]->(c:Company {name: 'Samsung'})
RETURN d.model, d.device_type, d.release_date
ORDER BY d.release_date DESC
LIMIT 10;
```

## Devices with specific RAM capacity

```cypher
MATCH (d:Device)-[:HAS_RAM]->(ram:RAM)
WHERE ram.capacity_gb >= 8
RETURN d.model, ram.capacity_gb
ORDER BY ram.capacity_gb DESC
LIMIT 15;
```

## Find devices by type

```cypher
MATCH (d:Device {device_type: 'Phone'})
RETURN d.model, d.release_date
ORDER BY d.release_date DESC
LIMIT 10;
```

## Devices with large storage capacity

```cypher
MATCH (d:Device)-[:HAS_STORAGE]->(storage:Storage)
WHERE storage.capacity_gb >= 256
RETURN d.model, storage.capacity_gb
ORDER BY storage.capacity_gb DESC
LIMIT 10;
```

## Find devices with specific battery capacity

```cypher
MATCH (d:Device)-[:HAS_BATTERY]->(battery:Battery)
WHERE battery.capacity_mah >= 5000
RETURN d.model, battery.capacity_mah, battery.type
ORDER BY battery.capacity_mah DESC
LIMIT 10;
```

## Devices with high-resolution cameras

```cypher
MATCH (d:Device)-[:HAS_CAMERA]->(cam:Camera {type: 'Back'})
WHERE cam.megapixels >= 50
RETURN d.model, cam.megapixels
ORDER BY cam.megapixels DESC
LIMIT 10;
```

## Find devices by release year

```cypher
MATCH (d:Device)
WHERE d.release_date CONTAINS '2024'
RETURN d.model, d.device_type, d.release_date
ORDER BY d.model
LIMIT 15;
```

## Count devices by company

```cypher
MATCH (d:Device)-[:PRODUCED_BY]->(c:Company)
RETURN c.name, count(d) as device_count
ORDER BY device_count DESC;
```

## Find all processors used

```cypher
MATCH (p:Processor)<-[:HAS_PROCESSOR]-(d:Device)
RETURN p.model, count(d) as device_count
ORDER BY device_count DESC
LIMIT 10;
```

## Devices with large screens

```cypher
MATCH (d:Device)-[:HAS_SCREEN]->(screen:Screen)
WHERE screen.diagonal_inch >= 6.5
RETURN d.model, screen.diagonal_inch, screen.type
ORDER BY screen.diagonal_inch DESC
LIMIT 10;
```