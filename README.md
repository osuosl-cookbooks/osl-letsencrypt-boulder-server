# letsencrypt-boulder-server-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

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

Author:: Patrick Connolly (patcon) (<patrick.c.connolly@gmail.com>)
