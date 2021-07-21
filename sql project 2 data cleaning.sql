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
  FROM [project 2].[dbo].[Sheet1$]

  --Cleaning Data in SQL Queries

Select *
From dbo.Sheet1$

--- Standardize Date Format

select saledatecoverted, CONVERT(DATE,SALEDATE)
From dbo.Sheet1$


ALTER  TABLE dbo.Sheet1$
ADD SaleDateconverted  DATE;

UPDATE dbo.Sheet1$
set SaleDateconverted =  CONVERT(DATE,SALEDATE)

select saledatecoverted as saledateconverted
from dbo.Sheet1$

-- Populate Property Address data

Select *
From dbo.Sheet1$
--where propertyaddress is null
order by ParcelID

Select a.ParcelID ,a.PropertyAddress, b.ParcelID ,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.Sheet1$ a
JOIN DBO.Sheet1$ b
ON a.ParcelID = b.ParcelID
AND  a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
SET propertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.Sheet1$ a
JOIN DBO.Sheet1$ b
ON a.ParcelID = b.ParcelID
AND  a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From dbo.Sheet1$
--where propertyaddress is null
--order by ParcelID

Select 
substring(propertyaddress,1,CHARINDEX(',',Propertyaddress)-1) as address
,SUBSTRING (propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress)) as Address
from dbo.Sheet1$

ALTER  TABLE dbo.Sheet1$
ADD propertysplitaddress  NVARCHAR(255);

UPDATE dbo.Sheet1$
set propertysplitaddress = substring(propertyaddress,1,CHARINDEX(',',Propertyaddress)-1) 

ALTER  TABLE dbo.Sheet1$
ADD propertysplitcity  NVARCHAR(255);

UPDATE dbo.Sheet1$
set propertysplitcity = SUBSTRING (propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress)) 

select OwnerAddress
from dbo.Sheet1$

select
PARSENAME(REPLACE(owneraddress,',','.'),3)
,PARSENAME(REPLACE(owneraddress,',','.'),2)
,PARSENAME(REPLACE(owneraddress,',','.'),1)
from dbo.Sheet1$

ALTER  TABLE dbo.Sheet1$
ADD ownerssplitaddress NVARCHAR(255);

UPDATE dbo.Sheet1$
set ownerssplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER  TABLE dbo.Sheet1$
ADD ownerssplitcity  NVARCHAR(255);

UPDATE dbo.Sheet1$
set ownerssplitcity = PARSENAME(REPLACE(owneraddress,',','.'),2)


ALTER  TABLE dbo.Sheet1$
ADD ownerssplitstate  NVARCHAR(255);

UPDATE dbo.Sheet1$
set ownerssplitstate =PARSENAME(REPLACE(owneraddress,',','.'),1) 

select*
from dbo.Sheet1$

--- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant)
from dbo.Sheet1$

select distinct(soldasvacant),COUNT(soldasvacant)
from dbo.Sheet1$
group by soldasvacant
order by soldasvacant




select soldasvacant,
case when soldasvacant='N' then 'NO'
     when soldasvacant='Y' then 'NO'
	 Else soldasvacant
	 END
from dbo.Sheet1$

UPDATE dbo.Sheet1$
set soldasvacant =case when soldasvacant='N' then 'NO'
     when soldasvacant='Y' then 'NO'
	 Else soldasvacant
	 END

 --Remove Duplicates

 select*
 from dbo.Sheet1$

 WITH ROWNUMCTC AS (
 select*,
   ROW_NUMBER()over(
    partition by parcelID,
	             PropertyAddress,
				 saledate,
				 SalePrice,
				 LegalReference
				 ORDER BY
				 uniqueID
				 )Row_num

from dbo.sheet1$
--ORDER BY parcelID
)

--SELECT *
--FROM ROWNUMCTC
--where row_num>1
--order by propertyaddress

DELETE
FROM ROWNUMCTC
where row_num>1
--order by propertyaddress

-- Delete Unused Columns


SELECT*
from dbo.Sheet1$

ALTER TABLE dbo.Sheet1$
DROP COLUMN PropertyAddress,Saledate,ownerAddress,Taxdistrict,owmerssplitcity