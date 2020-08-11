FROM docker:dind

# install bash
RUN apk add --no-cache ca-certificates bash
# install git client
RUN apk add --no-cache ca-certificates git

# copy scripts
RUN mkdir /scripts 
COPY ./scripts/* /scripts/
