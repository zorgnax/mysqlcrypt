use 5.012;
use Data::Dumper;
use Encode;
use Carp;

sub ntcrypt {
    my ($pass) = @_;
    # roughly: (my $ucs2le = $pass) =~ s/(.)/$1\000/sg
    my $ucs2le = encode("UCS-2LE", $pass);
    # md4($ucs2le);
}

# Support functions
# Ported from SAMBA/source/lib/md4.c:F,G and H respectfully
sub F { my ( $X, $Y, $Z ) = @_; return ($X&$Y) | ((~$X)&$Z); }
sub G { my ( $X, $Y, $Z) = @_; return ($X&$Y) | ($X&$Z) | ($Y&$Z); }
sub H { my ($X, $Y, $Z) = @_; return $X^$Y^$Z; }

# Needed? because perl seems to choke on overflowing when doing bitwise
# operations on numbers larger than 32 bits. Well, it did on my machine =)
sub add32 {
    my ( @v ) = @_;
    my ( $ret, @sum );
    foreach ( @v ) {
        $_ = [ ($_&0xffff0000)>>16, ($_&0xffff) ];
    }
    @sum = ();
    foreach ( @v ) {
        $sum[0] += $_->[0];
        $sum[1] += $_->[1];
    }
    $sum[0] += ($sum[1]&0xffff0000)>>16;
    $sum[1] &= 0xffff;
    $sum[0] &= 0xffff;
    $ret = ($sum[0]<<16) | $sum[1];
    return $ret;
}

# Ported from SAMBA/source/lib/md4.c:lshift
# Renamed to prevent clash with SAMBA/source/libsmb/smbdes.c:lshift
sub md4lshift {
    my ($x, $s) = @_;
    $x &= 0xFFFFFFFF;
    return (($x<<$s)&0xFFFFFFFF) | ($x>>(32-$s));
}

# Ported from SAMBA/source/lib/md4.c:ROUND1
sub ROUND1 {
    my($a,$b,$c,$d,$k,$s,@X) = @_;
    $_[0] = md4lshift(add32($a,F($b,$c,$d),$X[$k]), $s);
    return $_[0];
}

# Ported from SAMBA/source/lib/md4.c:ROUND2
sub ROUND2 {
    my ($a,$b,$c,$d,$k,$s,@X) = @_;
    $_[0] = md4lshift(add32($a,G($b,$c,$d),$X[$k],0x5A827999), $s);
    return $_[0];
}

# Ported from SAMBA/source/lib/md4.c:ROUND3
sub ROUND3 {
    my ($a,$b,$c,$d,$k,$s,@X) = @_;
    $_[0] = md4lshift(add32($a,H($b,$c,$d),$X[$k],0x6ED9EBA1), $s);
    return $_[0];
}

