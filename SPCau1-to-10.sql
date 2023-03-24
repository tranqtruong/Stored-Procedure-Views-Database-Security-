/*
1. Cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí của các cầu thủ thuộc đội
bóng “SHB Đà Nẵng” có quốc tịch “Brazil”
*/
CREATE PROC SPCau1 @TenCLB NVARCHAR(50), @TenQG NVARCHAR(50)
AS
SELECT MACT, HOTEN, NGAYSINH, DIACHI, VITRI
FROM CAUTHU, CAULACBO, QUOCGIA
WHERE CAUTHU.MACLB = CAULACBO.MACLB AND CAUTHU.MAQG = QUOCGIA.MAQG
	AND TENCLB = @TenCLB AND TENQG = @TenQG
GO
EXEC SPCau1 @TENCLB = N'SHB ĐÀ NẴNG', @TENQG = N'Bra-xin'

--2. Cho biết kết quả (MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) các trận đấu vòng 3 của mùa bóng năm 2009
CREATE PROC SPCau2 @Round INT, @Year INT
AS
SELECT MATRAN, NGAYTD, TENSAN, CAULACBO.TENCLB AS TENCLB1, CAULACBOAO.TENCLB AS TENCLB2,KETQUA
FROM (((TRANDAU 
inner join SANVD on TRANDAU.MASAN = SANVD.MASAN)
inner join CAULACBO on TRANDAU.MACLB1 = CAULACBO.MACLB)
inner join CAULACBOAO on TRANDAU.MACLB2 = CAULACBOAO.MACLB)
WHERE TRANDAU.VONG = @Round and year(NGAYTD) = @Year
GO
EXEC SPCau2 3, 2009

/*
3. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, vai trò và tên CLB
đang làm việc của các huấn luyện viên có quốc tịch “Việt Nam”
*/
CREATE PROC SPCau3 @QuocGia NVARCHAR(30)
AS
SELECT HUANLUYENVIEN.MAHLV, TENHLV, NGAYSINH, DIACHI, VAITRO, TENCLB
FROM HUANLUYENVIEN, HLV_CLB, CAULACBO, QUOCGIA
WHERE HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV
and HLV_CLB.MACLB = CAULACBO.MACLB
AND HUANLUYENVIEN.MAQG = QUOCGIA.MAQG
and TENQG = @QuocGia
GO
EXEC SPCau3 @QuocGia = N'Việt Nam'

/*
4. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ và số lượng
cầu thủ nước ngoài (có quốc tịch khác “Việt Nam”) tương ứng của các câu lạc bộ
có nhiều hơn 2 cầu thủ nước ngoài
*/
CREATE PROC SPCau4 @QuocGia2 NVARCHAR(30)
AS
with Tamthoi (MCLB, SLCTNN) as
(
	SELECT CAUTHU.MACLB, count(QUOCGIA.MAQG) as SOLUONG
	FROM CAUTHU, QUOCGIA
	WHERE TENQG <> @QuocGia2 AND CAUTHU.MAQG = QUOCGIA.MAQG
	GROUP BY CAUTHU.MACLB
	having count(QUOCGIA.MAQG) >= 2 
)
SELECT MCLB, TENCLB, TENSAN, DIACHI, SLCTNN
FROM Tamthoi, CAULACBO, SANVD
WHERE Tamthoi.MCLB = CAULACBO.MACLB
and CAULACBO.MASAN = SANVD.MASAN
GO
EXEC SPCau4 @QuocGia2 = N'Việt Nam'

/*
5. Cho biết tên tỉnh, số lượng cầu thủ đang thi đấu ở vị trí tiền đạo trong các câu lạc
bộ thuộc địa bàn tỉnh đó quản lý.
*/
CREATE PROC SPCau5 @vitri NVARCHAR(30)
AS
with Temp5 (MCLB, SLTD) 
as
(
	SELECT MACLB, count(MACT)
	FROM CAUTHU
	WHERE VITRI = @vitri
	GROUP BY MACLB
)
SELECT TENTINH, SLTD
FROM Temp5, TINH, CAULACBO
WHERE Temp5.MCLB = CAULACBO.MACLB and CAULACBO.MATINH = TINH.MATINH
GO

