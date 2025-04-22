create database Nhom11_QuanLyBanHang
go
use Nhom11_QuanLyBanHang
go

create table DonViNhap
(
    MaDVN char(6) not null,
    TenDVN varchar(150) not null,
    STK varchar(15) null,
    SDT char(10) not null, 
    DiachiNH varchar(150) not null,
    primary key (MaDVN)
)

create table NguoiMuaHang
(
    MaNMH char(6) not null,
    TenNMH varchar(150) not null,
    STK varchar(15) null,
    DiaChi varchar(150) not null,
    primary key (MaNMH)
)

create table HangHoa
(
    MaHH char(6) not null,
    DVT varchar(150) not null,
    TenHH varchar(150) not null,
    SL_HH int not null,
    primary key (MaHH)
)

create table GiaNhapHH
(
    MaGiaNhap char(6) not null,
    MaHH char(6) not null,
    GiaNhap numeric(15, 2) not null,
    NgayNhap date not null,
    primary key(MaGiaNhap),
    foreign key (MaHH) references HangHoa (MaHH)
)

create table GiaBanHH
(
    MaGiaBan    char(6) not null,
    MaHH        char(6) not null,
    GiaBan      Numeric(15, 2) not null,
    NgayBan     date not null,
    primary key(MaGiaBan),
    foreign key (MaHH) references HangHoa (MaHH)
)

create table Nhap
(
    MaNH            char(6) not null,
    ThoiGianNH      date not null,        
	ThanhTien	    numeric(15, 2) not null,
    ThueSuat        float not null,
    TongTienThue    numeric(15, 2) not null,
    TongTienHang    numeric(15, 2) not null,    
    TienThue        numeric(15, 2)  not null,
    TongTien        numeric(15, 2) not null,    
    MaDVN           char(6) not null,               
    primary key(MaNH),
    foreign key(MaDVN) references DonViNhap(MaDVN)
)

create table NhapChiTiet
(
	MaNH		char(6) not null,
	MaHH		char(6) not null,
	SL			int not null,
	ThanhTien	numeric(15, 2) not null,
	primary key(MaNH, MaHH),
	foreign key(MaNH) references Nhap(MaNH),
	foreign key(MaHH) references HangHoa(MaHH)
)

create table BAN
(
	MaBH			char(6) not null,
	MaNMH			char(6) not null,		
	ThoiGianBH		date not null,	
	ThanhTien		numeric(15, 2) not null,
	ThueSuat		float not null,	
	TienThue		numeric(15, 2) not null,	
	TongTienHang	numeric(15, 2) not null,
	TongTien		numeric(15, 2) not null,	
	primary key(MaBH),
	foreign key(MaNMH) references NguoiMuaHang(MaNMH)
)

create table BAN_CHI_TIET
(
	MaBH		char(6)		not null,
	MaHH		char(6)		not null,
	SL			int			not null,
	ThanhTien	numeric(15, 2)	not null,
	primary key(MaBH, MaHH),
	foreign key(MaBH) references Ban(MaBH),
	foreign key(MaHH) references HangHoa(MaHH)
)



use Nhom11_QuanLyBanHang
-- 1. Thủ tục thêm DonViNhap mới
go
create or alter proc sp_DonViNhap
as
begin
	declare @i int = 1
	declare @MaDVN char(7)
	declare @TenDVN varchar(150)
	declare @STK varchar(15)
	declare @SDT char(10)
	declare @DiachiNH varchar(150)

	while @i <= 1000
	begin
		-- Tạo giá trị động cho các trường
		set @MaDVN = 'DVN' + RIGHT('000' + CAST(@i as varchar(4)), 4)
		set @TenDVN = 'Don Vi Nhap ' + CAST(@i as varchar(3))
		set @STK = case when @i % 2 = 0 then '123456789' + CAST(@i as varchar(6)) else NULL end -- STK chỉ có giá trị với dòng chẵn
		set @SDT = '012345' + RIGHT('000' + CAST(@i as varchar(4)), 4) -- Tạo SDT động
		set @DiachiNH = 'Dia chi ' + CAST(@i as varchar(3)) + ', City'

		-- Chèn dữ liệu vào bảng
		insert into DonViNhap (MaDVN, TenDVN, STK, SDT, DiachiNH)
		values (@MaDVN, @TenDVN, @STK, @SDT, @DiachiNH)

		-- Tăng biến đếm
		set @i = @i + 1
	end
