-- Create the database
CREATE DATABASE ChateauStayDB;
USE ChateauStayDB;

-- Create tables
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    date_of_birth DATE
);

CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    hire_date DATE,
    job_title VARCHAR(100),
    salary DECIMAL(10, 2)
);

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    registration_date DATE
);

CREATE TABLE Apartments (
    apartment_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT,
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    price_per_night DECIMAL(10, 2),
    num_bedrooms INT,
    num_bathrooms INT,
    size_sq_m DECIMAL(10, 2),
    FOREIGN KEY (owner_id) REFERENCES Users(user_id)
);

CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    customer_id INT,
    start_date DATE,
    end_date DATE,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATE,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    payment_date DATE,
    amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

CREATE TABLE Amenities (
    amenity_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT
);

CREATE TABLE ApartmentAmenities (
    apartment_id INT,
    amenity_id INT,
    PRIMARY KEY (apartment_id, amenity_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (amenity_id) REFERENCES Amenities(amenity_id)
);

CREATE TABLE Messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT,
    receiver_id INT,
    content TEXT,
    sent_at DATETIME,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);

CREATE TABLE Discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    discount_percentage DECIMAL(5, 2),
    start_date DATE,
    end_date DATE
);

CREATE TABLE BookingDiscounts (
    booking_id INT,
    discount_id INT,
    PRIMARY KEY (booking_id, discount_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id)
);

CREATE TABLE ApartmentPolicies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    policy_name VARCHAR(100),
    policy_description TEXT,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE PropertyManagers (
    manager_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    contact_info VARCHAR(100),
    address VARCHAR(255)
);

CREATE TABLE ManagedProperties (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    manager_id INT,
    apartment_id INT,
    FOREIGN KEY (manager_id) REFERENCES PropertyManagers(manager_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE CleaningSchedules (
    cleaning_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    cleaning_date DATE,
    cleaner_name VARCHAR(100),
    notes TEXT,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE MaintenanceRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    requester_id INT,
    request_date DATE,
    description TEXT,
    status VARCHAR(50),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (requester_id) REFERENCES Users(user_id)
);

CREATE TABLE PropertyPhotos (
    photo_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    photo_url VARCHAR(255),
    description TEXT,
    upload_date DATE,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE UserFavorites (
    user_id INT,
    apartment_id INT,
    PRIMARY KEY (user_id, apartment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE NeighboringProperties (
    property1_id INT,
    property2_id INT,
    PRIMARY KEY (property1_id, property2_id),
    FOREIGN KEY (property1_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (property2_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE InsurancePolicies (
    insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    policy_number VARCHAR(100),
    coverage_amount DECIMAL(10, 2),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE PropertyRules (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    rule_description TEXT,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE ApartmentTypes (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100),
    description TEXT
);

CREATE TABLE ApartmentTypeAssignments (
    apartment_id INT,
    type_id INT,
    PRIMARY KEY (apartment_id, type_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (type_id) REFERENCES ApartmentTypes(type_id)
);

-- Example Triple Relationships
CREATE TABLE PropertyOwners (
    property_owner_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT,
    apartment_id INT,
    ownership_percentage DECIMAL(5, 2),
    FOREIGN KEY (owner_id) REFERENCES Users(user_id),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
);

CREATE TABLE UserRoles (
    user_role_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    role_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE ApartmentLeases (
    lease_id INT AUTO_INCREMENT PRIMARY KEY,
    apartment_id INT,
    tenant_id INT,
    lease_start_date DATE,
    lease_end_date DATE,
    monthly_rent DECIMAL(10, 2),
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
    FOREIGN KEY (tenant_id) REFERENCES Users(user_id)
);

-- Recursive Relationship Example
ALTER TABLE Messages
ADD CONSTRAINT fk_sender_receiver
FOREIGN KEY (receiver_id) REFERENCES Messages(sender_id);
