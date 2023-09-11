/*

Cleaning Data in SQL queries


*/
Select *
From housing.nashville
---------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- The date format is not suitable in SaleDate column, it is having time as well, so we need to clean it up because timestamp is not very important here, we just want dates only.

Select SaleDate, CONVERT(Date, SaleDate)
From housing.nashville

ALTER TABLE housing.nashville
ADD SaleDateConverted Date;

UPDATE housing.nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From housing.nashville

-- Done YaY!

---------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From housing.nashville
--Where PropertyAddress Is Null
Order by ParcelID

-- There are null values in PropertyAddress columns, so we need to fill them, we found that there was duplicacy in ParcelID column with one PropertyAddress have the complete address and the other PropertyAddress is blank. So we need to apply the self join on the table to fill the null values.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From housing.nashville as a
Join housing.nashville as b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From housing.nashville as a
Join housing.nashville as b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is Null

--Done YaY!

---------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

Select PropertyAddress
From housing.nashville

-- The PropertyAddress column contains a long address which is not suitable, we need to break that long address into relevant fields.

-- Method 1 for PropertyAddress
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From housing.nashville

ALTER TABLE housing.nashville
ADD PropertySplitAddress Nvarchar(255);

UPDATE housing.nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE housing.nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE housing.nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From housing.nashville

-- Method 2 for OwnerAddress

Select OwnerAddress
From housing.nashville

-- Easy method to break the string into different columns

Select PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From housing.nashville

ALTER TABLE housing.nashville
ADD OwnerSplitAddress Nvarchar(255);

UPDATE housing.nashville
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE housing.nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE housing.nashville
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE housing.nashville
ADD OwnerSplitState Nvarchar(255);

UPDATE housing.nashville
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From housing.nashville

--Done YaY!

---------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' Field

Select Distinct(SoldAsVacant)
From housing.nashville

-- Column SoldAsVacant contains some Y and N values too which we have to replace with Yes and No

Select SoldAsVacant,
      Case When SoldAsVacant = 'N' Then 'No' 
	  When SoldAsVacant = 'Y' Then 'Yes'
	  Else SoldAsVacant
	  End
From housing.nashville

Update housing.nashville
Set SoldAsVacant = Case When SoldAsVacant = 'N' Then 'No' 
	  When SoldAsVacant = 'Y' Then 'Yes'
	  Else SoldAsVacant
	  End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From housing.nashville
Group by SoldAsVacant

--Done YaY!

---------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RownumCTE As( 
		Select *, ROW_NUMBER() Over (
		Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		Order by UniqueID
		) row_num
		From housing.nashville)
	Select *
	From RownumCTE
	Where row_num > 1

-- We got the duplicate rows, now we have to delete them

With RownumCTE As( 
		Select *, ROW_NUMBER() Over (
		Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		Order by UniqueID
		) row_num
		From housing.nashville)
	Delete
	From RownumCTE
	Where row_num > 1

-- Done YaY!

---------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From housing.nashville

Alter Table housing.nashville
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table housing.nashville
Drop Column SaleDate

--Done YaY! Our Data is clean now, we can use it to find out various business insights using visualization techniques.