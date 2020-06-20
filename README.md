# CS-Studio Phoebus in Docker

This is an effort to "dockerize" [CS-Studio Phoebus][Phoebus],
a control system GUI for EPICS.
Phoebus is free software licensed under the terms of the Eclipse
Public License 1.0 and is published [on Github][Phoebus on Github].

Pre-built images can be found [on the Docker Hub][/r/pklaus/phoebus].

### Running the GUI on the host's X11 Server

```bash
KEY=$(xauth list | grep "$(hostname)/unix:0" | awk '{ print $3 }' | head -n 1)
CONT_HOSTNAME=docker-phoebus
xauth add $CONT_HOSTNAME/unix:0 . $KEY

docker run \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/.Xauthority:/tmp/.Xauthority \
    -v /dev/snd:/dev/snd \
    -e DISPLAY=unix$DISPLAY \
    -e XAUTHORITY=/tmp/.Xauthority  \
    -h $CONT_HOSTNAME \
    --device=/dev/dri:/dev/dri \
    --rm -it \
  pklaus/phoebus

xauth remove $CONT_HOSTNAME/unix:0
```

Phoebus can be started with further arguments/options by providing them
as additional commands at the end of the run statement.
(For the Docker experts: Phoebus' product.jar is the Docker `ENTRYPOINT`.)
Here are a couple of examples, for a full list, check out the
[documentation on starting Phoebus][].

* `-list` to show all options available for startup and exit,
* `-resource pv://?root:aiExample\&root:ai2\&app=databrowser` to open
  the databrowser with the specified PVs,
* `-settings /storage/phoebus_settings.ini` to start with
  a custom (e.g. bind-mounted) settings file.

### History

The first packaging of phoebus for Docker happened in May 2019
in the context of the CSS/RDB Archiver (aka beauty):
<https://github.com/pklaus/beauty_docker/commits/master/phoebus>

[Phoebus]: https://controlssoftware.sns.ornl.gov/css_phoebus/
[/r/pklaus/phoebus]: https://hub.docker.com/r/pklaus/phoebus
[Phoebus on Github]: https://github.com/ControlSystemStudio/phoebus
[documentation on starting Phoebus]: https://control-system-studio.readthedocs.io/en/latest/running.html
