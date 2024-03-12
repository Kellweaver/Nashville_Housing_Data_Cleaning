
--- Cleaning Data in SSMS

select * from data_cleaning_project.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------

--- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate) from data_cleaning_project.dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

--- Alter Table NashvilleHousing
--- Add SaleDateConverted Date

----------------------------------------------------------------------------------------

---Populate Property Adddress Data


Select * from data_cleaning_project.dbo.NashvilleHousing
---Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From data_cleaning_project.dbo.NashvilleHousing a
Join data_cleaning_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From data_cleaning_project.dbo.NashvilleHousing a
Join data_cleaning_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]

----------------------------------------------------------------------------------------------

--- Breaking out Address into Individual Coulmns (Address, City, State)



Select PropertyAddress
From data_cleaning_project.dbo.NashvilleHousing
--- Where PropertyAddress is null
--- Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From data_cleaning_project.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select *
From data_cleaning_project.dbo.NashvilleHousing

Select OwnerAddress
From data_cleaning_project.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From data_cleaning_project.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From data_cleaning_project.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------

--- Change 1 and 0 to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From data_cleaning_project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


--- Select SoldAsVacant,
---Case When SoldAsVacant = '1' THEN 'Yes'
---	 When SoldAsVacant = '0' THEN 'No'
---	 Else SoldAsVacant
---	 End
---From data_cleaning_project.dbo.NashvilleHousing

SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 1 THEN 'Yes'
        WHEN SoldAsVacant = 0 THEN 'No'
        ELSE CONVERT(VARCHAR(MAX), SoldAsVacant)
    END
FROM 
    data_cleaning_project.dbo.NashvilleHousing;


	ALTER TABLE data_cleaning_project.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(3); -- Assuming you want to store 'Yes'/'No'

UPDATE data_cleaning_project.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
     WHEN SoldAsVacant = 1 THEN 'Yes'
     WHEN SoldAsVacant = 0 THEN 'No'
     ELSE CONVERT(VARCHAR(MAX), SoldAsVacant)
END;

------------------------------------------------------------------------------------------

--- Removing Duplicates

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

From data_cleaning_project.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From data_cleaning_project.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------

--- Deleting Unused Columns


Select *
From data_cleaning_project.dbo.NashvilleHousing

ALTER TABLE data_cleaning_project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate