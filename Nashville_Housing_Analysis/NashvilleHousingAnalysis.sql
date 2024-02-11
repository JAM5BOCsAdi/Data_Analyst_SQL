--USE NashvilleHousingAnalysis
--GO

SELECT *
FROM NashvilleHousingAnalysis..NashvilleHousing 
ORDER BY [UniqueID ];

-- Running Summarization Description:
-- https://codingsight.com/calculating-running-total-with-over-clause-and-partition-by-clause-in-sql-server/
-- SUM(SalePrice): This is what you want to summarize, and create the running calculation
-- OVER (ORDER BY UniqueID): You order the data based on the UniqueID, and based on this order (UniqueID),
-- it calculates the running summarization
-- And these 2 are creating a new column, that is named with the AS running_sale_price
SELECT 
	[UniqueID ], ParcelID, LandUse, PropertyAddress, SalePrice,
	SUM(SalePrice) OVER (ORDER BY UniqueID) AS running_sale_price	
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- PARTITION BY:
-- OVER (PARTITION BY LandUse ORDER BY UniqueID):
-- It partitions by the UniqueIDs, and that is how the running summarization
-- starts again from every partition.
-- Rest is the same as above, the SUM(SalePrice) decides which column you want to summarize
-- to create a new one.
-- In the ORDER BY, you should give one of the same columns that are in the SELECT
-- It adds up like this (diagonally = átlósan):
-- SalePrice    running_sale_price
--   2000000 ->  2000000 (adds this)
--			  + 
--   2000000 (to this) ->  4000000 (result)
--   140000  ->   140000 (adds this)
--			  +
--   50000 (to this)   ->   190000 (result) (adds this)
--						+
--   125000 (to this)  ->   315000 (result) (adds this)
--						+
--   400000 (to this)  ->	715000 (result) (adds this)
--						+
--   2000000 (to this) ->	2715000 (result) (adds this)
--						+
--   ....
SELECT 
	[UniqueID ], ParcelID, LandUse, PropertyAddress, SalePrice,
	SUM(SalePrice) OVER (PARTITION BY LandUse ORDER BY UniqueID) AS running_sale_price	
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- Same happens here, adds up diagonally (átlósan), and the result is in the "running_sale_price"
-- column in each line.
-- And it is ORDERED BY UniqueID, so it is more nicer to show from 0 to end
SELECT 
	[UniqueID ], ParcelID, LandUse, PropertyAddress, SalePrice,
	SUM(SalePrice) OVER (PARTITION BY LandUse ORDER BY UniqueID) AS running_sale_price	
FROM NashvilleHousingAnalysis..NashvilleHousing
ORDER BY [UniqueID ];

-- ***************************************** 
-- Actually starts here | Standardize Date Format
-- *****************************************

-- Standardize Date Format
SELECT SaleDate, CONVERT(date, SaleDate) AS SaleDateShort
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- ********** Possible problem: **********
-- @t.d.2016
-- 9 months ago
-- 9:05 Not sure if this has been pointed out, but the reason the SaleDate column didn't 
-- "update" here is because UPDATE does not change data types. 
-- The table is actually updating, but the data type for the column SaleDate is still datetime.
-- To change data type, one has to use 
-- ``` ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE ```
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);

-- ALTER TABLE: It says, I want to modify the NashvilleHousing DB,
-- and ADD a new column (SaleDateConverted) that's type is date
ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT SaleDate, SaleDateConverted, CONVERT(date, SaleDate) AS SaleDateShort
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- ***************************************** 
-- Populate Property Address Data 
-- *****************************************
SELECT *
FROM NashvilleHousingAnalysis..NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT *
FROM NashvilleHousingAnalysis..NashvilleHousing
ORDER BY ParcelID;

-- If there is more repetitive data in the ParcelID, 
-- but say the address is missing in the PropertyAddress, 
-- then enter that address as an auto-mat, modify that line.
-- So it should be the same address.
SELECT 
	a.ParcelID AS aParcelID, a.PropertyAddress AS aPropertyAddress, 
	b.ParcelID AS bParcelID, b.PropertyAddress AS bPropertyAddress
FROM NashvilleHousingAnalysis..NashvilleHousing a
JOIN NashvilleHousingAnalysis..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- [isNullPorpertyAddress] column is going to be put in to [aPropertyAddress]
-- WHERE the [aPropertyAddress] is NULL
SELECT 
	a.ParcelID AS aParcelID, a.PropertyAddress AS aPropertyAddress, 
	b.ParcelID AS bParcelID, b.PropertyAddress AS bPropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) AS isNullPropertyAddress
