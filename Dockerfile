FROM docker:dind

# install bash
RUN apk add --no-cache ca-certificates bash
# install git client
RUN apk add --no-cache ca-certificates git
# install curl
RUN apk add --no-cache ca-certificates curl
# install jq
RUN apk update && apk add --no-cache ca-certificates jq

# copy scripts
RUN mkdir /scripts 
COPY ./scripts/* /scripts/