EXEC SPCau5 @VITRI = N'Tiền Đạo'

/*
6. Cho biết tên câu lạc bộ, tên tỉnh mà CLB đang đóng nằm ở vị trí cao nhất của
bảng xếp hạng của vòng 3, năm 2009.
*/
CREATE PROC SPCau6 @Rank INT, @Round INT, @Year INT
AS
SELECT TENCLB, TENTINH
FROM BANGXH
inner join CAULACBO on CAULACBO.MACLB = BANGXH.MACLB
inner join TINH on TINH.MATINH = CAULACBO.MATINH
WHERE HANG = @Rank and VONG = @Round and NAM = @Year
GO

EXEC SPCau6 @Rank = 1, @Round = 3, @Year = 2009

/*
7. Cho biết tên huấn luyện viên đang nắm giữ một vị trí trong một câu lạc bộ mà
chưa có số điện thoại.
*/
CREATE PROC SPCau7
AS
SELECT TENHLV, DIENTHOAI
FROM HUANLUYENVIEN inner join HLV_CLB on HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV
WHERE DIENTHOAI is null
GO

EXEC SPCau7

/*
8. Liệt kê các huấn luyện viên thuộc quốc gia Việt Nam chưa làm công tác huấn
luyện tại bất kỳ một câu lạc bộ nào.
*/
CREATE PROC SPCau8 @Quocgia VARCHAR(30)
AS
SELECT TENHLV
FROM HUANLUYENVIEN, QUOCGIA
WHERE TENQG = @Quocgia AND HUANLUYENVIEN.MAQG = QUOCGIA.MAQG
and HUANLUYENVIEN.MAHLV not in (SELECT HLV_CLB.MAHLV FROM HLV_CLB)
GO
EXEC SPCau8 N'Việt Nam'

/*
9. Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) 
của câu lạc bộ CLB đang xếp hạng cao nhất tính đến hết vòng 3 năm 2009.
*/
CREATE PROC SPCau9 @Round INT, @Year INT
AS
SELECT  NGAYTD, TENSAN, CAULACBO.TENCLB as TENCLB1, CAULACBOAO.TENCLB as TENCLB2, KETQUA
FROM (((TRANDAU
join SANVD on TRANDAU.MASAN = SANVD.MASAN)
join CAULACBO on TRANDAU.MACLB1 = CAULACBO.MACLB)
join CAULACBOAO on TRANDAU.MACLB2 = CAULACBOAO.MACLB)
WHERE VONG <= @Round and TRANDAU.NAM = @Year and
(
	MACLB1 in (SELECT BANGXH.MACLB FROM BANGXH WHERE BANGXH.VONG = 3 and BANGXH.HANG = 1)
	or
	MACLB2 in (SELECT BANGXH.MACLB FROM BANGXH WHERE BANGXH.VONG = 3 and BANGXH.HANG = 1)
)
GO

EXEC SPCau9 @Round = 3, @Year = 2009

/*
10.Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) 
của câu lạc bộ CLB có thứ hạng thấp nhất trong bảng xếp hạng vòng 3 năm 2009.
*/
CREATE PROC SPCau10 @Round INT, @Year INT
AS
SELECT  NGAYTD, TENSAN, CAULACBO.TENCLB as TENCLB1, CAULACBOAO.TENCLB as TENCLB2, KETQUA
FROM (((TRANDAU
join SANVD on TRANDAU.MASAN = SANVD.MASAN)
join CAULACBO on TRANDAU.MACLB1 = CAULACBO.MACLB)
join CAULACBOAO on TRANDAU.MACLB2 = CAULACBOAO.MACLB)
WHERE VONG <= @Round and TRANDAU.NAM = @Year and
(
	MACLB1 in (SELECT BANGXH.MACLB FROM BANGXH WHERE BANGXH.VONG = 3 and BANGXH.HANG = (SELECT max(HANG) FROM BANGXH))
	or
	MACLB2 in (SELECT BANGXH.MACLB FROM BANGXH WHERE BANGXH.VONG = 3 and BANGXH.HANG = (SELECT max(HANG) FROM BANGXH))
)
GO

EXEC SPCau10 @Round = 3, @Year = 2009