FROM NashvilleHousingAnalysis..NashvilleHousing a
JOIN NashvilleHousingAnalysis..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingAnalysis..NashvilleHousing a
JOIN NashvilleHousingAnalysis..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Now, if you check the above one again, it should be no data init, because there is no
-- more NULL values in [aPropertyAddress]
-- ISNULL(checking_value, put_new_value_in_checking_value)
SELECT 
	a.ParcelID AS aParcelID, a.PropertyAddress AS aPropertyAddress, 
	b.ParcelID AS bParcelID, b.PropertyAddress AS bPropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) AS isNullPropertyAddress
FROM NashvilleHousingAnalysis..NashvilleHousing a
JOIN NashvilleHousingAnalysis..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- *****************************************
-- Breaking out Adress into Individual Columns (Address, City, State)
-- *****************************************
-- DELIMITER: Separates diferent columns/values, like "comma" [,] in a line of text
SELECT PropertyAddress
FROM NashvilleHousingAnalysis..NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
FROM NashvilleHousingAnalysis..NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address,
	CHARINDEX(',', PropertyAddress) AS CommaPosition
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- Get rid of 'comma' [,]:
-- There is a CommaPosition, that is a number. And If we do not need that to display,
-- we can say '-1' position before comma.
-- It is there, but not shown.
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM NashvilleHousingAnalysis..NashvilleHousing;


-- '+1' because you do not need comma before 'NASHVILLE' (Address2)
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address2
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- Create new columns for separate State, City, ...
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

-- Now the 2 columns are at the back of the DB as PropertySplitAddress and PropertySplitCity
SELECT *
FROM NashvilleHousingAnalysis..NashvilleHousing;





-- Simpler way of doing this on [OwnerAddress]
SELECT OwnerAddress
FROM NashvilleHousingAnalysis..NashvilleHousing;

SELECT 
	PARSENAME(OwnerAddress, 1) AS NothingChanged
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- It is only useful with periods like "comma" [,]:
-- It separates from the back, so in the next we will change it.
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS SeparatesBackward
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- Change it to be good:
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- Create new columns for separate State, City, ...
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT *
FROM NashvilleHousingAnalysis..NashvilleHousing;


-- *****************************************
-- Change Y and N to Yes and No in [Sold as Vacant] column
-- *****************************************
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS SoldAsVacantCount
FROM NashvilleHousingAnalysis..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacantCount;

-- Changing the 'Y's and 'N's to 'Yes' and 'No'
SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousingAnalysis..NashvilleHousing;

-- Update the [SoldAsVacant] column
UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
;

-- Check if there is 'Y' or 'N'
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS SoldAsVacantCount
FROM NashvilleHousingAnalysis..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacantCount;


-- *****************************************
-- Remove DUPLICATES
-- *****************************************
-- !!!!!! THIS IS NOT A STANDARD PRACTICE TO DELETE DATA FROM DATABASE
-- USUALLY DO NOT DO THIS IRL!!!!!!
-- Keep the DB as it was/is, and do not change the base
WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			ORDER BY 
				UniqueID					
		) AS row_num
	FROM NashvilleHousingAnalysis..NashvilleHousing
	-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Actually delete the above duplicates in [RowNumCTE2]
-- and if you run [RowNumCTE] again, you can see there is no duplicates
WITH RowNumCTE2 AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			ORDER BY 
				UniqueID					
		) AS row_num
	FROM NashvilleHousingAnalysis..NashvilleHousing
	-- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE2
WHERE row_num > 1;
-- ORDER BY PropertyAddress;

SELECT *
FROM NashvilleHousingAnalysis..NashvilleHousing;


-- *****************************************
-- Delete unused columns
-- *****************************************
-- !!!!!! THIS IS NOT A STANDARD PRACTICE TO DELETE DATA FROM DATABASE
-- USUALLY DO NOT DO THIS IRL!!!!!!
-- Keep the DB as it was/is, and do not change the base
SELECT *
FROM NashvilleHousingAnalysis..NashvilleHousing;

ALTER TABLE NashvilleHousingAnalysis..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousingAnalysis..NashvilleHousing
DROP COLUMN SaleDate;




