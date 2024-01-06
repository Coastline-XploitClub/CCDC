# CCDC Training Environment Setup Guide

This guide will walk you through setting up a CCDC training environment on a type 1 hypervisor. The guide is broken into two parts. Part 1 will walk you through setting up a Vsphere environment. Part 2 will walk you through setting up a Proxmox environment. The guide assumes you have a basic understanding of virtualization and networking. If you are not familiar with these concepts, please read the following guides before continuing.

## Table of Contents

- [CCDC Training Environment Setup Guide](#ccdc-training-environment-setup-guide)
  - [Part 1: Vsphere Installation](#part-1-vsphere-installation)
    - [1.1: Downloading Vsphere](#11-downloading-vsphere)
    - [1.2: Installing Vsphere](#12-installing-vsphere)
    - [1.3: Configuring Vcenter](#13-configuring-vcenter)
  - [Part 2: Proxmox Installation](#part-2-proxmox-installation)
    - [2.1: Downloading Proxmox](#21-downloading-proxmox)
    - [2.2: Installing Proxmox](#22-installing-proxmox)
    - [2.3: Configuring Proxmox Cluster](#23-configuring-proxmox-cluster)
  - [Part 3: Lab Setup Vsphere](#part-3-lab-setup-vsphere)
    - [3.1: Downloading CCDC VMs](#31-downloading-ccdc-vms)
    - [3.2: Importing CCDC VMs](#32-importing-ccdc-vms)
    - [3.3: Configuring CCDC VMs](#33-configuring-ccdc-vms)
    - [3.4: Configuring CCDC Network](#34-configuring-ccdc-network)
  - [Part 4: Lab Setup Proxmox](#part-4-lab-setup-proxmox)
    - [4.1: Downloading CCDC VMs](#41-downloading-ccdc-vms)
    - [4.2: Importing CCDC VMs](#42-importing-ccdc-vms)
    - [4.3: Configuring CCDC VMs](#43-configuring-ccdc-vms)
    - [4.4: Configuring CCDC Network](#44-configuring-ccdc-network)
  - [Part 5 (Optional): Wireguard VPN Setup](#part-5-optional-wireguard-vpn-setup)
    - [5.1: Creating Wireguard VM](#51-creating-wireguard-vm)
    - [5.2: Configuring Wireguard Server](#52-configuring-wireguard-server)
    - [5.3: Configuring Wireguard Client](#53-configuring-wireguard-client)
    - [5.4: Connecting to Wireguard VPN](#54-connecting-to-wireguard-vpn)

## Part 1: Vsphere Installation

Vsphere is an enterprise type-1 hypervisor from VMware that is used in many enterprise environments. Vsphere is a great choice to host a CCDC training environment because it is used to host the CCDC competition environment, and teams frequently have access to Vsphere during the competition. Familiarity with Vsphere will help teams during the competition and serve as a great learning experience. One downside to Vsphere is the cost for a license needed to host the full CCDC training environment. Obtaining a license for Vsphere is outside the scope of this guide, but a 60 day trial license can be obtained from VMware's website. The trial license will be sufficient for the duration of the CCDC training season. If you are unable to obtain a license, Proxmox is a great alternative that is free and open source.

### 1.1: Downloading Vsphere

- In order to download Vsphere, you will need to create an account on VMware's website. Once you have created an account, you can download the Vsphere installer from the following link: <https://my.vmware.com/en/web/vmware/evalcenter?p=free-esxi8>. The Vsphere installer is a bootable ISO that can be burned to a USB drive using a tool like Rufus or dd in linux.

- Rufus can be downloaded from the following link: <https://rufus.ie/>. Once installed, open Rufus and select the USB drive you would like to burn the Vsphere installer to. Select the Vsphere installer ISO and click start. Rufus will burn the Vsphere installer to the USB drive and make it bootable.  

- If you are using Linux, you can burn the Vsphere installer to a USB drive using the dd command. First, plug in the USB drive and run the following command to find the device name of the USB drive:

    ```bash
    lsblk
    ```

- Next, run the following command to burn the Vsphere installer to the USB drive, substituting the device name of the USB drive for `/dev/sdX` and the path to the Vsphere installer ISO for `/path/to/vsphere/installer.iso`:

    ```bash
    sudo dd if=/path/to/vsphere/installer.iso of=/dev/sdX bs=4M status=progress
    ```

### 1.2: Installing Vsphere

- To install Vsphere, plug the USB drive containing the Vsphere installer into the computer you would like to install Vsphere on and boot from the USB drive. The Vsphere installer will load and you will be presented with the following screens:
\
![Alt text](/Lab%20Setup/png/esxi/esxi-loading-1.png)
![Alt text](/Lab%20Setup/png/esxi/esxi-loading-2.png)

- Once the installer has loaded, you will be presented with the following screen, prompting you to press enter to continue:
\
![Alt text](/Lab%20Setup/png/esxi/esxi-loading-final.png)

- Next, you will be prompted to press `F11` to accept the EULA. Feel free to read the EULA before accepting it.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-eula.png)

- After accepting the EULA, Vsphere will scan for disks to install to. Select the disk you would like to install Vsphere to and press `Enter` to continue. In the following screenshot, 2 disks are shown of equal size. The first disk will be used for the Vsphere installation and the second disk will be used for the CCDC training environment. Feel free to use a single disk for both the Vsphere installation and the CCDC training environment if you do not have multiple disks available.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-disk-selection.png)

- Next, you will be prompted for a root password. This password will be used to log into the Vsphere host and can be changed later. Enter a password that meets the minimum requirements and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-set-password.png)

- You might see a warning about hardware compatibility issues. While it is recommended to use hardware that is on the VMware hardware compatibility list, it is not required. If you see this warning, press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-hardware-override.png)

- Finally, you will be prompted to confirm the installation. Press `F11` to confirm the installation. Note that this will erase all data on the disk you selected in the previous step, so be sure you have selected the correct disk before continuing.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-confirm-install.png)

- The installation should complete relatively quickly and you will be prompted to reboot. Press `Enter` to reboot.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-post-install-reboot.png)

- Once the host has rebooted, you will be presented with the following screen detailing the host's IP address and other information.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-first-boot.png)

- Since the host is currently receiving its IP address from DHCP, the IP address may change after rebooting. We will configure a static IP address and other network settings in the in the management network configuration settings. To access the management network configuration settings, press `F2` and enter the root password you set during the installation.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-system-menu-auth.png)

- Once you have authenticated, you will be presented with the following menu. Select `Configure Management Network` and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-1.png)

- Next, select `IPv4 Configuration` and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-2.png)

- Select `Set static IPv4 address and network configuration` and configure a static IP address, subnet mask, and default gateway. The subnet mask should be consistent with your local network configuration, and the default gateway is typically the IP address of your router or main network access point. Ensure that the static IP address you choose is not already in use and falls outside the DHCP scope of your router to prevent IP address conflicts. Press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-3.png)

- Next, select `DNS Configuration` and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-4.png)

- Select `Use the following DNS server addresses and hostname` and enter the IP address of your DNS server, and alternate DNS server, and a hostname for the host. The primary DNS server is typically the IP address of your router or main network access point. The alternate DNS server can be any public DNS server. In this case, we will use Cloudflare's public DNS server at `1.1.1.1`. Finally, set you hostname to something descriptive like `esxi1`. Press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-5.png)

- Next, select `IPv6 Configuration` and press `Enter` to continue. We are not using IPv6 in this environment, so select `Disable IPv6 (restart required)` and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-ipv6.png)

- With the network configuration complete, press `Esc` to return to the main menu. You will be prompted to reboot to apply the changes. Press `Y` to reboot the host.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-reboot.png)

- Once the host has rebooted, you will be presented with the following screen detailing the host's IP address and other information. Note that the IP address has changed to the static IP address we configured earlier and the hostname has been set to `esxi1`.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-config-mgmt-network-confirm.png)

- For the purposes of this guide, we will be setting up a 4 node Vsphere cluster. Repeat the installation process for each additional node in the cluster. The following screenshots show the network configuration for each node in the cluster. Note that the IP address and hostname are different for each node.
\
![Alt text](/Lab%20Setup/png/esxi/esxi-node-2.png)
![Alt text](/Lab%20Setup/png/esxi/esxi-node-3.png)
![Alt text](/Lab%20Setup/png/esxi/esxi-node-4.png)

### 1.3: Configuring Vcenter

Vcenter is a management server for Vsphere that allows you to manage multiple Vsphere hosts from a single interface. Vcenter is required to create a Vsphere cluster and is used to manage the CCDC training environment. Vcenter is not free, but a 60 day trial license can be obtained from VMware's website. The trial license will be sufficient for the duration of the CCDC training season. Again, Proxmox is a great alternative that is free and open source.

- Vcenter will be installed as a virtual machine on one of the Vsphere hosts. To install Vcenter, you will need to download the Vcenter installer from the following link: <https://my.vmware.com/en/web/vmware/evalcenter?p=free-esxi8>. The Vcenter installer is a bootable ISO that can be burned to a USB drive using a tool like Rufus or dd in linux. The image below shows the correct ISO to download.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-iso.png)

- We will be installing Vcenter on the first Vsphere host we installed. We need to log in to the `esxi1` host to configure the storage for the Vcenter VM. To log in to the `esxi1` host, open a web browser and navigate to the IP address specified during installation. You will be presented with a warning about the site's security certificate. This is expected because we are using a self-signed certificate. Click `Advanced` and then `Accept the risk and Continue` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi1-login-1.png)

- Next, you will be presented with the login screen. Enter the username `root` and password you set during installation and click `Login` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi1-login-2.png)

- Once you have logged in, you will be presented with the following screen. Click `Storage` on the left menu, then `New Datastore` to configure the virtual machine storage datastore.
\
![Alt text](/Lab%20Setup/png/esxi/esxi1-login-3.png)

- Next, select `Create new VMFS Datastore` and click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi1-storage-1.png)

- Select the disk you would like to use for the Vcenter VM and give it an appropriate name. We'll use the second disk on our Vsphere host and use `vm` in this example. Click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi1-storage-2.png)

- Select `VMFS-6` as the file system type and click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/esxi1-storage-3.png)

- Review the summary and click `Finish` to create the datastore.
\
![Alt text](/Lab%20Setup/png/esxi/esxi1-storage-4.png)

- To install Vcenter, mount the Vcenter installer ISO on your host and navigate to the mounted ISO. Navigate to the installation binary for your operating system. In this case, we will be installing Vcenter on a Windows host, so we will navigate to the `vcsa-ui-installer\win32` directory. Run the `installer.exe` file to start the Vcenter installer.
\
![Alt text](/Lab%20Setup/png/esxi/Vcenter-Installer.png)

- The Vcenter installer will load and you will be presented with the following screen. Click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-1.png)

- Next, you will be prompted to accept the EULA. Feel free to read the EULA before accepting it. Click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-2.png)
- Next, you will be prompted to enter the IP address or hostname of the Vsphere host you would like to install Vcenter on, a username, and a password. Enter the IP address of the Vsphere host you would like to install Vcenter on, the username `root`, and the password you set during installation. Click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-3.png)

- Next, you will be prompted to accept the host's SSL certificate. Click `Yes` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-4.png)

- Next, you will be prompted to enter the name of the Vcenter VM, and the root password for the Vcenter VM, Enter a name for the Vcenter VM and a password that meets the minimum requirements. Click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-5.png)

- Next, you will be prompted to select the deployment size. Select `Tiny` and click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-6.png)

- Next, you will be prompted to select the datastore to install Vcenter on. Select the datastore you created earlier and check the box to enable thin disk mode. Click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-7.png)

- Next, you will be prompted to configure the networking for the Vcenter installation. Select the network interface to be used for the management network and configure a static IP address, subnet mask, and default gateway. The subnet mask should be consistent with your local network configuration, and the default gateway is typically the IP address of your router or main network access point. Ensure that the static IP address you choose is not already in use and falls outside the DHCP scope of your router to prevent IP address conflicts. In this example we will use `172.20.10.15` for the Vcenter IP address. Use the same DNS servers that we used for the Vsphere hosts. Click `Next` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-8.png)

- Confirm the installation summary and click `Finish` to begin the installation.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-9.png)

- The installation will take some time to complete. Once the installation is complete, you will be presented with the following screen. Click `Continue to vCenter Server Appliance` to continue.
\
![Alt text](/Lab%20Setup/png/esxi/vcenter-installer-10.png)

## Part 2: Proxmox Installation

### 2.1: Downloading Proxmox

- You can download the Proxmox installer from the following link: <https://www.proxmox.com/en/downloads>. The Proxmox installer is a bootable ISO that can be burned to a USB drive using a tool like Rufus or dd in linux.

  - *Make sure to download the Proxmox VE ISO and not the Proxmox Backup Server ISO.*

- Rufus can be downloaded from the following link: <https://rufus.ie/>. Once installed, open Rufus and select the USB drive you would like to burn the Proxmox installer to. Select the Proxmox installer ISO and click start. Rufus will burn the Proxmox installer to the USB drive and make it bootable.  

- If you are using Linux, you can burn the Proxmox installer to a USB drive using the dd command. First, plug in the USB drive and run the following command to find the device name of the USB drive:

    ```bash
    lsblk
    ```

- Next, run the following command to burn the Proxmox installer to the USB drive, substituting the device name of the USB drive for `/dev/sdX` and the path to the Proxmox installer ISO for `/path/to/proxmox/installer.iso`:

  ```bash
  sudo dd if=/path/to/proxmox/installer.iso of=/dev/sdX bs=4M status=progress
  ```

