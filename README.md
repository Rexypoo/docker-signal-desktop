# docker-signal-desktop

A Docker build context to create a clean Docker image with [Signal] Desktop edition for Linux installed.

# Prerequisites

[Docker] 17.05+

# Usage

You can invoke signal desktop with the following command line snippet:

```shell
mkdir -p "$HOME"/.signal-desktop && \
docker run -d --rm \
--name signal-desktop \
--net=host \
-e DISPLAY \
-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
-v "$HOME"/.signal-desktop:/signal \
rexypoo/signal-desktop
```

Here's the explanation:

`mkdir -p "$HOME"/.signal-desktop`

Creates a directory for storing Signal configuration files on the host. This directory should be owned by the user that wishes to run Signal (it may contain secrets belonging to the user).

`docker run -d --rm`

Runs signal-desktop as a daemon (no output to the terminal) and removes the container when closed. Removing the container helps insure you always have the most up-to-date release.

`--name signal-desktop`

Provides a friendly name for the container. This makes it easy to stop a container by running `docker stop signal-desktop`.

`--net=host`

Shares the network interfaces with the docker container.

I haven't yet found a more secure way to ensure Signal has network access.

`-e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro`

Shares the host graphical environment with the docker container, allowing the interface for Signal to render on your desktop.

`-v "$HOME"/.signal-desktop:/signal`

Maps your `~/.signal-desktop` directory to the `/signal` directory inside the container. This allows the container to persistently access your configuration.

If you fail to map the container's `/signal` directory to a persistent volume you will be prompted to link your account every time signal-desktop is run.

`rexypoo/signal-desktop`

This is the name of [this image on DockerHub].

## [Entrypoint Helper]

This image uses an [entrypoint helper] script to manage permissions within the docker container.

The [entrypoint helper] sets permissions inside the image to match the UID and GID of the user who owns the `/signal` directory inside the image.  When you run the command shown in the [usage](usage) section the permissions are set based on whoever on the host owns `$HOME/.signal-desktop`. In most cases this would be the current interactive user.

The owner of `$HOME/.signal-desktop` must also have a valid X-window session corresponding to `/tmp/.X11-unix` and the `$DISPLAY` environment variable.

# License

This project is subject to the MIT license included in this repository.

[Signal] is licensed under [GPLv3]

# Legal

Please be advised that cryptographic software may be illegal to export/import or use in some jurisdictions. The maintainer of this repository is not liable for any violations. 

Per [the Signal team]:
> This distribution includes cryptographic software. The country in which you currently reside may have restrictions on the import, possession, use, and/or re-export to another country, of encryption software. BEFORE using any encryption software, please check your country's laws, regulations and policies concerning the import, possession, or use, and re-export of encryption software, to see if this is permitted. See [http://www.wassenaar.org/](http://www.wassenaar.org/) for more information.

>The U.S. Government Department of Commerce, Bureau of Industry and Security (BIS), has classified this software as Export Commodity Control Number (ECCN) 5D002.C.1, which includes information security software using or performing cryptographic functions with asymmetric algorithms. The form and manner of this distribution makes it eligible for export under the License Exception ENC Technology Software Unrestricted (TSU) exception (see the BIS Export Administration Regulations, Section 740.13) for both object code and source code.

[Docker]: https://www.docker.com
[Signal]: https://signal.org/
[this image on DockerHub]: https://hub.docker.com/r/rexypoo/jupyterlab
[entrypoint helper]: https://github.com/Rexypoo/docker-entrypoint-helper
[GPLv3]: http://www.gnu.org/licenses/gpl-3.0.html
[the Signal team]: https://github.com/signalapp/Signal-Desktop
