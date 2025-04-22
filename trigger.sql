use Bank
/*1 khi xóa dl trong bảng transctions, hãy thực hiện thao tác cập nhật trạng thái
t_type là 9 (không dùng nữa) thay vì xóa
input: không
output: không
loại: insetead of
sự kiện: delete
bảng: transactions
*/
go
create trigger tdelTran
on transactions
instead of delete
as
begin
	update transactions 
	set t_type=9
	where t_id in (select t_id from deleted)
end

-- test
select * from transactions
delete transactions where t_id='0000000203'

-----------BTVN---------------------------
/*
1.	Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a.	Kiểm tra trạng thái tài khoản của giao dịch hiện hành. Nếu trạng thái tài khoản ac_type = 9 
thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy thao tác đã thực hiện. Ngược lại:  
i.	Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
ii.	Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 
thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
input: không
output: không
loại: after
sự kiện: insert
bảng: transactions
xu ly: 
	1. tìm ac_no trong inserted --> @ac_no
	2. lay t_type trong bang ACCount, dk: ac_no = @ac_no --> @ac_type
		2.1. neu @ac_type = 9 --> print "tai khoan da bi xoa" + rollback
		2.1. ngược lai: update account set ac_balance = case @t_type = 1 then ac_balance + @t_amount
																@t_type = 0 then ac_balance - @t_amount
										dk: ac_no=@ac_no
			b) nếu @ac_type = 0
				nếu @ac_balance - @t_amount < 50000 --> print 'khong du tien' + rollback
				nguoc lai: update như trên nhưng trừ tiền
*/
-----------------------------------------------
go
create trigger tInsTran 
on transactions 
after insert
as
begin
	declare @ac_type char(1), @t_type char(1), @ac_no char(10), @t_amount numeric(15,0), @ac_balance numeric(15,0)
	select @t_type=t_type from inserted
	select @ac_no=ac_no from inserted
	select @ac_type = ac_type,  @ac_balance = ac_balance from account where Ac_no=@ac_no
	select @t_amount=t_amount from inserted
	if @ac_type=9
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end
	else
	begin
		if @t_type=1 or (@t_type=0 and @ac_balance-@t_amount>50000)
		begin
			update account
			set ac_balance= case @t_type	when 1 then ac_balance+@t_amount
											when 0 then ac_balance-@t_amount 
							end
							where ac_no=@ac_no
		end
		else
		begin
			print N'không đủ tiền'
			rollback 
		end
	end
end
insert into transactions values ('1000000501', 1, 1752000, '2011-12-27', '8:35','1000000041')

insert into transactions values ('0000000503', 0, 20000, '2011-12-27', '8:35','1000000041')

insert into transactions values ('0000000504', 1, 1752000, '2011-12-27', '8:35','1000000001')

select* from transactions join account on transactions.ac_no= account.Ac_no 
where account.Ac_no='0000000504'
select*from account
/*
2.	Sau khi xóa dữ liệu trong transactions hãy tính lại số dư:
a.	Nếu là giao dịch rút
Số dư = số dư cũ + t_amount
b.	Nếu là giao dịch gửi
Số dư = số dư cũ – t_amount
input: không
output: không
loại: after
sự kiện: delete
bảng: transactions
*/
go
create trigger tgDelete_Trans
on transactions
after delete
as
begin
	declare @t_type varchar(1), @t_amount int, @ac_no varchar(10)
	set @t_type = (select t_type from deleted)
	set @t_amount = (select t_amount from deleted)
	set @ac_no = (select ac_no from deleted)
	if @t_type='0'
	begin
		update account
		set ac_balance = ac_balance + @t_amount
		where Ac_no=@ac_no
	end
	else if @t_type='1'
	begin
		update account
		set ac_balance = ac_balance - @t_amount
		where Ac_no=@ac_no
	end
end
go

delete from transactions
where t_id='0000000208'

go
select* from transactions join account on transactions.ac_no= account.Ac_no 
where t_id='0000000208'

/* 3.	Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự. 
*/
go
create trigger tNameCust
on customer
for insert, update 
as
begin
	declare @cust_name nvarchar(50)
	set @cust_name = ( select Cust_name from inserted)
	if len(@cust_name) < 5
	begin
		print N'Độ dài tên chưa đạt'
		rollback
	end
