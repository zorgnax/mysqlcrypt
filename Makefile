crypt.sql: handy.sql des.sql lm.sql unixmd5.sql md4.sql nt.sql
	cat $^ > $@

install: crypt.sql
	cat $< | mysql -v test

