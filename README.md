# BotOfEndor

A Perl IRC bot built on Bot::BasicBot that listens for scripture references and posts the text for those references.
This was hacked together fairly quickly and relies on having a bible preprocessed into the right format. That is,
each book its own file, each line its own line prefixed with the line reference. This makes finding passages basically
a grepping operation. There are probably a dozen other shotcuts, but hey, it's Perl. No point in writing Perl if you
don't golf the whole solution!
