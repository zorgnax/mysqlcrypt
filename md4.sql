-- a translation of the md4 code in
-- https://github.com/samba-team/samba/blob/7fa51/lib/crypto/md4.c

drop function if exists md4s;;
create function md4s (a int unsigned, b int unsigned, c int unsigned, d int unsigned)
returns text
comment 'Creates the md4 state data structure of 4 32 bit numbers'
deterministic
begin
    return concat(lpad(a, 10, 0), lpad(b, 10, 0), lpad(c, 10, 0), lpad(d, 10, 0));
end;;

drop function if exists md4m;;
create function md4m (bin text)
returns text
comment 'Creates an array of 16 32 bit integers from a binary string'
deterministic
begin
    declare i int default 0;
    declare x text;
    declare a text;
    declare b text;
    declare c text;
    declare d text;
    declare m text default '';
    FOURBYTELOOP: loop
        if i = 16 then
            leave FOURBYTELOOP;
        end if;
        set x = substr(bin, i * 4 * 8 + 1, 4 * 8);
        set a = substr(x, 1, 4);
        set b = substr(x, 5, 4);
        set c = substr(x, 9, 4);
        set d = substr(x, 13, 4);
        set m = concat(m, lpad(conv(concat(d, c, b, a), 2, 10), 10, 0));
        set i = i + 1;
    end loop;
    return m;
end;;

drop function if exists md4a;;
create function md4a (a text, n int)
returns int unsigned
comment 'Returns the nth value in the number array'
deterministic
begin
    return substr(a, n * 10 + 1, 10);
end;;

drop function if exists md4f;;
create function md4f (x int unsigned, y int unsigned, z int unsigned)
returns int unsigned
deterministic
begin
    return x & y | ~x & z;
end;;

drop function if exists md4g;;
create function md4g (x int unsigned, y int unsigned, z int unsigned)
returns int unsigned
deterministic
begin
    return x & y | x & z | y & z;
end;;

drop function if exists md4h;;
create function md4h (x int unsigned, y int unsigned, z int unsigned)
returns int unsigned
deterministic
begin
    return x ^ y ^ z;
end;;

drop function if exists md4lshift;;
create function md4lshift (x int unsigned, n int unsigned)
returns int unsigned
deterministic
begin
    return x << n & 0xffffffff | x >> 32 - n;
end;;

drop function if exists md4r1;;
create function md4r1 (s text, oa int, ob int, oc int, od int, m text, k int, n int)
returns text
deterministic
begin
    declare a int unsigned default md4a(s, oa);
    declare b int unsigned default md4a(s, ob);
    declare c int unsigned default md4a(s, oc);
    declare d int unsigned default md4a(s, od);
    declare x int unsigned default md4lshift(
        a + md4f(b, c, d) + md4a(m, k) & 0xffffffff, n);
    set a = if(oa = 0, x, md4a(s, 0));
    set b = if(oa = 1, x, md4a(s, 1));
    set c = if(oa = 2, x, md4a(s, 2));
    set d = if(oa = 3, x, md4a(s, 3));
    return md4s(a, b, c, d);
end;;

drop function if exists md4r2;;
create function md4r2 (s text, oa int, ob int, oc int, od int, m text, k int, n int)
returns text
deterministic
begin
    declare a int unsigned default md4a(s, oa);
    declare b int unsigned default md4a(s, ob);
    declare c int unsigned default md4a(s, oc);
    declare d int unsigned default md4a(s, od);
    declare x int unsigned default md4lshift(
        a + md4g(b, c, d) + md4a(m, k) + 0x5a827999 & 0xffffffff, n);
    set a = if(oa = 0, x, md4a(s, 0));
    set b = if(oa = 1, x, md4a(s, 1));
    set c = if(oa = 2, x, md4a(s, 2));
    set d = if(oa = 3, x, md4a(s, 3));
    return md4s(a, b, c, d);
end;;

drop function if exists md4r3;;
create function md4r3 (s text, oa int, ob int, oc int, od int, m text, k int, n int)
returns text
deterministic
begin
    declare a int unsigned default md4a(s, oa);
    declare b int unsigned default md4a(s, ob);
    declare c int unsigned default md4a(s, oc);
    declare d int unsigned default md4a(s, od);
    declare x int unsigned default md4lshift(
        a + md4h(b, c, d) + md4a(m, k) + 0x6ed9eba1 & 0xffffffff, n);
    set a = if(oa = 0, x, md4a(s, 0));
    set b = if(oa = 1, x, md4a(s, 1));
    set c = if(oa = 2, x, md4a(s, 2));
    set d = if(oa = 3, x, md4a(s, 3));
    return md4s(a, b, c, d);
end;;

