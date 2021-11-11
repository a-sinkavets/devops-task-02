## Prerequisites

- docker
- grype (https://github.com/anchore/grype)

Build image
`docker build . -t alek/bitcoin:0.21.0`

Vulnerability scan
`grype alek/bitcoin:0.21.0 --only-fixed --quiet`
