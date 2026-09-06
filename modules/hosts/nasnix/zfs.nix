# Automatically import all discovered non-root ZFS pools on boot.
# The root pool is already imported by the initrd and skipped to avoid conflicts.
{...}: {
  zfs.automatic.import = true;
}