end

go
update customer
set Cust_name = 'ab'
where Cust_id='000011'

select * from customer

/*
4.	Khi xóa dữ liệu trong bảng account, hãy thực hiện thao tác cập nhật trạng thái tài khoản là 9 (không dùng nữa) thay vì xóa.
input: không
output: không
loại: instead of
sự kiện: delete
bảng: transactions
*/
go
create trigger tdelTran
on transactions
instead of delete
as
begin
	update transactions 
	set t_type=9
	where t_id in (select t_id from deleted)
end

go
delete transactions where t_id='0000000201'
-- test
select * from transactions

/*
5.	Khi thêm mới dữ liệu trong bảng transactions hãy thực hiện các công việc sau:
a.	Kiểm tra trạng thái tài khoản của giao dịch hiện hành. 
Nếu trạng thái tài khoản ac_type = 9 thì đưa ra thông báo ‘tài khoản đã bị xóa’ 
và hủy thao tác đã thực hiện. Ngược lại:  
i.	Nếu là giao dịch gửi: số dư = số dư + tiền gửi. 
ii.	Nếu là giao dịch rút: số dư = số dư – tiền rút. Nếu số dư sau khi thực hiện giao dịch < 50.000 
thì đưa ra thông báo ‘không đủ tiền’ và hủy thao tác đã thực hiện.
giống cau 1
*/

/*
6.	Khi sửa dữ liệu trong bảng transactions hãy tính lại số dư:
Số dư = số dư cũ + (số dữ mới – số dư cũ)
input: khong
output: không
loại: create
sự kiện: update
bảng: transactions
*/
go
create trigger tgUpdateT_Amount
on transactions
for update
as
begin
	declare @t_amount int, @t_type varchar(1),@ac_no varchar(10)
	set @t_amount = (select t_amount from inserted)
	set @t_type = (select t_type from inserted)
	set @ac_no = (select Ac_no from inserted)
	if @t_type = '1'
	begin
		update account
		set ac_balance = ac_balance + @t_amount
		where Ac_no = @ac_no
	end
	else if @t_type = '0'
	begin
		update account
		set ac_balance = ac_balance - @t_amount
		where Ac_no = @ac_no
	end
end

go
update transactions
set t_amount = 100000
where t_id = '0000000206'

select* from transactions join account on transactions.ac_no= account.Ac_no 
where t_id = '0000000206'

/* 
7.	Sau khi xóa dữ liệu trong transactions hãy tính lại số dư:
a.	Nếu là giao dịch rút
Số dư = số dư cũ + t_amount
b.	Nếu là giao dịch gửi
Số dư = số dư cũ – t_amount
-> giong cau 2
8.	Khi cập nhật hoặc sửa dữ liệu tên khách hàng, hãy đảm bảo tên khách không nhỏ hơn 5 kí tự. 
-> giong cau 3
*/
/*
9.	Khi tác động đến bảng account (thêm, sửa, xóa), hãy kiểm tra loại tài khoản. 
Nếu ac_type = 9 (đã bị xóa) thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy các thao tác vừa thực hiện.
*/
go
create trigger tIns_Del_Upaccount
on account
for insert, update, delete
as
begin
    declare @ac_type char(1), @ac_no char(10)
    select @ac_type = ac_type, @ac_no = Ac_no from inserted
    
    if @ac_type = '9'
    begin
        print N'Tài khoản đã bị xóa'
        rollback
    end
end
-- Thêm một bản ghi
insert into account values ('1000045671', 84940033, 0, '000001')

-- Sửa một bản ghi
update account
set ac_balance = 46133892
where ac_no = '1000000001'

-- Xóa một bản ghi -> bị lỗi test
delete from account
where ac_no = '1000000002'

select *from account

