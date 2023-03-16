/*
Cleaning data using SQL Queries
*/

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

-----Standardizing Date format-----

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM ProjectPortfolio.dbo.NashvilleHousing


-----Populating Property Address data-----

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-----Breaking out PropertyAddress into individual columns(Address, City) USING SUBSTRING-----

SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Street
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS City
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(200);

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(200);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))


SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing



--Breaking out  OwnerAddress into individual columns(Address, City, State) USING PARSENAME----

SELECT OwnerAddress
FROM ProjectPortfolio.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitStreet Nvarchar(200);

UPDATE NashvilleHousing
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(200);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(200);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing


-----Changing Y and N to Yes and No in "Sold as Vacant" column-----

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldasVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END



-----Remove Duplicates-----
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY 
				 UniqueID
					) row_num
FROM ProjectPortfolio.dbo.NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num >1
--Order by PropertyAddress



SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing


-----Delete Unused Columns-----

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing


ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate