intel_iommu_kernel_param:
  bootloader.kernel_param:
    - name: intel_iommu
    - value: {{ '"on"' if grains['cpu_vendor'] == 'GenuineIntel' and pillar['iommu'] else 'null' }}