/*
10.	Khi thêm mới dữ liệu vào bảng customer, kiểm tra nếu họ tên và số điện thoại 
đã tồn tại trong bảng thì đưa ra thông báo ‘đã tồn tại khách hàng’ và hủy toàn bộ thao tác.
*/
/* 
Bang: customer
Loai: After
Su Kien: Insert
Process: 
		1. Ho ten, Sđt từ bảng inserted 
		2. Kiem tra tinh hop le Neu ho ten và so dien thoai ton tai ---> print 'Da ton tai khach hang' + ROLLBACK
		
*/
go
create trigger tInsCust
on customer
for insert
as
begin
	declare @cust_name nvarchar(50), @cust_phone varchar(11)
	select @cust_name=Cust_name from inserted
	select @cust_phone=Cust_phone from inserted
	if (select count(*) from customer 
		where Cust_name=@cust_name and Cust_phone=@cust_phone)>1
	begin
		print N'đã tồn tại khách hàng'
		rollback
	end 
end

insert into customer values ('000001',N'Hà Công Lực','01283388103', N'NGUYỄN TIẾN DUẨN - THÔN 3 - XÃ DHÊYANG - EAHLEO - ĐĂKLĂK','VT009')
select* from customer

alter table customer
enable trigger tInsCust 
alter table customer
disable trigger all
/*
11.	Khi thêm mới dữ liệu vào bảng account, hãy kiểm tra mã khách hàng. Nếu mã khách hàng chưa tồn tại trong bảng customer 
thì đưa ra thông báo ‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’ và hủy toàn bộ thao tác. 
*/
go
create trigger tIntAcc 
on account 
for insert
as
begin
	declare @cust_id char(6)
	select @cust_id=cust_id from inserted
	if not exists (select 1 from customer where Cust_id=@cust_id)
	begin
		print N'khách hàng chưa tồn tại, hãy tạo mới khách hàng trước'
		rollback
	end
end
insert into account values('1000000059',837000,'1','000004')

select * from account


/*
12.	Khi tác động đến bảng account (thêm, sửa, xóa), hãy kiểm tra loại tài khoản. Nếu ac_type = 9 (đã bị xóa) 
thì đưa ra thông báo ‘tài khoản đã bị xóa’ và hủy các thao tác vừa thực hiện.
*/
go
create trigger tChangeAcount
on account
for insert,update,delete
as
begin
	declare @ac_type1 varchar(1),@ac_type2 varchar(1)
	set @ac_type1 = (select ac_type from inserted)
	set @ac_type2 = (select ac_type from deleted)

	if @ac_type1= '9' and @ac_type2 is null    ---insert
	begin
		print N'Tài khoản đã bị xóa'
		rollback
	end

	if @ac_type2= '9' and @ac_type1 is null    ---delete
	begin
		print N'Tài khoản đã bị xoá'
		rollback
	end

	if @ac_type1 is null and @ac_type2 is null   --update
	begin
		print N'Tài khoản đã bị xoá'
		rollback
	end
end
go
update account set ac_type = 9 where ac_no = '1000000001'

insert into account values ('1000000011',3729022, 1,'000016') -- lỗi


alter table account
enable trigger tChangeAcount
alter table account
disable trigger all

select * from account
/*
13.	Khi thêm mới dữ liệu vào bảng customer, kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng 
thì đưa ra thông báo ‘đã tồn tại khách hàng’ và hủy toàn bộ thao tác.
-> giong cau 10
14.	Khi thêm mới dữ liệu vào bảng account, hãy kiểm tra mã khách hàng. Nếu mã khách hàng chưa tồn tại trong bảng customer 
thì đưa ra thông báo ‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’ và hủy toàn bộ thao tác. 
-> giong cau 11*/

alter table customer
disable trigger tInsert_customer --(enable)
alter table customer
enable trigger all


/* Câu 2
trigger 
bang: Transaction
loai: After
sukien: insert 
process: 
		1. Lay ac_no, t_type, @t_amount cua bang inserted ---> @ac_no, @t_type, @t_amount
		2. Lay ac_type, ac_balance của bang account ---> @ac_type, @ac_balance
		3. 
		a.neu @ac_type = 9 print 'Tai khoan da bi xoa' + roll back
		b.nguoc lai 
		3b1: Neu @t_type =1: update account, ac_balance = ac_balance + @t_amount					
							Dieu kien: ac_no = @ac_no
		3b2. Neu @t_type =0:
			a) Neu @ac_balance - @t_amount <50000: print 'Khong du tien' + ROLLBACK
			b) Nguoc lai: update account, ac_balance = ac_balance - @t_amount
						  Dieu Kien: ac_no = @ac_no


