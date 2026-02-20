GitLab Hetzner Runner
===

This project extends the official gitlab runner image with the [Hetzner docker-machine plugin](https://github.com/JonasProgrammer/docker-machine-driver-hetzner/) by [Jonas Stoehr](https://github.com/JonasProgrammer), so it can run the [CI processes](https://docs.gitlab.com/ee/ci/) on [Hetzner Cloud](https://www.hetzner.com/cloud) instances.

Setup Runner
---

First of all you have to run the image using [docker](https://docker.com) or [podman](https://podman.io). This example will use [docker-compose](https://docs.docker.com/compose/overview/):

```yaml
# docker-compose.yml
version: '2'
services:
  hetzner-runner:
    image: quay.io/shivering-isles/gitlab-hetzner-runner:latest
    mem_limit: 128mb
    memswap_limit: 256mb
    volumes:
      - "./hetzner_config:/etc/gitlab-runner"
      - "./hetzner_machine:/root/.docker/machine"
    restart: always
```

Run the [regular registration process](https://docs.gitlab.com/runner/register/index.html#gnulinux) but replace the 1st and the 6th (Runner executor) with the following:


### For the 1st step run:

```bash
docker-compose run --rm hetzner-runner register
```

### For the 6th step (Runner executor):

```
Please enter the executor: ssh, docker+machine, docker-ssh+machine, kubernetes, docker, parallels, virtualbox, docker-ssh, shell:
 docker+machine
```

Configure Hetzner
---

With the basic runner setup, it's time to configure docker-machine to work with Hetzner.

Login to the [Hetzner Cloud Console](https://console.hetzner.cloud/) and create a new project (even when you already have existing projects, running your CI in an own project helps with isolating possible security issues when the API key gets compromised).

Within the new project, [obtain an API token from Hetzner](https://docs.hetzner.cloud/#overview-getting-started).


Now modify your `config.toml` that appeared in `./hetzner_config` with the following fields:

```toml
# config.toml
[[runners]]
  executor = "docker+machine"
  [runners.docker]
    privileged = true
    volumes = ["/cache"]
  [runners.machine]
    MachineDriver = "hetzner"
    MachineName = "machine-%s-gitlab-runner-2gb"
    MachineOptions = [
       "hetzner-server-type=cx23",
       "hetzner-api-token=<HETZNER API TOKEN>",
       "hetzner-image=ubuntu-22.04"
    ]
```

The result should look similar to this:

```toml
# config.toml
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "hetzner-runner"
  limit = 1
  url = "https://gitlab.com/"
  token = "<RUNNERS GITLAB TOKEN>"
  executor = "docker+machine"
  [runners.docker]
    image = "docker:stable"
    privileged = true
    volumes = ["/cache"]
  [runners.machine]
    IdleCount = 0
    IdleTime = 1800
    MaxBuilds = 200
    MachineDriver = "hetzner"
    MachineName = "machine-%s-gitlab-runner-2gb"
    MachineOptions = [
       "hetzner-server-type=cx21",
       "hetzner-api-token=<HETZNER API TOKEN>",
       "hetzner-image=ubuntu-18.04"
    ]
```

Finally you can run `docker-compose up -d` and your gitlab runner should be ready to use! :smile:

Development
---

If you want to modify the image or build it yourself:

```bash
git clone https://git.shivering-isles.com/shivering-isles/gitlab-hetzner-runner.git
cd gitlab-hetzner-runner
# Do you modifications
# ...
docker build -t "gitlab-hetzner-runner:latest" .
```

If you want to contribute to this image directly, free free to sign up on the [SI GitLab instance](https://git.shivering-isles.com) and request access to [the project](https://git.shivering-isles.com/shivering-isles/gitlab-hetzner-runner).

Workarounds
---

If this error is raised when creating a new machine:
`Error creating machine: Error running provisioning: Unable to verify the Docker daemon is listening: Maximum number of retries (10) exceeded`

It can be solved with the workaround provided in this issue in [docker-machine-driver-hetzner](https://github.com/JonasProgrammer/docker-machine-driver-hetzner/issues/54#issuecomment-899746133) repository

```yaml
[[runners]]
  [runners.machine]
    MachineOptions = [
      """hetzner-user-data=
        #cloud-config
        runcmd:
          - |
            while sleep 1; do
              if [ -e /etc/systemd/system/docker.service.d/10-machine.conf ]; then
                sleep 15
                systemctl restart docker
                break
              fi
            done &
      """
    ]
```


Issues
---

Feel free to report issues to [the issue tracker](https://git.shivering-isles.com/shivering-isles/gitlab-hetzner-runner/issues).