drop function if exists md464;;
create function md464 (s text, m text)
returns text
comment 'Calculates the md4 state on 64 bytes of a message'
deterministic
begin
    declare a int unsigned default md4a(s, 0);
    declare b int unsigned default md4a(s, 1);
    declare c int unsigned default md4a(s, 2);
    declare d int unsigned default md4a(s, 3);
    set s = md4r1(s, 0, 1, 2, 3, m, 0, 3);
    set s = md4r1(s, 3, 0, 1, 2, m, 1, 7);
    set s = md4r1(s, 2, 3, 0, 1, m, 2, 11);
    set s = md4r1(s, 1, 2, 3, 0, m, 3, 19);
    set s = md4r1(s, 0, 1, 2, 3, m, 4, 3);
    set s = md4r1(s, 3, 0, 1, 2, m, 5, 7);
    set s = md4r1(s, 2, 3, 0, 1, m, 6, 11);
    set s = md4r1(s, 1, 2, 3, 0, m, 7, 19);
    set s = md4r1(s, 0, 1, 2, 3, m, 8, 3);
    set s = md4r1(s, 3, 0, 1, 2, m, 9, 7);
    set s = md4r1(s, 2, 3, 0, 1, m, 10, 11);
    set s = md4r1(s, 1, 2, 3, 0, m, 11, 19);
    set s = md4r1(s, 0, 1, 2, 3, m, 12, 3);
    set s = md4r1(s, 3, 0, 1, 2, m, 13, 7);
    set s = md4r1(s, 2, 3, 0, 1, m, 14, 11);
    set s = md4r1(s, 1, 2, 3, 0, m, 15, 19);
    set s = md4r2(s, 0, 1, 2, 3, m, 0, 3);
    set s = md4r2(s, 3, 0, 1, 2, m, 4, 5);
    set s = md4r2(s, 2, 3, 0, 1, m, 8, 9);
    set s = md4r2(s, 1, 2, 3, 0, m, 12, 13);
    set s = md4r2(s, 0, 1, 2, 3, m, 1, 3);
    set s = md4r2(s, 3, 0, 1, 2, m, 5, 5);
    set s = md4r2(s, 2, 3, 0, 1, m, 9, 9);
    set s = md4r2(s, 1, 2, 3, 0, m, 13, 13);
    set s = md4r2(s, 0, 1, 2, 3, m, 2, 3);
    set s = md4r2(s, 3, 0, 1, 2, m, 6, 5);
    set s = md4r2(s, 2, 3, 0, 1, m, 10, 9);
    set s = md4r2(s, 1, 2, 3, 0, m, 14, 13);
    set s = md4r2(s, 0, 1, 2, 3, m, 3, 3);
    set s = md4r2(s, 3, 0, 1, 2, m, 7, 5);
    set s = md4r2(s, 2, 3, 0, 1, m, 11, 9);
    set s = md4r2(s, 1, 2, 3, 0, m, 15, 13);
    set s = md4r3(s, 0, 1, 2, 3, m, 0, 3);
    set s = md4r3(s, 3, 0, 1, 2, m, 8, 9);
    set s = md4r3(s, 2, 3, 0, 1, m, 4, 11);
    set s = md4r3(s, 1, 2, 3, 0, m, 12, 15);
    set s = md4r3(s, 0, 1, 2, 3, m, 2, 3);
    set s = md4r3(s, 3, 0, 1, 2, m, 10, 9);
    set s = md4r3(s, 2, 3, 0, 1, m, 6, 11);
    set s = md4r3(s, 1, 2, 3, 0, m, 14, 15);
    set s = md4r3(s, 0, 1, 2, 3, m, 1, 3);
    set s = md4r3(s, 3, 0, 1, 2, m, 9, 9);
    set s = md4r3(s, 2, 3, 0, 1, m, 5, 11);
    set s = md4r3(s, 1, 2, 3, 0, m, 13, 15);
    set s = md4r3(s, 0, 1, 2, 3, m, 3, 3);
    set s = md4r3(s, 3, 0, 1, 2, m, 11, 9);
    set s = md4r3(s, 2, 3, 0, 1, m, 7, 11);
    set s = md4r3(s, 1, 2, 3, 0, m, 15, 15);
    return md4s(
        a + md4a(s, 0) & 0xffffffff,
        b + md4a(s, 1) & 0xffffffff,
        c + md4a(s, 2) & 0xffffffff,
        d + md4a(s, 3) & 0xffffffff);
end;;

drop function if exists md4reversebytes;;
create function md4reversebytes (x int unsigned)
returns text
comment 'Converts a 32 bit int to a bit string with its bytes reversed'
deterministic
begin
    declare b text default lpad(conv(x, 10, 2), 8 * 4, 0);
    return concat(
        substr(b, 25, 8), substr(b, 17, 8), substr(b, 9, 8), substr(b, 1, 8));
end;;

drop function if exists md4;;
create function md4 (str text)
returns text
comment 'Encrypts a string to an MD4 hash'
deterministic
begin
    declare bin text default str2bin(str);
    declare s text default md4s(1732584193, 4023233417, 2562383102, 271733878);
    declare m text;
    declare i int default 0;
    declare n int;
    declare bits int default length(bin);
    declare a text;
    declare b text;
    declare c text;
    declare d text;
    REDUCELOOP: loop
        if length(bin) - i <= 8 * 64 then
            leave REDUCELOOP;
        end if;
        set m = md4m(substr(bin, i + 1, 8 * 64));
        set s = md464(s, m);
        set i = i + 8 * 64;
    end loop;
    set n = length(bin) - i;
    set bin = rpad(concat(substr(bin, i + 1), hex2bin('80')), 8 * 128, 0);
    if n <= 8 * 55 then
        set bin = rpad(concat(substr(bin, 1, 56 * 8), md4reversebytes(bits)), 8 * 64, 0);
        set m = md4m(bin);
        return m;
        set s = md464(s, m);
    else
        begin end;
    end if;
    set a = lpad(conv(md4reversebytes(md4a(s, 0)), 2, 16), 8, 0);
    set b = lpad(conv(md4reversebytes(md4a(s, 1)), 2, 16), 8, 0);
    set c = lpad(conv(md4reversebytes(md4a(s, 2)), 2, 16), 8, 0);
    set d = lpad(conv(md4reversebytes(md4a(s, 3)), 2, 16), 8, 0);
    return concat(a, b, c, d);
end;;

