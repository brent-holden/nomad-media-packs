# Unmanic Pack

This pack deploys [Unmanic](https://github.com/Unmanic/unmanic) to Nomad, with optional backup, restore, and version update jobs. Unmanic is a library optimizer that automatically converts media files to a chosen format using hardware-accelerated transcoding.

## Prerequisites

1. **Nomad Variables** - Set the Unmanic version:
   ```bash
   nomad var put nomad/jobs/unmanic version="latest"
   ```

2. **Host Volumes** - Configure on your Nomad clients:
   - `unmanic-config` - Persistent configuration storage

3. **CSI Volumes** - Configure storage:
   - `media-drive` - Your media library
   - `backup-drive` - Backup storage (if `enable_backup=true`)

4. **GPU (Optional but recommended)** - For hardware transcoding with Intel Arc B580:
   - Ensure `/dev/dri/card1` and `/dev/dri/renderD129` exist on the host
   - See [GPU Driver Setup](#gpu-driver-setup) below

## GPU Driver Setup

The container's bundled Intel media driver does not support AV1 encoding on the Arc B580 (Battlemage). When `gpu_transcoding=true`, this pack bind-mounts the host's Intel media driver and gmmlib into the container to provide full AV1 hardware encoding support.

### Host requirements

The following must be installed on the Nomad client host:

- **Kernel**: 6.13+ recommended (ELRepo `kernel-ml` on CentOS Stream 10)
- **intel-media-driver**: 25.4.6+ built from source with gmmlib 22.9.0+
  - Installed to `/usr/lib64/dri/iHD_drv_video.so`
  - gmmlib at `/usr/lib64/libigdgmm.so.12.9.0`
- **GPU firmware**: On-device GSC firmware must be updated via `igsc` (minimum version 21.1174+)
- **Resizable BAR**: Must be enabled in BIOS

### Building intel-media-driver from source

```bash
# Install gmmlib 22.9.0
git clone --depth 1 --branch intel-gmmlib-22.9.0 https://github.com/intel/gmmlib.git
cd gmmlib && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib64
make -j$(nproc) && sudo make install

# Build intel-media-driver 25.4.6
git clone --depth 1 --branch intel-media-25.4.6 https://github.com/intel/media-driver.git
cd media-driver && mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib64 \
  -DENABLE_KERNELS=ON -DENABLE_NONFREE_KERNELS=ON \
  -DBUILD_CMRTLIB=OFF -DMEDIA_RUN_TEST_SUITE=OFF
make -j$(nproc) && sudo make install
```

### Flashing GPU firmware with igsc

```bash
# Build igsc
git clone https://github.com/intel/igsc.git
cd igsc && git submodule update --init
mkdir build && cd build && cmake .. && make -j$(nproc) && sudo make install

# Check current firmware version
sudo igsc fw version --device /dev/mei1

# Flash latest firmware (get from https://github.com/Solaris17/Arc-Firmware)
sudo igsc fw update --device /dev/mei1 --image bmg_g21_fwupdate.bin -a

# Reboot after flashing
sudo reboot
```

## Usage

```bash
# Deploy with defaults (GPU enabled, backup enabled, update enabled)
nomad-pack run packs/unmanic

# Deploy without GPU transcoding
nomad-pack run packs/unmanic -var gpu_transcoding=false

# Deploy without backup job
nomad-pack run packs/unmanic -var enable_backup=false

# Deploy with custom resources
nomad-pack run packs/unmanic -var cpu=8000 -var memory=8192
```

## Jobs Created

This pack creates up to 4 Nomad jobs:

| Job | Description | Controlled By |
|-----|-------------|---------------|
| `unmanic` | Main Unmanic service | Always created |
| `unmanic-backup` | Periodic backup of config, database, and plugins | `enable_backup` |
| `unmanic-update` | Periodic version check from Docker Hub | `enable_update` |
| `unmanic-restore` | Parameterized restore job (dispatch manually) | `enable_restore` |

## Variables

### Service Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `job_name` | Name of the Nomad job | `unmanic` |
| `datacenters` | Eligible datacenters | `["dc1"]` |
| `region` | Nomad region | `global` |
| `namespace` | Nomad namespace | `default` |
| `image` | Container image | `docker.io/josh5/unmanic:latest` |
| `gpu_transcoding` | Enable GPU passthrough and host driver mounts | `true` |
| `gpu_devices` | GPU device mappings (host:container) | `card1`, `renderD129` |
| `unmanic_uid` | UID for Unmanic user | `1002` |
| `unmanic_gid` | GID for Unmanic group | `1001` |
| `timezone` | Container timezone | `America/New_York` |
| `cpu` | CPU allocation (MHz) | `4000` |
| `memory` | Memory allocation (MB) | `4096` |
| `port` | Unmanic web UI port | `8888` |
| `media_volume_name` | CSI volume name | `media-drive` |
| `config_volume_name` | Config host volume | `unmanic-config` |
| `cache_path` | Host path for encoding cache | `/tmp/unmanic` |
| `register_consul_service` | Register with Consul | `true` |
| `consul_service_name` | Consul service name | `unmanic` |

### Backup Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_backup` | Enable backup job | `true` |
| `backup_cron_schedule` | Backup schedule | `0 2 * * *` (2am daily) |
| `backup_volume_name` | CSI volume for backups | `backup-drive` |
| `backup_retention_days` | Days to retain backups | `14` |

### Update Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_update` | Enable update job | `true` |
| `update_cron_schedule` | Update schedule | `0 3 * * *` (3am daily) |
| `nomad_variable_path` | Nomad variable path | `nomad/jobs/unmanic` |

### Restore Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_restore` | Enable restore job | `false` |

## Access

After deployment, access Unmanic at: `http://<nomad-client-ip>:8888`