end
exec sp_DonViNhap
Select * from DonViNhap


-- 2. Thủ tục thêm khách hàng mới
go
create or alter proc sp_KhachHang
as
begin
	declare @i int = 1
	declare @MaNMH char(6)
	declare @TenNMH varchar(150)
	declare @STK varchar(15)
	declare @DiaChi varchar(150)

	while @i <= 1000
	begin
		-- Tạo giá trị động cho các trường
			set @MaNMH = 'NMH' + RIGHT('000' + CAST(@i as varchar(3)), 3) -- Mã người mua hàng từ 'NMH001' đến 'NMH1000'
			set @TenNMH = 'Khach Hang ' + CAST(@i as varchar(3)) -- Tên người mua hàng
			set @STK = case when @i % 2 = 0 then '123456789' + CAST(@i as varchar(6)) else NULL end -- STK chỉ có giá trị với dòng chẵn
			set @DiaChi = 'Dia Chi ' + CAST(@i as varchar(3))-- Địa chỉ giả lập

			-- Chèn dữ liệu vào bảng NguoiMuaHang
			insert into NguoiMuaHang (MaNMH, TenNMH, STK, DiaChi)
			values (@MaNMH, @TenNMH, @STK, @DiaChi)

			-- Tăng biến đếm
			set @i = @i + 1
	end
end
exec sp_KhachHang
Select * from NguoiMuaHang

-- 3. Thủ tục thêm hàng hóa mới
go
create or alter proc sp_HangHoa
as
begin
	declare @i int = 1
	declare @maHH char(6)
	declare @DVT varchar(150)
	declare @TenHH varchar(150)
	declare @SL_HH int

	while @i <= 1000
	begin
		-- Tạo giá trị động cho các trường
		set @maHH = 'HH' + RIGHT('000' + CAST(@i as varchar(4)), 4)
		set @DVT = case when @i % 2 = 0 then 'Hop' else 'Thung' end
		set @TenHH = 'SanPham ' + CAST(@i as varchar(3))
		set @SL_HH = (50 + @i % 50)         -- Số lượng tăng dần từ 50

		-- Chèn dữ liệu vào bảng
		insert into HangHoa (MaHH, DVT, TenHH, SL_HH)
		values (@maHH, @DVT, @TenHH, @SL_HH)

		-- Tăng biến đếm
		set @i = @i + 1
	end
end
exec sp_HangHoa
Select * from HangHoa



-- 4. Thủ tục thêm thông tin vào nhập hàng
go
create or alter proc sp_NhapHang
as
begin
	declare @i int = 1
	declare @MaNH char(6)
	declare @ThoiGianNH date
	declare @ThanhTien numeric(15,2)
	declare @ThueSuat float
	declare @TongTienThue numeric(15, 2)
	declare @TongTienHang numeric(15, 2)
	declare @TienThue numeric(15, 2)
	declare @TongTien numeric(15, 2)
	declare @MaDVN char(7)

	while @i <= 1000
	begin
		-- Tạo giá trị động cho các trường
		set @MaNH = 'NH' + RIGHT('000' + CAST(@i as varchar(4)), 4)
		set @ThoiGianNH = DATEADD(DAY, @i, '2020-01-01') -- Thời gian động bắt đầu từ ngày 2023-01-01
		set @ThanhTien = 10000 + (@i * 5) -- Tạo giá trị thanh tiền từ 10,000 và tăng dần
		set @ThueSuat = 0.1 + (@i % 5) * 0.01 -- Thuế suất thay đổi từ 10% đến 14%
		set @TongTienHang = 10000 + (@i * 100) -- Tổng tiền hàng tăng dần
		set @TienThue = @TongTienHang * @ThueSuat -- Tiền thuế được tính dựa trên tổng tiền hàng và thuế suất
		set @TongTienThue = @TongTienHang + @TienThue
		set @TongTien = @TongTienThue -- Tổng tiền là tổng của tiền hàng và tiền thuế
		set @MaDVN = 'DVN' + RIGHT('000' + CAST((@i % 10) + 1 as varchar(4)), 4) -- Mã đơn vị nhập được tạo động, từ DVN001 đến DVN010

		-- Chèn dữ liệu vào bảng
		insert into Nhap (MaNH, ThoiGianNH, ThanhTien, ThueSuat, TienThue, TongTienHang, TongTienThue, TongTien, MaDVN)
		values (@MaNH, @ThoiGianNH, @ThanhTien, @ThueSuat, @TienThue, @TongTienHang, @TongTienThue, @TongTien, @MaDVN)

		-- Tăng biến đếm
		set @i = @i + 1
	end
