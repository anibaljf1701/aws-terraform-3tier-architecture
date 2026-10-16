FROM ministackorg/ministack:1.5.28

LABEL org.opencontainers.image.title="Terraform 3-Tier Ministack" \
      org.opencontainers.image.description="Local AWS API emulator for the Terraform 3-tier architecture project" \
      org.opencontainers.image.source="https://github.com/anibaljf1701/aws-terraform-3tier-architecture"

EXPOSE 4566

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:4566/_ministack/health', timeout=2)"]