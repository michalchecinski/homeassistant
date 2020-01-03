FROM python:2.7-alpine

RUN apk add --no-cache --virtual .build_deps \
	gcc \
	musl-dev \
	linux-headers \
	&& pip install 'psutil>=5.4.7,<5.5.0' bottle==0.12.13 \
	&& apk del .build_deps

COPY ./glances /glances

WORKDIR /glances

EXPOSE 61208 61209

CMD python -m glances -C /glances/conf/glances.conf $GLANCES_OPT