end
exec sp_NhapHang
Select * from Nhap


-- 5. Thủ tục thêm chi tiết đơn nhập hàng
go
create or alter proc sp_NhapChiTiet
as
begin
	declare @i int = 1
	declare @MaNH char(6)
	declare @MaHH char(6)
	declare @SL int
	declare @ThanhTien numeric(15)

	while @i <= 1000
	begin
		-- Tạo giá trị động cho các trường
		set @MaNH = 'NH' + RIGHT('000' + CAST((@i % 1000) + 1 as varchar(4)), 4) -- Sử dụng 1000 mã nhập từ 'NH001' đến 'NH01000'
		set @MaHH = 'HH' + RIGHT('000' + CAST((@i % 20) + 1 as varchar(4)), 4) -- Sử dụng 20 mã hàng hóa từ 'HH001' đến 'HH020'
		set @SL = 10 + (@i % 5) * 2 -- Số lượng ngẫu nhiên từ 10, 12, 14,...
		set @ThanhTien = @SL * (1000 + @i) -- Thành tiền được tính dựa trên số lượng và đơn giá (1000 + @i)

		-- Chèn dữ liệu vào bảng
		insert into NhapChiTiet(MaNH, MaHH, SL, ThanhTien)
		values (@MaNH, @MaHH, @SL, @ThanhTien)

		-- Tăng biến đếm
		set @i = @i + 1
	end
end
exec sp_NhapChiTiet
Select * from NhapChiTiet


-- 6. Thủ tục thêm thông tin bán hàng mới
go
create or alter proc sp_ThongTinBanHang
as
begin
	declare @i int = 1
	declare @MaBH char(6)
	declare @MaNMH char(6)
	declare @ThoiGianBH date
	declare @ThanhTien numeric(15, 2)
	declare @ThueSuat float
	declare @TienThue numeric(15, 2)
	declare @TongTienHang numeric(15, 2)
	declare @TongTien numeric(15, 2)

	while @i <= 1000
	begin
		-- Tạo giá trị động cho các trường
		set @MaBH = 'BH' + RIGHT('000' + CAST(@i as varchar(4)), 4) -- Mã bán hàng 'BH001' đến 'BH1000'
		set @MaNMH = 'NMH' + RIGHT('000' + CAST((@i % 10) + 1 as varchar(3)), 3) -- Mã người mua hàng từ 'NMH001' đến 'NMH010'
		set @ThoiGianBH = DATEADD(DAY, @i, '2020-01-01') -- Tạo ngày bán hàng từ 2020-01-01 trở đi
		set @ThanhTien = 10000 + (@i * 5) -- Tạo giá trị thanh tiền từ 10,000 và tăng dần
		set @ThueSuat = 0.1 -- Thuế suất cố định 10%
		set @TienThue = @ThanhTien * @ThueSuat -- Tiền thuế dựa trên ThanhTien và ThueSuat
		set @TongTienHang = @ThanhTien -- Tổng tiền hàng bằng ThanhTien
		set @TongTien = @TongTienHang + @TienThue -- Tổng tiền bao gồm thuế

		-- Chèn dữ liệu vào bảng BAN
		insert into BAN (MaBH, MaNMH, ThoiGianBH, ThanhTien, ThueSuat, TienThue, TongTienHang, TongTien)
		values (@MaBH, @MaNMH, @ThoiGianBH, @ThanhTien, @ThueSuat, @TienThue, @TongTienHang, @TongTien)

		-- Tăng biến đếm
		set @i = @i + 1
	end
