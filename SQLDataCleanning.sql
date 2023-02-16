
-- Select everything

SELECT * 
FROM Housing

-- Standarize Date Format

SELECT SalesDateConvert, CONVERT(date, SaleDate)
FROM Housing

UPDATE Housing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly

ALTER TABLE Housing
ADD SalesDateConvert Date;

UPDATE Housing
SET SalesDateConvert = CONVERT(Date, SaleDate)


-- Populate Property Address data

SELECT *
FROM Housing 
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT HA.ParcelID, HA.PropertyAddress, HB.ParcelID, HB.PropertyAddress, ISNULL(HA.PropertyAddress, HB.PropertyAddress)
FROM Housing AS HA
JOIN Housing AS HB
	ON HA.ParcelID = HB.ParcelID
	AND HA.[UniqueID ] <> HB.[UniqueID ]
WHERE HA.PropertyAddress IS NULL

UPDATE HA
SET PropertyAddress = ISNULL(HA.PropertyAddress, HB.PropertyAddress)
	FROM Housing AS HA
	JOIN Housing AS HB
		ON HA.ParcelID = HB.ParcelID
		AND HA.[UniqueID ] <> HB.[UniqueID ]
WHERE HA.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Housing 

SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress) -1 ) AS Address
, SUBSTRING( PropertyAddress, CHARINDEX( ',' , PropertyAddress) +1, LEN( PropertyAddress)) AS Address1
FROM Housing

ALTER TABLE Housing
ADD PropertySplitAddress NVarchar(255);

UPDATE Housing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress) -1 )

ALTER TABLE Housing
ADD PropertySplitCity NVarchar(255);

UPDATE Housing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX( ',' , PropertyAddress) +1, LEN( PropertyAddress))

SELECT *
FROM Housing

-- Another way of doing it 

SELECT OwnerAddress,
PARSENAME( REPLACE( OwnerAddress, ',' , '.'), 3),
PARSENAME( REPLACE( OwnerAddress, ',' , '.'), 2),
PARSENAME( REPLACE( OwnerAddress, ',' , '.'), 1)
FROM Housing

ALTER TABLE Housing
ADD OwnerSplitAddress NVarchar(255),
	OwnerSplitCity NVarchar(255),
	OwnerSplitState NVarchar(255)

UPDATE Housing
SET OwnerSplitAddress = PARSENAME( REPLACE( OwnerAddress, ',' , '.'), 3),
	OwnerSplitCity = PARSENAME( REPLACE( OwnerAddress, ',' , '.'), 2),
	OwnerSplitState = PARSENAME( REPLACE( OwnerAddress, ',' , '.'), 1)

SELECT * 
FROM Housing

-- Change Y and N to Yes and No in "Sold As Vacant" column

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM Housing

UPDATE Housing
SET SoldAsVacant = 	
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END


SELECT DISTINCT( SoldAsVacant )
FROM Housing

-- Delete unused Columns

SELECT * 
FROM Housing

ALTER TABLE  Housing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate



