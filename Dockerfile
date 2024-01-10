FROM amir20/dozzle:v3.13.1 as official

FROM govpf/alpine:3

ENV PATH /bin

COPY --from=official /dozzle /dozzle

EXPOSE 8080

ENTRYPOINT ["/dozzle"]
