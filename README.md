# nvqctl

**NVMM/QEMU Virtual Machine Control for NetBSD**

A lightweight CLI tool for managing QEMU virtual machines with NVMM hardware
acceleration on NetBSD. Inspired by Xen's `xl` and OpenBSD's `vmctl`.

## Features

- **Zero dependencies** beyond NetBSD base system + QEMU (socat recommended)
- **Multiple VM management** with per-VM configuration files
- **QEMU command line generation** from simple key=value configs
- **Graceful shutdown** via guest-agent → ACPI → quit → kill
- **Serial console** access via Unix socket
- **QMP monitor** access for advanced QEMU operations
- **rc.d integration** for auto-start/stop VMs at boot
- **VirtIO-first** approach: virtio-blk, virtio-net, virtio-rng
- **POSIX sh** — runs on any NetBSD system without additional interpreters

## Requirements

- NetBSD 10.0 or later (amd64, with NVMM support)
- QEMU with NVMM accelerator (`/usr/pkg/bin/qemu-system-x86_64`)
- CPU with AMD SVM or Intel VMX
- socat (recommended, for interactive console: `pkg_add socat`)

## Installation

### From source (manual)

```sh
git clone https://github.com/hkenken/nvqctl.git
cd nvqctl
make install
```

### From pkgsrc

Copy the pkgsrc package directory to your local pkgsrc tree:

```sh
cp -r nvqctl/pkgsrc/sysutils/nvqctl /usr/pkgsrc/sysutils/nvqctl
cd /usr/pkgsrc/sysutils/nvqctl
make install clean
```

Or via pkgsrc-wip (once submitted):

```sh
cd /usr/pkgsrc/wip/nvqctl
make install clean
```

## Quick Start

```sh
# Create a new VM configuration
nvqctl create myvm

# Edit the configuration
nvqctl config myvm

# Preview the QEMU command line
nvqctl dryrun myvm

# Start the VM
nvqctl start myvm

# Check status
nvqctl list

# Attach serial console (Ctrl-] to detach)
nvqctl console myvm

# Graceful shutdown
nvqctl stop myvm
```

## Commands

| Command | Description |
|---------|-------------|
| `nvqctl list` | List all VMs and their status |
| `nvqctl top [interval]` | Live VM resource monitor |
| `nvqctl start <vm>` | Start a VM |
| `nvqctl stop <vm> [timeout]` | Graceful ACPI/guest-agent shutdown |
| `nvqctl kill <vm>` | Force stop (data loss risk) |
| `nvqctl restart <vm>` | Stop then start |
| `nvqctl reboot <vm>` | Reboot via guest agent |
| `nvqctl status <vm>` | Show detailed VM status |
| `nvqctl console <vm>` | Attach serial console |
| `nvqctl monitor <vm>` | Attach QMP monitor |
| `nvqctl create <vm>` | Create a new VM configuration |
| `nvqctl config <vm>` | Edit VM configuration |
| `nvqctl dryrun <vm>` | Show QEMU command line (dry run) |

## Configuration

### Global Config

`/usr/local/etc/nvqctl/nvqctl.conf` — default values for all VMs.

### Per-VM Config

`/usr/local/etc/nvqctl/vm/<name>.conf` — simple shell-sourceable format:

```sh
NCPU=4
MEMORY=4096
ACCEL=nvmm
CPU=host

DISKS="
  /usr/xendata/myvm/root.img:raw
  /usr/xendata/myvm/home.img:raw
"

NETWORK="
  tap0:52:54:00:12:34:56
  tap1
"

SERIAL=yes
GUEST_AGENT=yes
GUEST_AGENT_METHOD=isa-serial
```

### Disk Format

```
path[:format[:cache]]
```

- `path` — path to disk image (required)
- `format` — `raw` (default) or `qcow2`
- `cache` — `none`, `writeback`, `writethrough`, `directsync`, `unsafe`

### Network Format

```
tap_name[:mac_address]
```

- `tap_name` — host tap interface (required, must be pre-configured)
- `mac_address` — optional, QEMU assigns one if omitted

## Boot Integration

Add to `/etc/rc.conf`:

```sh
nvqctl=YES
nvqctl_vms="myvm1 myvm2"
```

VMs will auto-start at boot and gracefully shut down on host shutdown.

## Shutdown Strategy

`nvqctl stop` tries the following in order:

1. **Guest agent** (`guest-shutdown`) — cleanest, requires qemu-guest-agent
2. **ACPI power button** (`system_powerdown`) — standard, requires ACPI in guest
3. Waits up to `SHUTDOWN_TIMEOUT` seconds (default: 120)

`nvqctl kill` as last resort:

4. **QMP quit** — QEMU process exits
5. **SIGKILL** — if QMP quit fails

## Guest Agent Setup (NetBSD Guest)

NetBSD lacks `virtio_console`, so use `isa-serial` method:

**Host config** (`GUEST_AGENT_METHOD=isa-serial`):
- Adds a second serial port (com1/tty01) for guest-agent communication

**Guest setup**:
```sh
cd /usr/pkgsrc/sysutils/qemu-guest-agent
make install clean

cat > /usr/pkg/etc/qemu/qemu-ga.conf << 'EOF'
[general]
daemon=true
method=isa-serial
path=/dev/tty01
pidfile=/var/run/qemu-ga.pid
logfile=/var/log/qemu-ga/qemu-ga.log
statedir=/var/run
EOF

echo 'qemu_guest_agent=YES' >> /etc/rc.conf
```

Ensure `tty01` is set to `off` in `/etc/ttys` (no getty conflict).

## Comparison with Xen xl

| Xen xl | nvqctl |
|--------|--------|
| `xl create myvm` | `nvqctl start myvm` |
| `xl shutdown myvm` | `nvqctl stop myvm` |
| `xl destroy myvm` | `nvqctl kill myvm` |
| `xl console myvm` | `nvqctl console myvm` |
| `xl list` | `nvqctl list` |
| `xl top` | `nvqctl top` |

## Directory Layout

```
/usr/local/etc/nvqctl/
├── nvqctl.conf           # Global defaults
└── vm/
    └── myvm.conf         # Per-VM config

/var/run/nvqctl/
└── myvm/
    ├── qemu.pid          # QEMU process PID
    ├── monitor.sock      # QMP monitor socket
    ├── serial.sock       # Serial console socket
    └── guest-agent.sock  # Guest agent socket
```

## License

BSD 2-Clause License. See [LICENSE](LICENSE) for details.

## Author

Kenichi Hashimoto