### 2.2: Installing Proxmox

![Alt text](/Lab%20Setup/png/proxmox/proxmox-boot.png)
Start by booting from the Proxmox installer USB drive. You will be presented with the following screen. Select `Install Proxmox VE (Graphical)` and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-eula.png)
Accept the EULA by selecting `I agree to the terms of the end user license agreement` and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-zfs-1.png)
There are several options for configuring the storage for Proxmox. For the purposes of this guide, we will be using ZFS. Select `ZFS (RAID1)` and press `Enter` to continue. ZFS is a file system that provides data integrity, compression, and other features. ZFS is a great choice for a Proxmox installation because it is easy to configure and provides data integrity features that are not available with other file systems.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-language.png)
Select your language and time zone and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-password.png)
Configure a password for the root user and press and an email address for notifications. Press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-network.png)
Select the network interface to be used for the management network and configure a static IP address, subnet mask, and default gateway. The subnet mask should be consistent with your local network configuration, and the default gateway is typically the IP address of your router or main network access point. Ensure that the static IP address you choose is not already in use and falls outside the DHCP scope of your router to prevent IP address conflicts. Press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-confirm-install.png)
Review the installation summary and press `Enter` to continue.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-install-reboot.png)
Once the installation is complete, you will be prompted to reboot. Press `Enter` to reboot.
\
![Alt text](/Lab%20Setup/png/proxmox/proxmox-first-boot.png)
If the installation was successful, you will be presented with the following screen detailing the host's IP address and other information.
\

### 2.3: Configuring Proxmox Cluster

## Part 3: Lab Setup Vsphere

### 3.1: Downloading CCDC VMs

### 3.2: Importing CCDC VMs

### 3.3: Configuring CCDC VMs

### 3.4: Configuring CCDC Network

## Part 4: Lab Setup Proxmox

### 4.1: Downloading CCDC VMs

### 4.2: Importing CCDC VMs

### 4.3: Configuring CCDC VMs

### 4.4: Configuring CCDC Network

## Part 5 (Optional): Wireguard VPN Setup

### 5.1: Creating Wireguard VM

### 5.2: Configuring Wireguard Server

### 5.3: Configuring Wireguard Client

### 5.4: Connecting to Wireguard VPN
