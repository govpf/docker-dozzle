FROM amir20/dozzle:v10 as official

FROM govpf/alpine:3

LABEL govpf.fromimage="govpf/alpine:3"
LABEL govpf.category="observability"

ENV PATH=/bin

COPY --from=official /dozzle /dozzle

EXPOSE 8080

ENTRYPOINT ["/dozzle"]