{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  roles = {
    workstation.honkbuilder = {
      enable = true;
      overrides = {
        kernelModules = ["ahci" "ehci_pci"];
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
