/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [CleanDataProject].[dbo].[NashvilleHousing]



/*The Purpose of these queries is to practice cleaning data*/

SELECT *
FROM CleanDataProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------



/*Standardize Date Format*/
SELECT salesDateConverted, CONVERT(Date, SaleDate)
FROM CleanDataProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;

UPDATE NashvilleHousing
SET salesDateConverted = CONVERT(Date, SaleDate)




/*Populate Property Address Data*/
SELECT *
FROM CleanDataProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CleanDataProject.dbo.NashvilleHousing a
JOIN CleanDataProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CleanDataProject.dbo.NashvilleHousing a
JOIN CleanDataProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-----------------------------------------------------------------------

/*Breaking out Address into Individual Columns (Address, City, State)*/
SELECT PropertyAddress
FROM CleanDataProject.dbo.NashvilleHousing

--CHARINDEX -1 is what allows us to find the ',' and not include it in the query
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address

FROM CleanDataProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



SELECT *
FROM CleanDataProject.dbo.NashvilleHousing



SELECT OwnerAddress
FROM CleanDataProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM CleanDataProject.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------


/*Change Y and N to Yes and No in "Sold as Vacant" column*/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Total
FROM CleanDataProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM CleanDataProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM CleanDataProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------


/*Remove Duplicates*/

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM CleanDataProject.dbo.NashvilleHousing
)

--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
FROM CleanDataProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------

/*Delete Unused Columns*/



Select *
From CleanDataProject.dbo.NashvilleHousing


ALTER TABLE CleanDataProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate