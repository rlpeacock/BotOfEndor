
use Test::More tests => 5;
require "botofendor.pl";

my @KINGS = (
	"1:1 Then Moab rebelled against Israel after the death of Ahab.",
	"1:2 And Ahaziah fell down through a lattice in his upper chamber that was in Samaria, and was sick: and he sent messengers, and said unto them, Go, enquire of Baalzebub the god of Ekron whether I shall recover of this disease.",
	"1:3 But the angel of the LORD said to Elijah the Tishbite, Arise, go up to meet the messengers of the king of Samaria, and say unto them, Is it not because there is not a God in Israel, that ye go to enquire of Baalzebub the god of Ekron?	"
);

my @COLOSSIANS = (
	"3:1  If ye then be risen with Christ, seek those things which are above, where Christ sitteth on the right hand of God.",
	"3:2  Set your affection on things above, not on things on the earth.",
	"3:3  For ye are dead, and your life is hid with Christ in God."
);

is lookup_reference(""), undef, "empty lookup";

my @res = lookup_reference("2 kings 1:1");
is $res[0], $KINGS[0], "basic lookup";

my @res = lookup_reference("colossians 3:1-3");
is_deeply \@res, \@COLOSSIANS, "multiline lookup";

my @res = get_verses("foo [2 kings 1:1] bar [2 kings 1:2] baz [2 kings 1:3]");
is @res, @KINGS, "multiple verses";

my @res = get_verses("[song of solomon 2:1-20]");
is scalar(@res), 5, "too many verses";
