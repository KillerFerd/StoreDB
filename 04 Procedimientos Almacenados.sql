-- Usar DB "Store"
USE Store;

-- Procedimiento "AddBran"
IF OBJECT_ID('sp_AddBrand', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddBrand;
GO
CREATE PROCEDURE sp_AddBrand
    @brandName VARCHAR(255)
AS
BEGIN
    INSERT INTO brands (name)
    VALUES (@brandName);
END;

-- Ejecución "AddBran"
EXEC sp_AddBrand 'ASUS';

-- Procedimiento "AddCategory"
IF OBJECT_ID('sp_AddCategory', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddCategory;
GO
CREATE PROCEDURE sp_AddCategory
    @categoryName VARCHAR(255)
AS
BEGIN
    INSERT INTO categories (name)
    VALUES (@categoryName);
END;
GO

-- Ejecución "AddCategory"
EXEC sp_AddCategory 'Monitores';

-- Procedimiento "AddProduct"
IF OBJECT_ID('sp_AddProduct', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddProduct;
GO
CREATE PROCEDURE sp_AddProduct
    @brandId INT,
    @categoryId INT,
    @productName VARCHAR(255),
    @saleValue DECIMAL(30, 2),
    @costValue DECIMAL(30, 2)
AS
BEGIN
    -- Agregar el producto a la tabla "products"
    INSERT INTO products (idBrand, idCategory, name, saleValue, costValue)
    VALUES (@brandId, @categoryId, @productName, @saleValue, @costValue);

    -- Obtener el IdProduct generado para el nuevo producto
    DECLARE @productId INT;
    SET @productId = SCOPE_IDENTITY();

    -- Agregar el registro correspondiente en la tabla "inventory"
    INSERT INTO inventory (idProduct, stock, saleValue, costValue)
    VALUES (@productId, 0, 0, 0);
END;
GO

-- Ejecución "AddProduct"
EXEC sp_AddProduct 
@brandId = 1, 
@categoryId = 1, 
@productName = 'Razer Huntsman Mini', 
@saleValue = 65.00, 
@costValue = 50.00;


-- Procedimiento "AddSalesAndDetailSales"
IF OBJECT_ID('AddSalesAndDetailSales', 'P') IS NOT NULL
    DROP PROCEDURE AddSalesAndDetailSales;
GO
CREATE PROCEDURE AddSalesAndDetailSales
    @NIT INT,
    @DetailSalesData AS NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdSale INT;

    -- Agregar registro a la tabla "sales"
    INSERT INTO sales (date, NIT, saleValue)
    VALUES (GETDATE(), @NIT, 0);  -- Se establece "saleValue" en 0 por el momento

    -- Obtener el IdSale del registro recién insertado
    SET @IdSale = SCOPE_IDENTITY();

    -- Crear tabla temporal para almacenar los datos de DetailSales
    CREATE TABLE #TempDetailSales (
        idProduct INT,
        quantity INT,
        saleValue DECIMAL(30, 2)
    );

    -- Insertar los datos de DetailSales en la tabla temporal
    INSERT INTO #TempDetailSales (idProduct, quantity, saleValue)
    SELECT idProduct, quantity, saleValue
    FROM OPENJSON(@DetailSalesData)
    WITH (
        idProduct INT,
        quantity INT,
        saleValue DECIMAL(30, 2)
    );

    -- Agregar registros a la tabla "detailSales" con el mismo IdSale
    INSERT INTO detailSales (idSale, idProduct, quantity, saleValue)
    SELECT @IdSale, idProduct, quantity, saleValue
    FROM #TempDetailSales;

    -- Actualizar el "saleValue" en la tabla "sales" con la suma de los valores de venta en detailSales
    UPDATE sales
    SET saleValue = (
            SELECT SUM(saleValue)
            FROM detailSales
            WHERE idSale = @IdSale
        )
    WHERE IdSale = @IdSale;

    -- Agregar registros a la tabla "detailInventory" por cada registro en detailSales
    INSERT INTO detailInventory (idInventory, idTipeReason, idReason, tipe, date, quantity)
    SELECT i.idInventory, 1, @IdSale, 1, GETDATE(), ds.quantity
    FROM detailSales ds
    INNER JOIN inventory i ON ds.idProduct = i.idProduct
    WHERE ds.idSale = @IdSale;

    -- Llamar al procedimiento "AddDetailInventory" para agregar registros a la tabla "detailInventory"
    EXEC UpdateInventoryByReason @IdSale;

    -- Eliminar la tabla temporal
    DROP TABLE #TempDetailSales;
END;

-- Ejecutar "AddSalesAndDetailSales"
DECLARE @NIT INT;
DECLARE @DetailSalesData NVARCHAR(MAX);

-- Establecer los valores de los parámetros
SET @NIT = 1234567890; -- Reemplaza con el valor deseado
SET @DetailSalesData = '[
    {"idProduct": 1, "quantity": 2, "saleValue": 10.99},
    {"idProduct": 2, "quantity": 3, "saleValue": 15.99},
    {"idProduct": 3, "quantity": 1, "saleValue": 8.99}
]'; -- Reemplaza con los valores deseados

-- Ejecutar el procedimiento almacenado
EXEC AddSalesAndDetailSales @NIT, @DetailSalesData;


-- Procedimiento "UpdateInventoryByReason"
CREATE PROCEDURE UpdateInventoryByReason
    @idReason INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Modificar registros en la tabla "inventory" según el parámetro @idReason
    UPDATE inventory
    SET stock = CASE
                    WHEN di.tipe = 1 THEN inventory.stock - di.quantity
                    WHEN di.tipe = 2 THEN inventory.stock + di.quantity
                END,
        saleValue = inventory.stock * p.saleValue,
        costValue = inventory.stock * p.costValue
    FROM inventory
    INNER JOIN detailInventory di ON inventory.idInventory = di.idInventory
    INNER JOIN products p ON inventory.idProduct = p.IdProduct
    WHERE di.idReason = @idReason;
END;

