# Obtain the application's name from the app's root directory ($1)
read_appname() {
    if [ $(basename "$1") = "current" ]; then
        real_root=$(dirname $1)
    else
        real_root=$(basename $1)
    fi
    basename $real_root
}

# Obtain the path to the default pidfile.
default_pidfile() {
    echo "$PID_DIR/ebloomd.pid"
}

# Execute the given command and store the pidfile in one step
# FIXME: Works with erl only.
with_pid() {
    (
        tag=$(mktemp -t ebloomd)
        $@ -extra $tag
        pid=$(ps auxwww | grep beam | grep "$tag" | awk '{print $2}')
        echo $pid > $(default_pidfile)
    )
}

# Require the default pidfile to not exist.
require_stopped() {
    if [ -f $(default_pidfile) ]; then
        echo "VM is already running (PID: $(default_pidfile))" 1>&2
        exit 1
        # kill $$
    fi
}

# Require the default pidfile to exist.
require_started() {
    if [ ! -f $(default_pidfile) ]; then
        echo "VM is not running (No PID at: $(default_pidfile))" 1>&2
        # kill $$
        exit 1
    fi
}
