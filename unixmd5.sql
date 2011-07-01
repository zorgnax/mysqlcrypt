-- unixmd5.sql

drop function if exists autosaltcrypt;;
drop function if exists unixmd5crypt;;
create function unixmd5crypt (pass text)
returns text
comment 'Creates a randomly salted unix md5 encrypted password'
not deterministic
begin
    declare salt char(11);
    declare cryptpass text;
    set salt = concat("$1$", substr(hex2b64(md5(rand())), -8));
    set cryptpass = encrypt(pass, salt);
    return cryptpass;
end;;

