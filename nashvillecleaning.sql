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
  FROM [Portfolio Project].[dbo].[NashvilleHousing]

  --Standardize Date format
  Select saleDate, convert(Date, saleDate) as SaleDate
  From [Portfolio Project].[dbo].[NashvilleHousing]

  Update NashvilleHousing
  set saleDate = convert(Date, saleDate)

 alter Table NashvilleHousing
 add SaleDateConverted Date;


Update NashvilleHousing
  set SaleDateConverted = convert(Date, saleDate)

select * from NashvilleHousing


--Populate Property Address
select * 
from NashvilleHousing
where PropertyAddress is null

--Use join to join the same table together to find which address are null as they are usually already in tab;e
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , isNull(a.propertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


--Breaking out address into different columns (Address, City, State) - USING SUBSTRINGS
Select PropertyAddress
From NashvilleHousing

Select substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) + 1, Len(PropertyAddress)) as Address
From NashvilleHousing

 alter Table NashvilleHousing
 add PropertySplitAddress nvarchar(100)


Update NashvilleHousing
  set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

 alter Table NashvilleHousing
 add PropertySplitCity nvarchar(100);


Update NashvilleHousing
  set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, Len(PropertyAddress))


Select OwnerAddress
from NashvilleHousing

select
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing



 alter Table NashvilleHousing
 add OwnerSplitAddress nvarchar(100)


Update NashvilleHousing
  set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

 alter Table NashvilleHousing
 add OwnerSplitCity nvarchar(100);


Update NashvilleHousing
  set OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

alter Table NashvilleHousing
add OwnerSplitState nvarchar(100);


Update NashvilleHousing
  set OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)


select * from NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant"
Select distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
END 
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
END

select



--Remove Duplicates
with RowNumCTE as (
Select *,
	Row_number() OVER (Partition By ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									Order by UniqueID) row_num
From NashvilleHousing
)
Select * 
from RowNumCTE
where row_num > 1


--Delete Unused Columns
select * from NashvilleHousing

Alter Table NashvilleHousing
drop column saledate