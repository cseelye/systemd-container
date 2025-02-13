# systemd-container
Run systemd in a container to test unit files

I built this to quickly test a systemd unit file for starting a container without needing a linux system to run on.

## Usage
The compose file will build and start the container, which should automatically start systemd and launch the container service.
```bash
docker compose up --build
```
