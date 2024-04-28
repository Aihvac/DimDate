

--========================ساخت تابع تبدیل تاریخ میلادی به شمسی======
IF object_id(N'fn_MiladiShamsi', N'FN') IS NOT NULL
    DROP FUNCTION fn_MiladiShamsi
GO
CREATE FUNCTION  [dbo].[fn_MiladiShamsi](@DateMiladi As DATE) 
RETURNS NVARCHAR(10)
 AS  
BEGIN 
DECLARE @SalShamsi AS INT ,@MahShamsi AS INT ,@RoozShamsi AS INT 
,@SalMiladi AS INT ,@MahMiladi AS INT ,@DayMiladi AS INT 
,@SaleKabiseh AS INT ,@Sale2Kabiseh AS INT 
,@DayOne AS INT ,@MahOne AS INT
, @shMaah AS NVARCHAR(MAX),@shRooz AS NVARCHAR(MAX),@RooxSal AS INT
DECLARE @DayDate AS NVARCHAR(MAX)

SET @SalMiladi = DATEPART(yyyy, @DateMiladi)

IF @SalMiladi < 1000 SET @SalMiladi = @SalMiladi + 2000

SET @MahMiladi = MONTH(@DateMiladi)
SET @DayMiladi = DAY(@DateMiladi)
SET @SalShamsi = @SalMiladi - 622
SET @RooxSal = 5

IF ( ( @SalMiladi - 1992 ) % 4 = 0) SET @SaleKabiseh = 0 ELSE SET @SaleKabiseh = 1

IF ( ( @SalShamsi - 1371 ) % 4 = 0) SET @Sale2Kabiseh = 0 ELSE SET @Sale2Kabiseh = 1

SET @MahOne = 1
SET @DayOne = 1
SET @MahShamsi = 10
SET @RoozShamsi = 11

IF ( ( @SalMiladi - 1993 ) % 4 = 0 ) SET @RoozShamsi = 12


WHILE ( @MahOne != @MahMiladi ) OR ( @DayOne != @DayMiladi )
BEGIN

  SET @DayOne = @DayOne + 1
  SET @RooxSal = @RooxSal + 1

  IF 
  (@DayOne = 32 AND (@MahOne = 1 OR @MahOne = 3 OR @MahOne = 5 OR @MahOne = 7 OR @MahOne = 8 OR @MahOne = 10 OR @MahOne = 12))
  OR
  (@DayOne = 31 AND (@MahOne = 4 OR @MahOne = 6 OR @MahOne = 9 OR @MahOne = 11))
  OR
  (@DayOne = 30 AND @MahOne = 2 AND @SaleKabiseh = 1)
  OR
  (@DayOne = 29 AND @MahOne = 2 AND @SaleKabiseh = 0)
  BEGIN
    SET @MahOne = @MahOne + 1
    SET @DayOne = 1
  END

  IF @MahOne > 12
  BEGIN
    SET @SalMiladi = @SalMiladi + 1
    SET @MahOne = 1
  END

  IF @RooxSal > 7 SET @RooxSal = 1

 SET @RoozShamsi = @RoozShamsi + 1

  IF
  (@RoozShamsi = 32 AND @MahShamsi < 7)
  OR
  (@RoozShamsi = 31 AND @MahShamsi > 6 AND @MahShamsi < 12)
  OR
  (@RoozShamsi = 31 AND @MahShamsi = 12 AND @Sale2Kabiseh = 1)
  OR
  (@RoozShamsi = 30 AND @MahShamsi = 12 AND @Sale2Kabiseh = 0)
  BEGIN
    SET @MahShamsi = @MahShamsi + 1
    SET @RoozShamsi = 1
  END

  IF @MahShamsi > 12
  BEGIN
    SET @SalShamsi = @SalShamsi + 1
    SET @MahShamsi = 1
  END

END

Return REPLACE(RIGHT(STR(@SalShamsi, 4), 4), ' ', '0') 
  +'-' + REPLACE(STR(@MahShamsi, 2), ' ', '0')
  + '-' +REPLACE(( STR(@RoozShamsi,2) ), ' ', '0')
END


--==============ساخت جدول با سه ستون تاریخ میلادی و شمسی و شماره روز در هفته============================================
DROP TABLE IF Exists DimDate
CREATE TABLE DimDate (
	Autoid int IDENTITY(1,1) NOT NULL,
	DateMiladi DATE NOT NULL PRIMARY KEY,
	Tarikh NVARCHAR(10) Null ,
	DayInWeek INT  NULL,
);
WITH [range] AS (
    SELECT 0 as v
    UNION ALL
    SELECT v + 1
    FROM range t
    WHERE t.v < 100
)
INSERT INTO dbo.DimDate ( DateMiladi )
SELECT dateadd(day, v, '2018-01-01')  FROM [range]
  
--========آپدیت تاریخ شمسی و روز هفته در جدول =====================
UPDATE DimDate SET Tarikh = dbo.[fn_MiladiShamsi](DateMiladi) 
					, DayInWeek = DATEPART(WEEKDAY, DimDate.DateMiladi)

SELECT * From dbo.DimDate 
--===================================================================






