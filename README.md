# Vehicle Rental System - Database Project

## Project Overview

This project implements a simple **Vehicle Rental System** database using **PostgreSQL**. The system manages:

- **Users** (Customers and Admins)
- **Vehicles** (cars, bikes, trucks)
- **Bookings** (rental records linking users to vehicles)

The design supports key business requirements such as unique user emails and vehicle registration numbers, vehicle availability tracking, booking status management, and total cost calculation.

### Key Features

- Role-based users: `Admin` or `Customer`
- Vehicles with type, model, unique registration, daily rental price, and availability status
- Bookings with start/end dates, status (`pending`, `confirmed`, `completed`, `cancelled`), and total cost
- Data integrity enforced via constraints (UNIQUE, CHECK, FOREIGN KEY)

## Database Schema (PostgreSQL)

```sql
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Customer')),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE Vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('car', 'bike', 'truck')),
    model VARCHAR(100) NOT NULL,
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    rental_price_per_day DECIMAL(10, 2) NOT NULL,
    availability_status VARCHAR(20) NOT NULL
        CHECK (availability_status IN ('available', 'rented', 'maintenance'))
        DEFAULT 'available',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    vehicle_id INT NOT NULL REFERENCES Vehicles(vehicle_id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    booking_status VARCHAR(20) NOT NULL
        CHECK (booking_status IN ('pending', 'confirmed', 'completed', 'cancelled'))
        DEFAULT 'pending',
    total_cost DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (end_date >= start_date)
);
```

Sample Data
The project includes sample data for demonstration:
Users

Alice (Customer)
Bob (Admin)
Charlie (Customer)

Vehicles

Toyota Corolla (car, available)
Honda Civic (car, rented)
Yamaha R15 (bike, available)
Ford F-150 (truck, maintenance)

Bookings
4 bookings involving Alice and Charlie with the Honda Civic and Toyota Corolla.
Required SQL Queries
All queries are also saved in queries.sql.

1. Retrieve booking information with customer and vehicle names

```sql
SELECT
    b.booking_id,
    u.name AS customer_name,
    v.vehicle_name,
    v.type AS vehicle_type,
    v.model AS vehicle_model,
    b.start_date,
    b.end_date,
    b.booking_status,
    b.total_cost
FROM Bookings b
JOIN Users u ON b.user_id = u.user_id
JOIN Vehicles v ON b.vehicle_id = v.vehicle_id
WHERE u.role = 'Customer'
ORDER BY b.booking_id;
```

2. Find vehicles that have never been booked (using NOT EXISTS)

```sql
SELECT
    vehicle_id,
    vehicle_name AS name,
    type,
    model,
    registration_number,
    rental_price_per_day AS rental_price,
    availability_status AS status
FROM Vehicles v
WHERE NOT EXISTS (
    SELECT 1
    FROM Bookings b
    WHERE b.vehicle_id = v.vehicle_id
)
ORDER BY vehicle_id;
```

3. Retrieve all available vehicles of a specific type (e.g., cars) (using WHERE)

```sql
SELECT
    vehicle_id,
    vehicle_name AS name,
    type,
    model,
    registration_number,
    rental_price_per_day AS rental_price,
    availability_status AS status
FROM Vehicles
WHERE type = 'car'
  AND availability_status = 'available'
ORDER BY vehicle_id;
```

4. Find vehicles with more than 2 bookings (using GROUP BY and HAVING)

```sql
SELECT
    v.vehicle_name,
    COUNT(b.booking_id) AS total_bookings
FROM Vehicles v
JOIN Bookings b ON v.vehicle_id = b.vehicle_id
GROUP BY v.vehicle_name
HAVING COUNT(b.booking_id) > 2
ORDER BY total_bookings DESC;
```

How to Use

Connect to your PostgreSQL database
Run the schema creation scripts in order: Users → Vehicles → Bookings
(Optional) Insert the sample data
Execute the queries from queries.sql to verify results

This project demonstrates core SQL concepts:

Table relationships and foreign keys
JOIN operations
Subqueries with NOT EXISTS
Filtering with WHERE
Aggregation with GROUP BY and HAVING
