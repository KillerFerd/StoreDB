-- Usar DB "Store"
USE Store;

-- Primera ejecución
DELETE FROM brands;
DELETE FROM categories;
DELETE FROM products;
DELETE FROM inventory;

-- Segunda Ejecución
DBCC CHECKIDENT('brands', RESEED, 0);
DBCC CHECKIDENT('categories', RESEED, 0);
DBCC CHECKIDENT('products', RESEED, 0);
DBCC CHECKIDENT('inventory', RESEED, 0);

-- Tercera Ejecución

-- Datos Iniciales "brands"
INSERT INTO brands (name)
VALUES ('Razer'),
       ('Logitech'),
       ('Corsair'),
       ('SteelSeries'),
       ('HyperX');

-- Datos Iniciales "categories"
INSERT INTO categories (name)
VALUES ('Teclados'),
       ('Ratones'),
       ('Auriculares'),
       ('Mousepads'),
       ('Sillas gaming');

-- Datos Iniciales "products"
INSERT INTO products (idBrand, idCategory, name, saleValue, costValue)
VALUES 
    (1, 1, 'Teclado Razer BlackWidow Elite', 150.00, 112.50),
    (2, 2, 'Ratón Logitech G502 Hero', 80.00, 60.00),
    (3, 3, 'Auriculares Corsair Void RGB Elite', 100.00, 75.00),
    (4, 4, 'Mousepad SteelSeries QcK Prism', 40.00, 30.00),
    (5, 5, 'Silla gaming HyperX Cloud Alpha', 200.00, 150.00);

-- Datos Iniciales "inventory"
INSERT INTO inventory (idProduct, stock, saleValue, costValue)
SELECT p.IdProduct, i.stock, i.stock * p.saleValue, i.stock * p.costValue
FROM products p
JOIN (
    VALUES (1, 10), (2, 15), (3, 5), (4, 3), (5, 20)
) AS i(idProduct, stock) ON p.IdProduct = i.idProduct;

