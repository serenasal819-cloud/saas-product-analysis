FROM python:3.12-slim
WORKDIR /app
COPY saas_analytics ./saas_analytics
RUN useradd --create-home portfolio && mkdir /app/output && chown portfolio:portfolio /app/output
USER portfolio
ENTRYPOINT ["python", "-m", "saas_analytics"]
CMD ["demo", "--output", "/app/output/demo"]