end
exec sp_ThongTinBanHang
Select * from BAN

-- 7. Thủ tục thêm chi tiết đơn bán bàng
go
create or alter proc sp_BanChiTiet
as
begin
	declare @i int = 1
	declare @MaBH char(6)
	declare @MaHH char(6)
	declare @SL int
	declare @ThanhTien numeric(15, 2)

	while @i <= 1000
	begin
		-- Tạo giá trị động cho các trường
		set @MaBH = 'BH' + RIGHT('000' + CAST(@i as varchar(4)), 4) -- Mã bán hàng 'BH001' đến 'BH1000'
		set @MaHH = 'HH' + RIGHT('000' + CAST((@i % 20) + 1 as varchar(4)), 4) -- Sử dụng 20 mã hàng hóa từ 'HH001' đến 'HH020'
		set @SL = ((@i % 10) + 1) * 5; -- Số lượng ngẫu nhiên từ 5 đến 50
		set @ThanhTien = @SL * 1000; -- Thành tiền dựa trên số lượng * 1000

		-- Chèn dữ liệu vào bảng BAN_CHI_TIET
		insert into BAN_CHI_TIET (MaBH, MaHH, SL, ThanhTien)
		values (@MaBH, @MaHH, @SL, @ThanhTien)

		-- Tăng biến đếm
		set @i = @i + 1
	end
end
exec sp_BanChiTiet
Select * from BAN_CHI_TIET


--8. Thủ tục thêm Giá Bán Hàng Hoá
go
create or alter procedure sp_GiaBanHangHoa
as
begin
    declare @i				int = 1
	declare @MaGiaBan		char(7)
	declare @MaHH			char(6)
	declare @GiaBan			numeric(15, 2)
    declare @NgayBan		date

    while @i <= 1000
    begin
		set @MaGiaBan = 'GB' + RIGHT('0000' + CAST(@i AS VARCHAR), 4) -- Tạo mã giá bán tự động
        set @maHH = 'HH' + RIGHT('000' + CAST(@i as varchar(4)), 4)
        set @GiaBan =   ROUND(RAND() * 1000000, 2) -- Giá bán ngẫu nhiên từ 0 đến 1.000.000
        set @NgayBan =   DATEADD(DAY, -@i % 30, GETDATE()) -- Ngày bán ngẫu nhiên trong vòng 30 ngày gần nhất
        

		--Chèn dữ liệu vào bảng GiaBanHH

		insert into GiaBanHH(MaGiaBan, MaHH, GiaBan, NgayBan)
		values (@MaGiaBan, @MaHH, @GiaBan, @NgayBan)
		--Tăng biến đếm
        set @i = @i + 1
    end
end

exec sp_GiaBanHangHoa
Select * from GiaBanHH


--9. Thủ tục thêm Giá Nhập Hàng Hoá

go
create or alter procedure sp_GiaNhapHangHoa
as
begin
    declare @i				int = 1
	declare @MaGiaNhap		char(7)
	declare @MaHH			char(6)
	declare @GiaNhap		numeric(15, 2)
    declare @NgayNhap		date

    while @i <= 1000
    begin
		set @MaGiaNhap = 'GB' + RIGHT('0000' + CAST(@i AS VARCHAR), 4) -- Tạo mã giá bán tự động
        set @maHH = 'HH' + RIGHT('000' + CAST(@i as varchar(4)), 4)
        set @GiaNhap =   ROUND(RAND() * 1000000, 2) -- Giá bán ngẫu nhiên từ 0 đến 1.000.000
        set @NgayNhap =   DATEADD(DAY, -@i % 30, GETDATE()) -- Ngày bán ngẫu nhiên trong vòng 30 ngày gần nhất
        

		--Chèn dữ liệu vào bảng GiaBanHH

		insert into GiaNhapHH(MaGiaNhap, MaHH, GiaNhap, NgayNhap)
		values (@MaGiaNhap, @MaHH, @GiaNhap, @NgayNhap)
		--Tăng biến đếm
        set @i = @i + 1
    end
end

exec sp_GiaNhapHangHoa
Select * from GiaNhapHH	




