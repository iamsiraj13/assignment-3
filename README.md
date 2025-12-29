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
