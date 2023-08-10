
-- Checking The Data Imported
Select * 
From [Portfolio Project]..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------

-- Changing SaleDate into Standard Date Format
Select SaleDate
From [Portfolio Project]..NashvilleHousing

Select SaleDate, CONVERT(date, SaleDate) 
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add SaleDateConverted date;

Update [Portfolio Project]..NashvilleHousing
Set SaleDateConverted= CONVERT(date, SaleDate) 

Select SaleDateConverted
From [Portfolio Project]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------

-- Add Address Data where Missing
-- Populate PropertyAddress Data

Select *
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
, ISNULL(a.PropertyAddress,b.PropertyAddress) --ISNULL if 1st mentioned column has null value it gets replaced with 2nd one
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --not equal to
Where a.PropertyAddress is null


Update a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress) 
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --not equal to
Where a.PropertyAddress is null
--no null PropertyAddress now


----------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking PropertyAddress into 2 individual columns(address and city)

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing

-- Using Substring and Charindex
Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) 
, SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, Len(PropertyAddress)) 
From [Portfolio Project]..NashvilleHousing

--Updating this in table
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Check if columns are added
Select *
From [Portfolio Project]..NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Using Different approach 
-- Breaking OwnewrAddress into 3 parts- Address,City,State

Select OwnerAddress
From [Portfolio Project]..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Check if columns are updated
Select *
From  [Portfolio Project]..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "SoldAsVacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From  [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
From  [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	                    When SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	               END
-- Check if updated
Select SoldAsVacant
From  [Portfolio Project]..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing duplicate data
-- Using ROW_NUMBER() function
-- Creating CTE to perform operations on row_num
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project]..NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress

--Deleting These duplicates
DELETE 
From RowNumCTE
Where row_num >1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Deleting unused columns

Select *
From [Portfolio Project]..NashvilleHousing

Alter table [Portfolio Project]..NashvilleHousing
Drop COLUMN PropertyAddress, Saledate, OwnerAddress, TaxDistrict