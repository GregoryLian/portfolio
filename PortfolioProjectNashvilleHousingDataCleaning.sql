/*
Cleaning Data in SQL Queries
*/

select *
from PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------

-- Standardize Sale Date format

/*select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)*/ -- did not work, instead will alter table and add in a new column SaleDateConverted

alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

select *
from PortfolioProject..NashvilleHousing 


--------------------------------------------------------------------------------------------------

-- Populate property address data

select*
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID 
-- realise that there are PropertyAddress that is null, however there are ParcelID that are similar in different rows, 
-- and the PropertyAddress is always the same, so we can populate the PropertyAddress with this logic


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
join PortfolioProject..NashvilleHousing b -- joining the table to itself based on the same ParcelID but different UniqueID
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
join PortfolioProject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID -- joining the table to itself based on the same ParcelID but different UniqueID
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------

-- Breaking PropertyAddress into individual columns (address, city)

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as address2
from PortfolioProject..NashvilleHousing  


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing 


--------------------------------------------------------------------------------------------------

-- Breaking OwnerAddress into individual columns (address, city, state)

select 
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1)

select *
from PortfolioProject..NashvilleHousing 


--------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldasVacant), count(SoldasVacant)
from PortfolioProject..NashvilleHousing 
group by SoldasVacant
order by 2

select SoldasVacant
, Case when SoldasVacant = 'Y' then 'Yes'
		when SoldasVacant = 'N' then 'No'
		else SoldasVacant
		end
from PortfolioProject..NashvilleHousing 

update NashvilleHousing 
set SoldasVacant = Case when SoldasVacant = 'Y' then 'Yes'
						when SoldasVacant = 'N' then 'No'
						else SoldasVacant
						end

select *
from PortfolioProject..NashvilleHousing 

select distinct(SoldasVacant), count(SoldasVacant)
from PortfolioProject..NashvilleHousing 
group by SoldasVacant


--------------------------------------------------------------------------------------------------

-- Remove duplicates

with RowNumCTE as (
select *, 
	row_number() over (
	partition by ParcelID, -- partition by these 5 columns to make sure they have unique values if not they will be
				PropertyAddress, -- credited as a duplicate column and will have row_num 2 assigned to them respectively
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
) row_num
from PortfolioProject..NashvilleHousing 
--order by ParcelID, this has to be removed in the creation of a CTE
)

select *
from RowNumCTE
where row_num > 1 -- these are the rows of duplicate entries that has row_num = 2 to be deleted
order by PropertyAddress

delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress


--------------------------------------------------------------------------------------------------

-- delete unused columns which we have converted previously

select *
from PortfolioProject..NashvilleHousing 

alter table PortfolioProject..NashvilleHousing 
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing 
drop column SaleDate