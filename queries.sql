-- Table: Users

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Customer')),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255),
    phone_number VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: Vehicles
CREATE TABLE Vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (
        type IN ('car', 'bike', 'truck')
    ),
    model VARCHAR(100) NOT NULL,
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    rental_price_per_day DECIMAL(10, 2) NOT NULL,
    availability_status VARCHAR(20) NOT NULL CHECK (
        availability_status IN (
            'available',
            'rented',
            'maintenance'
        )
    ) DEFAULT 'available',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: Bookings (simple version as requested)
CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
    vehicle_id INT NOT NULL REFERENCES Vehicles (vehicle_id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    booking_status VARCHAR(20) NOT NULL CHECK (
        booking_status IN (
            'pending',
            'confirmed',
            'completed',
            'cancelled'
        )
    ) DEFAULT 'pending',
    total_cost DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (end_date >= start_date)
);

SELECT
    b.booking_id,
    u.name AS customer_name,
    v.vehicle_name,
    b.start_date,
    b.end_date,
    b.booking_status as status
FROM
    Bookings b
    JOIN Users u ON b.user_id = u.user_id
    JOIN Vehicles v ON b.vehicle_id = v.vehicle_id
WHERE
    u.role = 'Customer'
ORDER BY b.booking_id;

SELECT
    vehicle_id,
    vehicle_name,
    type,
    model,
    registration_number,
    rental_price_per_day AS rental_price,
    availability_status AS status
FROM Vehicles v
WHERE
    NOT EXISTS (
        SELECT 1
        FROM Bookings b
        WHERE
            b.vehicle_id = v.vehicle_id
    )
ORDER BY vehicle_id;

SELECT
    vehicle_id,
    vehicle_name AS name,
    type,
    model,
    registration_number,
    rental_price_per_day AS rental_price,
    availability_status AS status
FROM Vehicles
WHERE
    type = 'car'
    AND availability_status = 'available'
ORDER BY vehicle_id;

SELECT v.vehicle_name, COUNT(b.booking_id) AS total_bookings
FROM Vehicles v
    JOIN Bookings b ON v.vehicle_id = b.vehicle_id
GROUP BY
    v.vehicle_name
HAVING
    COUNT(b.booking_id) > 2
ORDER BY total_bookings DESC;