Select *
From PortfolioProject.dbo.[Nashville-Housing-Price]

--Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate) 
From PortfolioProject.dbo.[Nashville-Housing-Price]


Update [Nashville-Housing-Price]
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE	[Nashville-Housing-Price]
Add SaleDateConverted Date;

Update [Nashville-Housing-Price]
Set SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data

Select *
From PortfolioProject.dbo.[Nashville-Housing-Price]
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville-Housing-Price] a
JOIN PortfolioProject.dbo.[Nashville-Housing-Price] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville-Housing-Price] a
JOIN PortfolioProject.dbo.[Nashville-Housing-Price] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.[Nashville-Housing-Price]
--Where PropertyAddress is null
--order by ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.[Nashville-Housing-Price]

ALTER TABLE	[Nashville-Housing-Price]
Add PropertySplitAddress NVARCHAR(255);

Update [Nashville-Housing-Price]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE	[Nashville-Housing-Price]
Add PropertySplitCity NVARCHAR(255);

Update [Nashville-Housing-Price]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.[Nashville-Housing-Price]


Select OwnerAddress
From PortfolioProject.dbo.[Nashville-Housing-Price]


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.[Nashville-Housing-Price]

ALTER TABLE	[Nashville-Housing-Price]
Add OwnerSplitAddress NVARCHAR(255);

Update [Nashville-Housing-Price]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE	[Nashville-Housing-Price]
Add OwnerSplitCity NVARCHAR(255);

Update [Nashville-Housing-Price]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE	[Nashville-Housing-Price]
Add OwnerSplitState NVARCHAR(255);

Update [Nashville-Housing-Price]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.[Nashville-Housing-Price]

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.[Nashville-Housing-Price]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'YES'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end
From PortfolioProject.dbo.[Nashville-Housing-Price]

Update [Nashville-Housing-Price]
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'YES'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end


--Remove Duplicates

WITH RowNumCTE as(
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

From PortfolioProject.dbo.[Nashville-Housing-Price]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unused Columns

Select *
From PortfolioProject.dbo.[Nashville-Housing-Price]

ALTER TABLE PortfolioProject.dbo.[Nashville-Housing-Price]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.[Nashville-Housing-Price]
DROP COLUMN SaleDate