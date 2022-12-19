FROM apache/airflow:2.4.2
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         build-essential \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER airflow
WORKDIR /home/airflow
RUN pip install --no-cache-dir apache-airflow-providers-amazon