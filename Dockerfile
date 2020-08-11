FROM docker:dind

# install git client
RUN apk add --no-cache ca-certificates git

# copy scripts
RUN mkdir /scripts 
COPY ./scripts/* /scripts/
