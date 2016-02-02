# Let's Encrypt: Boulder cookbook

This is a cookbook for provisioning [**Boulder**][], an
[ACME-based][acme-spec] CA, written in Go. The Boulder application is an
official effort of [Let's Encrypt project][letsencrypt].

**Warning:** This cookbook was created for testing other cookbooks, not
production purposes.

## Supported Platforms

* Ubuntu 14.04
* Centos 7

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['letsencrypt-boulder-server']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### letsencrypt-boulder-server::default

Include `letsencrypt-boulder-server` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[letsencrypt-boulder-server::default]"
  ]
}
```

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
