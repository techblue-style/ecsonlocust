FROM --platform=linux/x86_64 locustio/locust

COPY ./scripts /scripts

EXPOSE 8089
EXPOSE 5557
EXPOSE 5558