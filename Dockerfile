#
# This creates a minimal Docker image to allow easy testing of Waldo CLI on
# Linux. It is based on the Alpine Linux image adding in Bash, curl, and make.
# It also installs the `waldo` executable into `/usr/local/bin`.
#
# To build the image, issue the following command from the project directory:
#
# ```
# $ docker build -t linux-waldo-cli .
# ```
#
# You can subsequently run the resulting Docker image from any directory (and
# also create a readonly binding to that directory) with the following command:
#
# ```
# $ docker run -it -v $(pwd):/app:ro linux-waldo-cli
# ```

FROM alpine:latest

RUN apk add --no-cache curl bash

COPY WaldoCLI.sh /usr/local/bin/waldo
RUN chmod a+x /usr/local/bin/waldo
