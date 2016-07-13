# This application is meant to be loaded in an iframe of another application, so we don't need this security feature.
Rails.application.config.action_dispatch.default_headers.delete('X-Frame-Options')

# Explicitly enable OAuth 1 support (for the ims-lti gem)
OAUTH_10_SUPPORT = true
