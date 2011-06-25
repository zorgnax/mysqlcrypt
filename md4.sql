drop function if exists md4;;
create function md4 (str text)
returns text
comment 'Encrypts a string to an MD4 hash'
deterministic
begin
    declare bin text default str2bin(str);
    declare a int default 1732584193;
    declare b int default 4023233417;
    declare c int default 2562383102;
    declare d int default 271733878;
    REDUCELOOP: loop
        set a = 1;
        leave REDUCELOOP;
    end loop;
    return 'hello';
end;;

