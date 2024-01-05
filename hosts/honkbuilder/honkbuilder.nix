{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  roles = {
    workstation.builder = {
      enable = true;
      overrides = {
        kernelModules = [];
        initrd = {
          availableKernelModules = [
            "uhci_hcd"
            "ehci_pci"
            "ahci"
            "virtio_pci"
            "virtio_scsi"
            "sd_mod"
            "sr_mod"
          ];
        };
      };
    };
  };
}
