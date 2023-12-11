/*
Clean data in SQL queries
*/

Select *
From PortfolioProject..NashvilleHousing

-- Standardize Date format

Select SaleDate
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
alter column SaleDate Date

-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by  ParcelID

Select a.[UniqueID ], b.[UniqueID ], a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
    On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--Order by a.[UniqueID ]

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
    On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))  as City
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1)

Alter table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as State
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Alter table NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select *
From PortfolioProject..NashvilleHousing


-- Change Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant =  'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing
--Where SoldAsVacant IN ('Y', 'N')

Update NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant =  'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- Remove duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num >  1
--Order by ParcelID


-- Delete unused columns

Select *
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict
