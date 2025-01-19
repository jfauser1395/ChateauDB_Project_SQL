-- Create and use database
CREATE DATABASE ChateauStayDB;
USE ChateauStayDB;

-- Create tables in order of dependencies

-- 1. Users table (no dependencies)
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    password_hash VARCHAR(255) NOT NULL,
    last_login TIMESTAMP NULL,
    failed_login_attempts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- 2. Employees table (no dependencies)
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    job_title VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- 3. Customers table (no dependencies)
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    registration_date DATE NOT NULL
);

-- 4. CancellationPolicies table (no dependencies)
CREATE TABLE CancellationPolicies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    refund_percentage DECIMAL(5,2) NOT NULL,
    days_before_checkin INT NOT NULL
);

-- 5. Apartments table (depends on Users and CancellationPolicies)
CREATE TABLE Apartments (
    apartment_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    price_per_night DECIMAL(10, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    num_bedrooms INT NOT NULL DEFAULT 1,
    num_bathrooms INT NOT NULL DEFAULT 1,
    size_sq_m DECIMAL(10, 2) NOT NULL,
    max_occupancy INT NOT NULL DEFAULT 2,
    check_in_time TIME DEFAULT '15:00',
    check_out_time TIME DEFAULT '11:00',
    minimum_stay INT DEFAULT 1,
    status ENUM('available', 'unavailable', 'maintenance', 'archived') NOT NULL DEFAULT 'available',
    cancellation_policy_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (owner_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (cancellation_policy_id) REFERENCES CancellationPolicies(policy_id),
    CONSTRAINT valid_price CHECK (price_per_night > 0),
    CONSTRAINT valid_size CHECK (size_sq_m > 0)
);

-- 6. Bookings table (depends on Apartments and Customers)
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT NOT NULL,
    customer_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'checked_in', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    contact_email VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20),
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT valid_dates CHECK (end_date > start_date)
);

-- Reviews table with improvements
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATE NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- Payments table with improvements
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    payment_method VARCHAR(50),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- Amenities table
CREATE TABLE Amenities (
    amenity_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- ApartmentAmenities table
CREATE TABLE ApartmentAmenities (
    apartment_id INT,
    amenity_id INT,
    PRIMARY KEY (apartment_id, amenity_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (amenity_id) REFERENCES Amenities(amenity_id)
);

-- Discounts table
CREATE TABLE Discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- BookingDiscounts table
CREATE TABLE BookingDiscounts (
    booking_id INT,
    discount_id INT,
    PRIMARY KEY (booking_id, discount_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id)
);

-- Messages table with improvements
CREATE TABLE Messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    content TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    message_type ENUM('booking', 'support', 'maintenance', 'general') NOT NULL DEFAULT 'general',
    parent_message_id INT NULL,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id),
    FOREIGN KEY (parent_message_id) REFERENCES Messages(message_id)
);

-- CleaningSchedules table
CREATE TABLE CleaningSchedules (
    cleaning_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT NOT NULL,
    cleaning_date DATE NOT NULL,
    cleaner_name VARCHAR(100) NOT NULL,
    notes TEXT,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

-- MaintenanceRequests table with improvements
CREATE TABLE MaintenanceRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT NOT NULL,
    requester_id INT NOT NULL,
    request_date DATE NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    priority ENUM('low', 'medium', 'high', 'urgent') NOT NULL DEFAULT 'medium',
    resolved_at TIMESTAMP NULL,
    resolved_by INT,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (requester_id) REFERENCES Users(user_id),
    FOREIGN KEY (resolved_by) REFERENCES Employees(employee_id)
);

-- PropertyManagers table
CREATE TABLE PropertyManagers (
    manager_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(100),
    address VARCHAR(255)
);

-- ManagedProperties table
CREATE TABLE ManagedProperties (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    manager_id INT NOT NULL,
    apartment_id INT NOT NULL,
    FOREIGN KEY (manager_id) REFERENCES PropertyManagers(manager_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

-- InsurancePolicies table
CREATE TABLE InsurancePolicies (
    insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT NOT NULL,
    policy_number VARCHAR(100) NOT NULL,
    coverage_amount DECIMAL(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

-- ApartmentPolicies table
CREATE TABLE ApartmentPolicies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT NOT NULL,
    policy_name VARCHAR(100) NOT NULL,
    policy_description TEXT,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

-- PropertyPhotos table
CREATE TABLE PropertyPhotos (
    photo_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT NOT NULL,
    photo_url VARCHAR(255) NOT NULL,
    description TEXT,
    upload_date DATE NOT NULL,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

-- UserRoles table
CREATE TABLE UserRoles (
    user_role_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ApartmentTypes table
CREATE TABLE ApartmentTypes (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- ApartmentTypeAssignments table
CREATE TABLE ApartmentTypeAssignments (
    apartment_id INT NOT NULL,
    type_id INT NOT NULL,
    PRIMARY KEY (apartment_id, type_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (type_id) REFERENCES ApartmentTypes(type_id)
);

-- SeasonalPricing table
CREATE TABLE SeasonalPricing (
    id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price_multiplier DECIMAL(4,2) NOT NULL,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    CONSTRAINT valid_seasonal_dates CHECK (end_date > start_date)
);

-- Create indexes for performance
CREATE INDEX idx_apartments_city ON Apartments(city);
CREATE INDEX idx_bookings_dates ON Bookings(start_date, end_date);
CREATE INDEX idx_messages_sent_at ON Messages(sent_at);
CREATE INDEX idx_reviews_rating ON Reviews(rating);

-- Insert sample data
-- 1. Insert Users (no dependencies)
INSERT INTO Users (first_name, last_name, email, phone_number, date_of_birth, password_hash) VALUES
('John', 'Smith', 'john.smith@email.com', '+1-555-0123', '1980-05-15', 'hashed_password_1'),
('Emma', 'Johnson', 'emma.j@email.com', '+1-555-0124', '1975-08-22', 'hashed_password_2'),
('Pierre', 'Dubois', 'pierre.d@email.com', '+33-555-0125', '1982-03-10', 'hashed_password_3'),
('Sophie', 'Martin', 'sophie.m@email.com', '+33-555-0126', '1988-11-30', 'hashed_password_4'),
('Carlos', 'Garcia', 'carlos.g@email.com', '+34-555-0127', '1979-07-18', 'hashed_password_5');

-- 2. Insert Employees (no dependencies)
INSERT INTO Employees (first_name, last_name, email, phone_number, hire_date, job_title, salary) VALUES
('Maria', 'Rodriguez', 'maria.r@chateaustay.com', '+1-555-0128', '2022-01-15', 'Property Manager', 55000.00),
('Jean', 'Dupont', 'jean.d@chateaustay.com', '+33-555-0129', '2022-03-01', 'Maintenance Supervisor', 48000.00),
('Alice', 'Williams', 'alice.w@chateaustay.com', '+1-555-0130', '2022-06-15', 'Customer Service Representative', 42000.00);

-- 3. Insert Customers (no dependencies)
INSERT INTO Customers (first_name, last_name, email, phone_number, registration_date) VALUES
('Michael', 'Brown', 'michael.b@email.com', '+1-555-0131', '2023-01-10'),
('Laura', 'Taylor', 'laura.t@email.com', '+1-555-0132', '2023-02-15'),
('Thomas', 'Anderson', 'thomas.a@email.com', '+1-555-0133', '2023-03-20'),
('Marie', 'Laurent', 'marie.l@email.com', '+33-555-0134', '2023-04-25'),
('Hans', 'Schmidt', 'hans.s@email.com', '+49-555-0135', '2023-05-30');

-- 4. Insert Property Managers (no dependencies)
INSERT INTO PropertyManagers (name, contact_info, address) VALUES
('Loire Valley Properties', 'contact@loirevalley.com', '789 Rue Principale, Tours, France'),
('Bordeaux Châteaux Management', 'info@bordeauxchateaux.com', '456 Avenue du Vin, Bordeaux, France'),
('Tuscany Villas', 'manager@tuscanyvillas.it', '123 Via Roma, Florence, Italy');

-- 5. Insert Amenities (no dependencies)
INSERT INTO Amenities (name, description) VALUES
('Swimming Pool', 'Outdoor heated pool'),
('Wine Cellar', 'Traditional wine storage with tasting area'),
('Garden', 'Manicured French gardens'),
('Tennis Court', 'Professional-grade court'),
('Chapel', 'Historic private chapel');

-- 6. Insert Apartment Types (no dependencies)
INSERT INTO ApartmentTypes (type_name, description) VALUES
('Château', 'Historic French castle'),
('Villa', 'Luxury countryside estate'),
('Castle', 'Historic British or German castle'),
('Palazzo', 'Italian historic palace');

-- 7. Insert CancellationPolicies (no dependencies)
INSERT INTO CancellationPolicies (name, description, refund_percentage, days_before_checkin) VALUES
('Flexible', 'Full refund if cancelled 24 hours before check-in', 100.00, 1),
('Moderate', '50% refund if cancelled 5 days before check-in', 50.00, 5),
('Strict', 'No refund within 7 days of check-in', 0.00, 7);

-- 8. Insert Apartments (depends on Users and CancellationPolicies)
INSERT INTO Apartments (owner_id, address, city, country, postal_code, price_per_night, currency, num_bedrooms, 
                       num_bathrooms, size_sq_m, max_occupancy, cancellation_policy_id) VALUES
(1, '123 Rue de la Loire', 'Tours', 'France', '37000', 250.00, 'EUR', 3, 2, 120.00, 6, 1),
(2, '456 Chemin du Château', 'Bordeaux', 'France', '33000', 350.00, 'EUR', 4, 3, 180.00, 8, 2),
(3, '789 Via Castello', 'Tuscany', 'Italy', '50100', 280.00, 'EUR', 2, 2, 90.00, 4, 1),
(4, '321 Castle Road', 'Edinburgh', 'United Kingdom', 'EH1 2NG', 200.00, 'GBP', 2, 1, 75.00, 4, 3),
(5, '654 Schlossweg', 'Bavaria', 'Germany', '80331', 300.00, 'EUR', 3, 2, 110.00, 6, 2);

-- 9. Insert ApartmentTypeAssignments (depends on Apartments and ApartmentTypes)
INSERT INTO ApartmentTypeAssignments (apartment_id, type_id) VALUES
(1, 1), -- Loire Valley Château
(2, 1), -- Bordeaux Château
(3, 2), -- Tuscany Villa
(4, 3), -- Edinburgh Castle
(5, 3); -- Bavarian Castle

-- 10. Insert ApartmentAmenities (depends on Apartments and Amenities)
INSERT INTO ApartmentAmenities (apartment_id, amenity_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2), (2, 3), (2, 4),
(3, 2), (3, 3),
(4, 3), (4, 5),
(5, 1), (5, 3), (5, 4);

-- 11. Insert Managed Properties (depends on PropertyManagers and Apartments)
INSERT INTO ManagedProperties (manager_id, apartment_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- 12. Insert Bookings (depends on Apartments and Customers)
INSERT INTO Bookings (apartment_id, customer_id, start_date, end_date, total_price, status, contact_email, contact_phone) VALUES
(1, 1, '2024-06-15', '2024-06-22', 1750.00, 'confirmed', 'michael.b@email.com', '+1-555-0131'),
(2, 2, '2024-07-01', '2024-07-08', 2450.00, 'confirmed', 'laura.t@email.com', '+1-555-0132'),
(3, 3, '2024-08-10', '2024-08-17', 1960.00, 'pending', 'thomas.a@email.com', '+1-555-0133'),
(4, 4, '2024-09-05', '2024-09-12', 1400.00, 'confirmed', 'marie.l@email.com', '+33-555-0134'),
(5, 5, '2024-10-01', '2024-10-08', 2100.00, 'pending', 'hans.s@email.com', '+49-555-0135');

-- 13. Insert Reviews (depends on Bookings)
INSERT INTO Reviews (booking_id, rating, comment, review_date) VALUES
(1, 5, 'Beautiful château with amazing Loire Valley views!', '2024-06-23'),
(2, 4, 'Great location in wine country, very spacious.', '2024-07-09'),
(4, 5, 'Wonderful Scottish castle experience.', '2024-09-13');

-- 14. Insert Payments (depends on Bookings)
INSERT INTO Payments (booking_id, payment_date, amount, currency, payment_method) VALUES
(1, '2024-05-15', 1750.00, 'EUR', 'credit_card'),
(2, '2024-06-01', 2450.00, 'EUR', 'bank_transfer'),
(4, '2024-08-05', 1400.00, 'GBP', 'credit_card');

-- 15. Insert Cleaning Schedules (depends on Apartments)
INSERT INTO CleaningSchedules (apartment_id, cleaning_date, cleaner_name, notes) VALUES
(1, '2024-06-14', 'Marie Claire', 'Pre-arrival deep clean'),
(1, '2024-06-22', 'Marie Claire', 'Post-departure clean'),
(2, '2024-06-30', 'Jean Baptiste', 'Pre-arrival deep clean');

-- 16. Insert Maintenance Requests (depends on Apartments and Users)
INSERT INTO MaintenanceRequests (apartment_id, requester_id, request_date, description, status, priority) VALUES
(1, 1, '2024-06-16', 'Pool heater needs checking', 'pending', 'medium'),
(2, 2, '2024-07-02', 'Tennis court needs resurfacing', 'pending', 'low'),
(3, 3, '2024-08-11', 'Wine cellar temperature control issue', 'pending', 'high');

-- 17. Insert Property Photos (depends on Apartments)
INSERT INTO PropertyPhotos (apartment_id, photo_url, description, upload_date) VALUES
(1, 'https://storage.chateaustay.com/loire-valley-1.jpg', 'Exterior view with Loire River', '2024-01-15'),
(1, 'https://storage.chateaustay.com/loire-valley-2.jpg', 'Master bedroom with period furniture', '2024-01-15'),
(2, 'https://storage.chateaustay.com/bordeaux-1.jpg', 'Aerial view of vineyard', '2024-01-20'),
(3, 'https://storage.chateaustay.com/tuscany-1.jpg', 'Tuscan countryside view', '2024-02-01');

-- 18. Insert Seasonal Pricing (depends on Apartments)
INSERT INTO SeasonalPricing (apartment_id, start_date, end_date, price_multiplier) VALUES
(1, '2024-07-01', '2024-08-31', 1.25), -- Summer peak season
(2, '2024-09-15', '2024-10-15', 1.30), -- Wine harvest season
(3, '2024-06-01', '2024-09-30', 1.20), -- Summer season
(4, '2024-08-01', '2024-08-31', 1.50), -- Edinburgh Festival period
(5, '2024-09-20', '2024-10-10', 1.35); -- Oktoberfest period

-- 19. Insert User Roles (depends on Users)
INSERT INTO UserRoles (user_id, role_name, start_date) VALUES
(1, 'property_owner', '2023-01-01'),
(2, 'property_owner', '2023-02-01'),
(3, 'property_owner', '2023-03-01'),
(4, 'property_owner', '2023-04-01'),
(5, 'property_owner', '2023-05-01');

-- 20. Insert Messages (depends on Users)
INSERT INTO Messages (sender_id, receiver_id, content, message_type) VALUES
(1, 3, 'Welcome to your stay! Please let me know if you need anything.', 'booking'),
(3, 1, 'Thank you! Could you recommend local wine tours?', 'general'),
(2, 4, 'Your booking is confirmed. Check-in details will be sent soon.', 'booking');