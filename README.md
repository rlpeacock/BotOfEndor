# BotOfEndor

A Perl IRC bot built on Bot::BasicBot that listens for scripture references and posts the text for those references.
This was hacked together fairly quickly and relies on having a bible preprocessed into the right format. That is,
each book its own file, each line its own line prefixed with the line reference. This makes finding passages basically
a grepping operation. Minimum possible implementation, created mostly as a toy.


Bible source [here](https://github.com/pstephens/kingjames.bible/blob/main/kjv-src/kjv-1769.txt)

The script preprocess.pl will split this up into files named after the books contained therein.

```sh
cat jkv-1769.txt | preprocess.pl
```
Drop these in a subdirectory called books and you are all set!

Run tests:
```sh
docker build -t boe .
docker run  -v ./bot:/app  boe
```

To run the thing:
```sh
docker run -v ./bot:/app perl -I "." bot-of-endor.pl <params>
```
