FROM docker:20-dind

# install bash
RUN apk add --no-cache ca-certificates bash
# install git client
RUN apk add --no-cache ca-certificates git
# install curl
RUN apk add --no-cache ca-certificates curl
# install jq
RUN apk update && apk add --no-cache ca-certificates jq
# install aws cli
RUN apk add --no-cache ca-certificates \
    python3 \
    py3-pip \
    && pip3 install --break-system-packages awscli

# copy scripts
RUN mkdir /scripts 
COPY ./scripts/* /scripts/
