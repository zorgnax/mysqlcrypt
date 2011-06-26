drop function if exists permute;;
create function permute (bin text, perm text)
returns text
begin
    declare pbin text default '';
    declare i int default 1;
    declare n int;
    PERMLOOP: loop
        if i > length(perm) then
            leave PERMLOOP;
        end if;
        set n = substr(perm, i, 2);
        set pbin = concat(pbin, substr(bin, n, 1));
        set i = i + 2;
    end loop;
    return pbin;
end;;

drop function if exists lshift;;
create function lshift (bin text, count int)
returns text
begin
    declare sbin text default '';
    declare i int default 0;
    declare j int;
    SHIFTLOOP: loop
        if i >= length(bin) then
            leave SHIFTLOOP;
        end if;
        set j = (i + count) % length(bin) + 1;
        set sbin = concat(sbin, substr(bin, j, 1));
        set i = i + 1;
    end loop;
    return sbin;
end;;

drop function if exists xorbin;;
create function xorbin (a text, b text)
returns text
begin
    declare x text default '';
    declare i int default 1;
    ALOOP: loop
        if i > length(a) then
            leave ALOOP;
        end if;
        set x = concat(x, substr(a, i, 1) ^ substr(b, i, 1));
        set i = i + 1;
    end loop;
    return x;
end;;

-- The following is a mysql translation of the
-- DES algorithm found in Samba's smbdes.c at
-- https://github.com/samba-team/samba/blob/7fa51/libcli/auth/smbdes.c
drop function if exists descrypt;;
create function descrypt (pass text, kee text)
returns text
comment 'Encrypts using the simple DES algorithm'
deterministic
begin
    declare perm1 text default '5749413325170901585042342618100259514335271911036052443663554739312315076254463830221406615345372921130528201204';
    declare perm2 text default '141711240105032815062110231912042608160727201302415231374755304051453348444939563453464250362932';
    declare perm3 text default '58504234261810026052443628201204625446383022140664564840322416085749413325170901595143352719110361534537292113056355473931231507';
    declare perm4 text default '320102030405040506070809080910111213121314151617161718192021202122232425242526272829282930313201';
    declare perm5 text default '1607202129122817011523260518311002082414322703091913300622110425';
    declare perm6 text default '40084816562464323907471555236331380646145422623037054513532161293604441252206028350343115119592734024210501858263301410949175725';
    declare sc text default '01010202020202020102020202020201';
    declare sbox text default '1404130102151108031006120509000700150704140213011006121109050308040114081306021115120907031005001512080204090107051103141000061315010814061103040907021312000510031304071502081412000110060911050014071110041301050812060903021513081001031504021106071200051409100009140603150501131207110402081307000903040610020805141211150113060409081503001101021205101407011013000609080704151403110502120713140300060910010208051112041513081105061500030407021201101409100609001211071315010314050208040315000610011308090405111207021402120401071011060805031513001409141102120407130105001510030908060402011110130708150912050603001411081207011402130615000910040503120110150902060800130304140705111015040207120905060113140011030809141505020812030700041001131106040302120905151011140107060008130411021415000813031209070510060113001107040901101403051202150806010411131203071410150608000509020611130801041007090500151402031213020804061511011009031405001207011513081003070412050611001409020711040109121402000610131503050802011407041008131512090003050611';
    declare pk1 text;
    declare c text;
    declare d text;
    declare cd text;
    declare ki text default '';
    declare kie text default '';
    declare er text;
    declare erk text;
    declare cb text default '';
    declare pcb text;
    declare r2 text;
    declare rl text;
    declare prl text;
    declare pd1 text;
    declare l text;
    declare r text;
    declare i int default 1;
    declare j int default 1;
    declare k int default 1;
    declare m int;
    declare n int;
    declare s int;
    set pass = str2bin(pass);
    set kee = str2bin(kee);
    set pk1 = permute(kee, perm1);
    set c = substr(pk1, 1, 28);
    set d = substr(pk1, 29, 28);
    SCLOOP: loop
        if i > length(sc) then
            leave SCLOOP;
        end if;
        set n = substr(sc, i, 2);
        set c = lshift(c, n);
        set d = lshift(d, n);
        set cd = concat(c, d);
        set ki = concat(ki, permute(cd, perm2));
        set i = i + 2;
    end loop;
    set pd1 = permute(pass, perm3);
    set l = substr(pd1, 1, 32);
    set r = substr(pd1, 33, 32);
    set i = 1;
    KILOOP: loop
        if i > length(ki) then
            leave KILOOP;
        end if;
        set kie = substr(ki, i, 48);
        set er = permute(r, perm4);
        set erk = xorbin(er, kie);
        set cb = '';
        set j = 0;
        JLOOP: loop
            if j > 7 then
                leave JLOOP;
            end if;
            set m = substr(erk, j * 6 + 1, 1) << 1 | substr(erk, j * 6 + 6, 1);
            set n = substr(erk, j * 6 + 2, 1) << 3 | substr(erk, j * 6 + 3, 1) << 2 | substr(erk, j * 6 + 4, 1) << 1 | substr(erk, j * 6 + 5, 1);
            set k = 0;
            KLOOP: loop
                if k > 3 then
                    leave KLOOP;
                end if;
                set s = if(substr(sbox, (j * 64 + m * 16 + n) * 2 + 1, 2) & 1 << 3 - k, 1, 0);
                set cb = concat(cb, s);
                set k = k + 1;
            end loop;
            set j = j + 1;
        end loop;
        set pcb = permute(cb, perm5);
        set r2 = xorbin(l, pcb);
        set l = r;
        set r = r2;
        set i = i + 48;
    end loop;
    set rl = concat(r, l);
    set prl = permute(rl, perm6);
    return lpad(conv(prl, 2, 16), 16, 0);
end;;

