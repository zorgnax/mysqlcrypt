drop function if exists lmkey;;
create function lmkey (str text)
returns text
comment 'Inserts a 0 bit after every 7 bits'
deterministic
begin
    declare bin text default str2bin(str);
    declare pbin text default '';
    declare i int default 1;
    declare d int;
    BINDIGIT: loop
        if i > length(bin) then
            leave BINDIGIT;
        end if;
        set d = substr(bin, i, 1);
        set pbin = concat(pbin, d);
        if !(i % 7) then
            set pbin = concat(pbin, '0');
        end if;
        set i = i + 1;
    end loop;
    set pbin = rpad(pbin, 64, 0);
    return bin2str(pbin);
end;;

drop function if exists lmcrypt;;
create function lmcrypt (pass text)
returns text
comment 'Encrypts a string to an LM hash'
deterministic
begin
    declare in1 text;
    declare in2 text;
    declare des1 text;
    declare des2 text;
    set in1 = upper(substr(pass, 1, 7));
    set in2 = upper(substr(pass, 8, 14));
    set des1 = descrypt('KGS!@#$%', lmkey(in1));
    set des2 = descrypt('KGS!@#$%', lmkey(in2));
    return concat(des1, des2);
end;;

