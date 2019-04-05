FROM dynverse/dynwrapr:v0.1.0

ARG GITHUB_PAT

RUN R -e 'devtools::install_github("kieranrcampbell/phenopath")'

COPY definition.yml run.R example.sh /code/

ENTRYPOINT ["/code/run.R"]
