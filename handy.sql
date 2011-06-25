set global log_bin_trust_function_creators = 1;
delimiter ;;

drop function if exists hex2bin;;
create function hex2bin (hex text)
returns text
comment 'Converts a string containing hex values into binary'
deterministic
begin
    declare bin text default '';
    declare n int default 0;
    declare d char(1);
    if hex is null then
        return null;
    end if;
    -- mysql's conv function has a limit on the length of the hex string
    -- it can convert in one shot, so convert it one char at a time.
    HEX2BIN: loop
        if n = length(hex) then
            leave HEX2BIN;
        end if;
        set n = n + 1;
        set d = substr(hex, n, 1);
        set bin = concat(bin, lpad(conv(d, 16, 2), 4, 0));
    end loop;
    return bin;
end;;

drop function if exists hex2b64;;
create function hex2b64 (hex text)
returns text
comment 'Converts a string containing hex values into base64'
deterministic
begin
    declare b64set text default
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./";
    declare bin text default hex2bin(hex);
    declare b64 text default '';
    declare chars int;
    declare chip int;
    declare n int default 0;
    declare d char(1);
    if hex is NULL then
        return NULL;
    end if;
    -- Chip away at the binary representation of the hex string 6 bits at
    -- a time. 6 bits =>  2**6 => base64. The binary number can then be
    -- used as an index into b64set to get the next base64 character.
    B64DIGIT: loop
        set chars = length(bin);
        if !chars then
            leave B64DIGIT;
        end if;
        set chip = if(chars % 6, chars % 6, 6);
        set n = conv(substr(bin, 1, chip), 2, 10);
        set d = substr(b64set, n + 1, 1);
        set b64 = concat(b64, d);
        set bin = substr(bin, chip + 1);
    end loop;
    return b64;
end;;

drop function if exists str2bin;;
create function str2bin (str text)
returns text
comment 'Converts a character string to a bit string'
deterministic
begin
    return hex2bin(hex(str));
end;;

drop function if exists bin2str;;
create function bin2str (bin text)
returns text
comment 'Converts a bit string to a character string'
deterministic
begin
    declare str text default '';
    declare n int;
    declare c text;
    BYTES: loop
        if !length(bin) then
            leave BYTES;
        end if;
        set n = conv(substr(bin, 1, 8), 2, 10);
        set c = char(n);
        set str = concat(str, c);
        set bin = substr(bin, 8 + 1);
    end loop;
    return str;
end;;

