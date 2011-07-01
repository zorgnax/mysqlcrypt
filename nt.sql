drop function if exists bswap16;;
create function bswap16 (bin text)
returns text
comment 'Swaps the bytes of every 16 bit word'
deterministic
begin
    declare sbin text default '';
    declare n int default 0;
    declare s text;
    declare a text;
    declare b text;
    if bin is null or bin = '' or length(bin) % 16 then
        return '';
    end if;
    SWAPLOOP: loop
        if n = length(bin) then
            leave SWAPLOOP;
        end if;
        set s = substr(bin, n + 1, 16);
        set a = substr(s, 1, 8);
        set b = substr(s, 9, 8);
        set sbin = concat(sbin, b, a);
        set n = n + 16;
    end loop;
    return sbin;
end;;

drop function if exists ucs2le;;
create function ucs2le (str text)
returns text
comment 'Encodes a string to binary UCS2 little endian'
deterministic
begin
    return bin2str(bswap16(hex2bin(hex(convert(str using ucs2)))));
end;;

drop function if exists ntcrypt;;
create function ntcrypt (pass text)
returns text
comment 'Encrypts a string to an NT hash'
deterministic
begin
    declare ucs2le text default ucs2le(pass);
    return md4(ucs2le);
end

