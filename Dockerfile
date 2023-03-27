FROM perl:5.36-slim

# need GCC to build a dependency *sigh*
RUN apt update
RUN apt install -y gcc

# bypass CPAN's config dialog.
# Hey CPAN, people like to automate things in the 21st century!
RUN echo | cpan
# cpanminus actually fetches dependencies.
RUN cpan App::cpanminus
RUN cpanm Log::Any
RUN cpanm Bot::BasicBot
RUN cpanm DateTime
RUN cpanm Test::More
RUN cpanm Test::MockObject

WORKDIR /app

CMD ["perl", "-I", ".", "test_botofendor.pl"]
