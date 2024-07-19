/*
Cleaning Data in MySQL
*/

SELECT * 
FROM nashvillehousing;

ALTER TABLE nashvillehousing
RENAME COLUMN ο»ΏUniqueID TO UniqueID;

SELECT PropertyAddress
FROM nashvillehousing
WHERE PropertyAddress = '';

UPDATE nashvillehousing
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

SELECT PropertyAddress
FROM nashvillehousing
WHERE PropertyAddress IS NULL;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashvillehousing a 
JOIN nashvillehousing b
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashvillehousing a
JOIN nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;

SELECT PropertyAddress, SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

SELECT PropertySplitAddress, PropertySplitCity
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress;

SELECT OwnerAddress, SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OwnerSplitCity,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerSplitState
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitState NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress;

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END;

WITH row_num_cte AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, SalePrice, PropertySplitAddress, 
PropertySplitcITY, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState ORDER BY UniqueID) AS row_num
FROM nashvillehousing
)
SELECT *
FROM row_num_cte
WHERE row_num > 1;

CREATE TABLE `nashvillehousing2` (
  `UniqueID` int DEFAULT NULL,
  `ParcelID` text,
  `LandUse` text,
  `SaleDate` text,
  `SalePrice` int DEFAULT NULL,
  `LegalReference` text,
  `SoldAsVacant` text,
  `OwnerName` text,
  `Acreage` text,
  `TaxDistrict` text,
  `LandValue` int DEFAULT NULL,
  `BuildingValue` int DEFAULT NULL,
  `TotalValue` int DEFAULT NULL,
  `YearBuilt` int DEFAULT NULL,
  `Bedrooms` int DEFAULT NULL,
  `FullBath` int DEFAULT NULL,
  `HalfBath` int DEFAULT NULL,
  `PropertySplitAddress` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `PropertySplitcITY` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `OwnerSplitAddress` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `OwnerSplitCity` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `OwnerSplitState` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO nashvillehousing2
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, SalePrice, PropertySplitAddress, 
PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState ORDER BY UniqueID) AS row_num
FROM nashvillehousing;

DELETE 
FROM nashvillehousing2
WHERE row_num > 1;

ALTER TABLE nashvillehousing2
DROP COLUMN row_num;

SELECT *
FROM nashvillehousing2;
