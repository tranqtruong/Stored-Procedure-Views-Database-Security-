/*
1. Cho biết mã số, họ tên, ngày sinh, địa chỉ và vị trí của các cầu thủ thuộc đội
bóng “SHB Đà Nẵng” có quốc tịch “Brazil”
*/
create view vCau1 as
select MACT, HOTEN, NGAYSINH, DIACHI, VITRI
from CAUTHU
where MACLB = 'SDN' and MAQG = 'BRA'
go

select * from vCau1


--2. Cho biết kết quả (MATRAN, NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) các trận đấu vòng 3 của mùa bóng năm 2009
create view CAULACBOAO as select * from CAULACBO go

create view vCau2 as
select MATRAN, NGAYTD, TENSAN, CAULACBO.TENCLB AS TENCLB1, CAULACBOAO.TENCLB AS TENCLB2,KETQUA
from (((TRANDAU 
inner join SANVD on TRANDAU.MASAN = SANVD.MASAN)
inner join CAULACBO on TRANDAU.MACLB1 = CAULACBO.MACLB)
inner join CAULACBOAO on TRANDAU.MACLB2 = CAULACBOAO.MACLB)
where TRANDAU.VONG = 3 and year(NGAYTD) = 2009
go

select * from vCau2


/*
3. Cho biết mã huấn luyện viên, họ tên, ngày sinh, địa chỉ, vai trò và tên CLB
đang làm việc của các huấn luyện viên có quốc tịch “Việt Nam”
*/
create view vCau3 as
select HUANLUYENVIEN.MAHLV, TENHLV, NGAYSINH, DIACHI, VAITRO, TENCLB
from HUANLUYENVIEN, HLV_CLB, CAULACBO
where HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV
and HLV_CLB.MACLB = CAULACBO.MACLB
and MAQG = 'VN'
go

select * from vCau3
drop view vCau3

/*
4. Cho biết mã câu lạc bộ, tên câu lạc bộ, tên sân vận động, địa chỉ và số lượng
cầu thủ nước ngoài (có quốc tịch khác “Việt Nam”) tương ứng của các câu lạc bộ
có nhiều hơn 2 cầu thủ nước ngoài
*/
create view vCau4 as
with Tamthoi (MCLB, SLCTNN) as
(
	select CAUTHU.MACLB, count(MAQG) as SOLUONG
	from CAUTHU
	where MAQG <> 'VN'
	group by CAUTHU.MACLB
	having count(MAQG) >= 2 
)
select MCLB, TENCLB, TENSAN, DIACHI, SLCTNN
from Tamthoi, CAULACBO, SANVD
where Tamthoi.MCLB = CAULACBO.MACLB
and CAULACBO.MASAN = SANVD.MASAN
go

select * from vCau4

/*
5. Cho biết tên tỉnh, số lượng cầu thủ đang thi đấu ở vị trí tiền đạo trong các câu lạc
bộ thuộc địa bàn tỉnh đó quản lý.
*/
create view vCau5 as
with Temp5 (MCLB, SLTD) 
as
(
	select MACLB, count(MACT)
	from CAUTHU
	where VITRI LIKE 'T%o'
	group by MACLB
)
select TENTINH, SLTD
from Temp5, TINH, CAULACBO
where Temp5.MCLB = CAULACBO.MACLB and CAULACBO.MATINH = TINH.MATINH
go

select * from vCau5
/*
6. Cho biết tên câu lạc bộ, tên tỉnh mà CLB đang đóng nằm ở vị trí cao nhất của
bảng xếp hạng của vòng 3, năm 2009.
*/
create view vCau6 as
select TENCLB, TENTINH
from BANGXH
inner join CAULACBO on CAULACBO.MACLB = BANGXH.MACLB
inner join TINH on TINH.MATINH = CAULACBO.MATINH
where HANG = 1 and VONG = 3 and NAM = 2009
go

select * from vCau6
/*
7. Cho biết tên huấn luyện viên đang nắm giữ một vị trí trong một câu lạc bộ mà
chưa có số điện thoại.
*/
create view vCau7 as
select TENHLV, DIENTHOAI
from HUANLUYENVIEN inner join HLV_CLB on HUANLUYENVIEN.MAHLV = HLV_CLB.MAHLV
where DIENTHOAI is null
go

select * from vCau7


/*
8. Liệt kê các huấn luyện viên thuộc quốc gia Việt Nam chưa làm công tác huấn
luyện tại bất kỳ một câu lạc bộ nào.
*/
create view vCau8 as
select *
from HUANLUYENVIEN
where MAQG = 'VN' and HUANLUYENVIEN.MAHLV not in (select HLV_CLB.MAHLV from HLV_CLB)
go


/*
9. Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) 
của câu lạc bộ CLB đang xếp hạng cao nhất tính đến hết vòng 3 năm 2009.
*/
-- view CAULACBOAO đã được tạo ở câu 2

create view vCau9 as
select  NGAYTD, TENSAN, CAULACBO.TENCLB as TENCLB1, CAULACBOAO.TENCLB as TENCLB2, KETQUA
from (((TRANDAU
join SANVD on TRANDAU.MASAN = SANVD.MASAN)
join CAULACBO on TRANDAU.MACLB1 = CAULACBO.MACLB)
join CAULACBOAO on TRANDAU.MACLB2 = CAULACBOAO.MACLB)
where VONG <= 3 and 
(
	MACLB1 in (select BANGXH.MACLB from BANGXH where BANGXH.VONG = 3 and BANGXH.HANG = 1)
	or
	MACLB2 in (select BANGXH.MACLB from BANGXH where BANGXH.VONG = 3 and BANGXH.HANG = 1)
)
go

select * from vCau9

/*
10.Cho biết danh sách các trận đấu (NGAYTD, TENSAN, TENCLB1, TENCLB2, KETQUA) 
của câu lạc bộ CLB có thứ hạng thấp nhất trong bảng xếp hạng vòng 3 năm 2009.
*/

create view vCau10 as
select  NGAYTD, TENSAN, CAULACBO.TENCLB as TENCLB1, CAULACBOAO.TENCLB as TENCLB2, KETQUA
from (((TRANDAU
join SANVD on TRANDAU.MASAN = SANVD.MASAN)
join CAULACBO on TRANDAU.MACLB1 = CAULACBO.MACLB)
join CAULACBOAO on TRANDAU.MACLB2 = CAULACBOAO.MACLB)
where VONG <= (select max(TRANDAU.VONG) from TRANDAU) and TRANDAU.NAM = 2009 and
(
	MACLB1 in (select BANGXH.MACLB from BANGXH where BANGXH.VONG = 3 and BANGXH.HANG = (select max(HANG) from BANGXH))
	or
	MACLB2 in (select BANGXH.MACLB from BANGXH where BANGXH.VONG = 3 and BANGXH.HANG = (select max(HANG) from BANGXH))
)
go

select * from vCau10


