# Let's Encrypt: Boulder cookbook

This is a cookbook for provisioning [Boulder][], an
[ACME-based][acme-spec] certificate authority, written in Go. The
Boulder application is an official effort of [Let's Encrypt
project][letsencrypt].

**Warning:** This cookbook was created for testing other cookbooks, not
production purposes.

## Supported Platforms

* Ubuntu 14.04
* Centos 7

## Attributes

|**Key**                                         | **Type**| **Description**                                    |
|------------------------------------------------|---------|----------------------------------------------------|
|`['boulder']['config']['boulder-config']`       | Hash    | Deep-merged into [eponymous config file][config1]. |
|`['boulder']['config']['issuer-ocsp-responder']`| Hash    | Deep-merged into [eponymous config file][config2]. |

## Recipes

### `default`

Install and starts the Boulder server.

## Notes

* Pay close attention to the output of any failed attempts. By default,
  Boulder tries to use all ports in the range 8000 to 8010, among
others. If there is a conflict with other applications, you can use this
cookbook's attributes to force Boulder onto a different port.

* If you're running the boulder server during testing, and it's on the
  same server as the webserver, you'll likely want to edit the
hostsfile. The [`hostfile` cookbook][hostsfile-ckbk] is great for this.

## Development

To tag and publish a new version of this cookbook, first ensure:

* the `metadata.rb` version has been bumped appropriately,
* the `CHANGELOG.md` has been updated, and
* all changes have been committed to git.

Once that has been done:

    bundle exec rake publish

This will create a git tag and push a new release to the Supermarket.

## License and Authors
* Author:: Thijs Houtenbos (@thoutenbos) <thoutenbos@schubergphilis.com>
* Countributor:: Patrick Connolly (@patcon) <patrickcconnolly@gmail.com>

## Sponsors

Code contributions have been generously made by the following
organizations:

* [Schuberg Philis][schubergphilis] (@thoutenbos)
* [Blended Perspectives, Inc.][blendive] (@patcon)

[acme-spec]: https://github.com/letsencrypt/acme-spec/
[letsencrypt]: https://letsencrypt.org/
[boulder]: https://github.com/letsencrypt/boulder/
[schubergphilis]: https://www.schubergphilis.com/
[blendive]: http://www.blendedperspectives.com/
[config1]: https://github.com/letsencrypt/boulder/blob/master/test/boulder-config.json
[config2]: https://github.com/letsencrypt/boulder/blob/master/test/issuer-ocsp-responder.json
[hostsfile-ckbk]: https://github.com/customink-webops/hostsfile
