# Extended provider prompt caching for pi where supported (e.g. Anthropic's
# 1-hour cache instead of 5 minutes). Pi has no settings.json key for this.
set -gx PI_CACHE_RETENTION long
