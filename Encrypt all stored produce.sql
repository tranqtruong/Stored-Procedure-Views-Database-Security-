CREATE PROCEDURE SP_SEL_NO_ENCRYPT @TenCLB nvarchar(30), @TenQG nvarchar(30)
AS
SELECT MACT, HOTEN, VITRI, NGAYSINH, DIACHI
FROM CAUTHU
WHERE MACLB = (SELECT MACLB FROM CAULACBO WHERE TENCLB LIKE SUBSTRING(@TenCLB, 1, 3) + '%')
AND MAQG = (SELECT MAQG FROM QUOCGIA WHERE TENQG = @TenQG)
GO

CREATE PROCEDURE SP_SEL_ENCRYPT @TenCLB nvarchar(30), @TenQG nvarchar(30)
WITH ENCRYPTION AS
SELECT MACT, HOTEN, VITRI, NGAYSINH, DIACHI
FROM CAUTHU
WHERE MACLB = (SELECT MACLB FROM CAULACBO WHERE TENCLB LIKE SUBSTRING(@TenCLB, 1, 3) + '%') 
AND MAQG = (SELECT MAQG FROM QUOCGIA WHERE TENQG = @TenQG)
GO


EXEC SP_SEL_NO_ENCRYPT @TenCLB = 'SHB ĐÀ NẴNG', @TenQG = 'Brazil'
EXEC SP_SEL_ENCRYPT @TenCLB = 'SHB ĐÀ NẴNG', @TenQG = 'Brazil'

DROP PROCEDURE SP_SEL_ENCRYPT
DROP PROCEDURE SP_SEL_NO_ENCRYPT


sp_helptext SP_SEL_NO_ENCRYPT
sp_helptext SP_SEL_ENCRYPT


SELECT * FROM CAUTHU
SELECT * FROM QUOCGIA
SELECT * FROM CAULACBO

create view Temp as
SELECT ROW_NUMBER() OVER(ORDER BY name) AS ID, name
FROM QLBongDa.sys.procedures
go

--drop view Temp
--select * from Temp

declare @i int set @i = 1
declare @ProcName nvarchar(max)
declare @len int
set @len = (select count(*) from Temp)

while (@i <= @len) 
begin
	set @ProcName = (select name from Temp where ID = @i)
	
	-- chuyển result sp_helptext @ProcName thành string Val
	declare @Table table(
        Val varchar(MAX)
	)

	insert into @Table exec sp_helptext @ProcName

	declare @Val varchar(MAX)

	set @Val = ''

	-- Replaces line breaks and tab keystrokes.
	select  @Val = @Val + replace(replace(replace(Val, char(10), ' '), char(13), ' '), char(9), ' ')
	from    @Table

	delete from @Table
	
	if charindex('WITH ENCRYPTION', @Val) = 0 or charindex('with encryption', @Val) = 0
	begin
		set @Val = stuff(@Val, charindex('CREATE', @Val), len('CREATE'), 'ALTER')
		set @Val = stuff(@Val, charindex('AS', @Val), len('AS'), 'WITH ENCRYPTION AS')
		--print @Val
		
		--mã hóa stored produce
		declare @sql nvarchar(max)
		set @sql = @Val
		exec sp_executesql @statement = @sql
	end
	
	set @i = @i + 1
end


	




--



