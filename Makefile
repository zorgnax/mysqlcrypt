crypt.sql: handy.sql des.sql lm.sql unixmd5.sql md4.sql
	cat $^ > $@

install: crypt.sql
	cat $< | mysql -v test

