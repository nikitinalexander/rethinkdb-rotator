FROM python:3.9.16-slim-bullseye as build
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
build-essential gcc curl

RUN curl -LO "https://dl.k8s.io/release/stable.txt"
RUN curl -L https://dl.k8s.io/release/$(cat stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

WORKDIR /usr/app
RUN python -m venv /usr/app/venv
ENV PATH="/usr/app/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install -r requirements.txt

FROM python:3.9.16-slim-bullseye

COPY --from=build /usr/local/bin/kubectl /usr/local/bin/kubectl

RUN apt-get update && apt-get install -y --no-install-recommends git && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives

RUN groupadd -g 999 python && \
    useradd -r -u 999 -g python python

RUN mkdir /usr/app && chown python:python /usr/app
WORKDIR /usr/app

COPY --chown=python:python --from=build /usr/app/venv ./venv
COPY --chown=python:python . .

USER 999

ENV PATH="/usr/app/venv/bin:$PATH"
CMD [ "bash", "rotate.sh" ]