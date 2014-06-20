## README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

### Ruby version

Zmey should run fine on Ruby 2.0 or above. It is currently in use on MRI
Ruby 2.1.1.

### System dependencies

Zmey uses ImageScience, which depends on FreeImage, for image resizing. See
http://docs.seattlerb.org/ImageScience.html for details.

### Environment variables

#### ZMEY_ASSETS

Location of additional assets. This allows a website's custom assets to be
stored outside of the core Zmey repository.

#### ZMEY_REPOSITORY

URL of the git repository. Used when deploying with Capistrano.

#### ZMEY_THEMES

Location of themes that will override the core views. Use this to theme
websites without modifying views in the core repository. To use external
themes, set a website's custom view resolver attribute to
`CustomView::ThemeResolver`. Themes are looked up in `ZMEY_THEMES/subdomain`
where subdomain is the website's subdomain attribute.
