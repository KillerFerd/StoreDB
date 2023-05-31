-- Crear DB "Store"
IF DB_ID('Store') IS NOT NULL
    BEGIN
        ALTER DATABASE Store SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE Store;
    END
CREATE DATABASE Store;

-- Usar DB "Store"
USE Store;

-- Tabla "brands"
IF OBJECT_ID('brands', 'U') IS NOT NULL
    DROP TABLE brands;
CREATE TABLE brands
(
    idBrand INT IDENTITY(1, 1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

IF OBJECT_ID('categories', 'U') IS NOT NULL
    DROP TABLE categories;
CREATE TABLE categories
(
    idCategory INT IDENTITY(1, 1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Tabla "products"
IF OBJECT_ID('products', 'U') IS NOT NULL
    DROP TABLE products;
CREATE TABLE products
(
    IdProduct INT IDENTITY(1, 1) PRIMARY KEY,
    idBrand INT NOT NULL,
    idCategory INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    saleValue DECIMAL(30, 2) NOT NULL,
    costValue DECIMAL(30, 2) NOT NULL,
    CONSTRAINT FK_products_brands FOREIGN KEY (idBrand) REFERENCES brands (idBrand),
    CONSTRAINT FK_products_categories FOREIGN KEY (idCategory) REFERENCES categories (idCategory)
);

-- Tabla "inventory"
IF OBJECT_ID('inventory', 'U') IS NOT NULL
    DROP TABLE inventory;
CREATE TABLE inventory
(
    idInventory INT IDENTITY(1, 1) PRIMARY KEY,
    idProduct INT NOT NULL,
    stock INT NOT NULL,
    saleValue DECIMAL(30, 2) NOT NULL,
    costValue DECIMAL(30, 2) NOT NULL,
    CONSTRAINT FK_inventory_products FOREIGN KEY (idProduct) REFERENCES products (IdProduct)
);

--Tabla "detailInventory"
IF OBJECT_ID('detailInventory', 'U') IS NOT NULL
    DROP TABLE detailInventory;
CREATE TABLE detailInventory
(
    idDetailInventory INT IDENTITY(1, 1) PRIMARY KEY,
    idInventory INT NOT NULL,
	idTipeReason INT NOT NULL,
	idReason INT NOT NULL,
	tipe INT NOT NULL, 
    date DATE NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT FK_detailInventory_inventory FOREIGN KEY (idInventory) REFERENCES inventory (idInventory)
);


-- Tabla "sales"
IF OBJECT_ID('sales', 'U') IS NOT NULL
    DROP TABLE sales;
CREATE TABLE sales
(
    Idsale INT IDENTITY(1, 1) PRIMARY KEY,
    date DATETIME NOT NULL,
    NIT INT NOT NULL,
    saleValue DECIMAL(30, 2) NOT NULL
);

-- Tabla "detailSales"
IF OBJECT_ID('detailSales', 'U') IS NOT NULL
    DROP TABLE detailSales;
CREATE TABLE detailSales
(
    idDetailSale INT IDENTITY(1, 1) PRIMARY KEY,
    idSale INT NOT NULL,
    idProduct INT NOT NULL,
    quantity INT NOT NULL,
    saleValue DECIMAL(30, 2) NOT NULL,
    CONSTRAINT FK_detailSales_sales FOREIGN KEY (idSale) REFERENCES sales (Idsale),
    CONSTRAINT FK_detailSales_products FOREIGN KEY (idProduct) REFERENCES products (IdProduct)
);