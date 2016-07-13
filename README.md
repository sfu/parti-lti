# Parti

Parti is a live image upload participation tool written in Ruby (1.9.3) on Rails (4.2.1). It is designed to work with the [Canvas LMS](https://github.com/instructure/canvas-lms).

## Configuration

Some manual configuration is needed to set up integration with Canvas. A Canvas Developer Key must first be [created](https://guides.instructure.com/m/4214/l/441833-how-do-i-add-a-developer-key-for-an-account) (self-hosted Canvas) or [requested](http://goo.gl/yu4lT) (Canvas cloud) for Parti. Then, [add Parti to Canvas as an External App](http://guides.instructure.com/s/2204/m/4152/l/74482-how-do-i-configure-an-external-tool-for-a-course-using-a-url). The Consumer Key and Shared Secret can be anything, but must match the values given to the database below. The Config URL is `/lti/config` under your Parti server (e.g. `http://party.yourschool.edu/lti/config`).

After all database migrations are done, create a record in the `lti_tool_consumers` table, either directly or through the Rails console. The following is a summary of all columns in the table:

* `name` — a human-readable name for this integration (e.g. "Canvas Production")
* `oauth_consumer_key` — the same value given to Canvas when adding Parti as an App
* `oauth_shared_secret` — the same value given to Canvas when adding Parti as an App
* `product_family` — identifies the Tool Consumer/LMS; only `canvas` is currently supported
* `url_root` — the protocol and hostname to your Canvas instance (e.g. `https://canvas.yourschool.edu`)
* `oauth2_auth_request_path` — the path to request authentication with Canvas (e.g. `/login/oauth2/auth`)
* `oauth2_token_request_path` — the path to request access tokens with Canvas (e.g. `/login/oauth2/token`)
* `oauth2_client_id` — the "ID" of Canvas Developer Key for Parti
* `oauth2_client_secret` — the "Key" of Canvas Developer Key for Parti

The first set of OAuth credentials is for LTI-based communication, which uses OAuth. The second set is for the Canvas REST API, which uses OAuth 2.0.

## Optional Integrations

Parti has built-in integration with [Google Analytics](http://www.google.com/analytics/) and [StatsD](https://github.com/etsy/statsd). The Google Analytics tracking code is added to all pages. The [nunes gem](https://github.com/jnunemaker/nunes) is used to send a number instrumentation metrics to the StatsD server.

To enable these, simply set the following environment variables before spinning up the service:

* `PARTI_GAID` — The UA-XXXXXXXX-X tracking ID
* `PARTI_STATSD_NAMESPACE_ROOT` — The root namespace for all events sent to StatsD
* `PARTI_STATSD_SERVER` — The hostname of the StatsD server

## Deployment

By default, Parti can be deployed using [Capistrano](http://capistranorb.com) and served with [Phusion Passenger](https://www.phusionpassenger.com). Customize `config/deploy.rb` and environment-specific files in `config/deploy` to fit your production setup.

## Interoperability

Parti largely uses [LTI](https://www.eduappcenter.com/docs/basics/index) to communicate with Canvas. With some code modifications and adjustments, it can be made to work with other learning management systems that support LTI.

Class roster acquisition is currently done through the Canvas REST API + OAuth2.0. LTI v2 has provisions for inspecting the class roster, but the standard was not fully finalized at the time Parti was written. Once it is finalized, it can likely be incorporated into Parti to remove this dependency on the Canvas REST API.

Parti also relies on some Canvas-specific LTI POST parameters: `custom_canvas_course_id` and `custom_canvas_api_domain`. If other generic equivalents become available in the future, those can be used instead for better interoperability.