# Ported from SAMBA/source/lib/md4.c:mdfour64
sub mdfour64 {
    my ( $A, $B, $C, $D, @M ) = @_;
    my ( $AA, $BB, $CC, $DD );
    my ( @X );
    @X = (map { $_?$_:0 } @M)[0..15];
    $AA=$A; $BB=$B; $CC=$C; $DD=$D;
        ROUND1($A,$B,$C,$D,  0,  3, @X);  ROUND1($D,$A,$B,$C,  1,  7, @X);
        ROUND1($C,$D,$A,$B,  2, 11, @X);  ROUND1($B,$C,$D,$A,  3, 19, @X);
        ROUND1($A,$B,$C,$D,  4,  3, @X);  ROUND1($D,$A,$B,$C,  5,  7, @X);
        ROUND1($C,$D,$A,$B,  6, 11, @X);  ROUND1($B,$C,$D,$A,  7, 19, @X);
        ROUND1($A,$B,$C,$D,  8,  3, @X);  ROUND1($D,$A,$B,$C,  9,  7, @X);
        ROUND1($C,$D,$A,$B, 10, 11, @X);  ROUND1($B,$C,$D,$A, 11, 19, @X);
        ROUND1($A,$B,$C,$D, 12,  3, @X);  ROUND1($D,$A,$B,$C, 13,  7, @X);
        ROUND1($C,$D,$A,$B, 14, 11, @X);  ROUND1($B,$C,$D,$A, 15, 19, @X);
        ROUND2($A,$B,$C,$D,  0,  3, @X);  ROUND2($D,$A,$B,$C,  4,  5, @X);
        ROUND2($C,$D,$A,$B,  8,  9, @X);  ROUND2($B,$C,$D,$A, 12, 13, @X);
        ROUND2($A,$B,$C,$D,  1,  3, @X);  ROUND2($D,$A,$B,$C,  5,  5, @X);
        ROUND2($C,$D,$A,$B,  9,  9, @X);  ROUND2($B,$C,$D,$A, 13, 13, @X);
        ROUND2($A,$B,$C,$D,  2,  3, @X);  ROUND2($D,$A,$B,$C,  6,  5, @X);
        ROUND2($C,$D,$A,$B, 10,  9, @X);  ROUND2($B,$C,$D,$A, 14, 13, @X);
        ROUND2($A,$B,$C,$D,  3,  3, @X);  ROUND2($D,$A,$B,$C,  7,  5, @X);
        ROUND2($C,$D,$A,$B, 11,  9, @X);  ROUND2($B,$C,$D,$A, 15, 13, @X);
        ROUND3($A,$B,$C,$D,  0,  3, @X);  ROUND3($D,$A,$B,$C,  8,  9, @X);
        ROUND3($C,$D,$A,$B,  4, 11, @X);  ROUND3($B,$C,$D,$A, 12, 15, @X);
        ROUND3($A,$B,$C,$D,  2,  3, @X);  ROUND3($D,$A,$B,$C, 10,  9, @X);
        ROUND3($C,$D,$A,$B,  6, 11, @X);  ROUND3($B,$C,$D,$A, 14, 15, @X);
        ROUND3($A,$B,$C,$D,  1,  3, @X);  ROUND3($D,$A,$B,$C,  9,  9, @X);
        ROUND3($C,$D,$A,$B,  5, 11, @X);  ROUND3($B,$C,$D,$A, 13, 15, @X);
        ROUND3($A,$B,$C,$D,  3,  3, @X);  ROUND3($D,$A,$B,$C, 11,  9, @X);
        ROUND3($C,$D,$A,$B,  7, 11, @X);  ROUND3($B,$C,$D,$A, 15, 15, @X);
    # We want to change the arguments, so assign them to $_[0] markers
    # rather than to $A..$D
    $_[0] = add32($A,$AA); $_[1] = add32($B,$BB);
    $_[2] = add32($C,$CC); $_[3] = add32($D,$DD);
    @X = map { 0 } (1..16);
}

# Ported from SAMBA/source/lib/md4.c:copy64
sub copy64 {
    my ( @in ) = @_;
    my ( $i, @M );
    for $i ( 0..15 ) {
        $M[$i] = ($in[$i*4+3]<<24) | ($in[$i*4+2]<<16) |
                        ($in[$i*4+1]<<8) | ($in[$i*4+0]<<0);
    }
    return @M;
}
# Ported from SAMBA/source/lib/md4.c:copy4
sub copy4 {
    my ( $x ) = @_;
    my ( @out );
        $out[0] = $x&0xFF;
        $out[1] = ($x>>8)&0xFF;
        $out[2] = ($x>>16)&0xFF;
        $out[3] = ($x>>24)&0xFF;
    @out = map { $_?$_:0 } @out;
    return @out;
}
# Ported from SAMBA/source/lib/md4.c:mdfour
sub mdfour {
    my ( @in ) = unpack("C*",$_[0]);
    my ( $b, @A, @M, @buf, @out );
    $b = scalar @in * 8;
    @A = ( 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476 );
    while (scalar @in > 64 ) {
        @M = copy64( @in );
        mdfour64( @A, @M );
        @in = @in[64..$#in];
    }
    @buf = ( @in, 0x80, map {0} (1..128) )[0..127];
    if ( scalar @in <= 55 ) {
        @buf[56..59] = copy4( $b );
        @M = copy64( @buf );
        mdfour64( @A, @M );
    }
    else {
        @buf[120..123] = copy4( $b );
        @M = copy64( @buf );
        mdfour64( @A, @M );
        @M = copy64( @buf[64..$#buf] );
        mdfour64( @A, @M );
    }
    @out[0..3] = copy4($A[0]);
    @out[4..7] = copy4($A[1]);
    @out[8..11] = copy4($A[2]);
    @out[12..15] = copy4($A[3]);
    return @out;
}

