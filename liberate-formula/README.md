# Liberate formula

This formula converts your systems from EL clones, Like CentOS 7 or even RHEL 9, to SUSE Liberty Linux. This method is meant to perform the conversion during the minion onboarding on [Uyuni](https://www.uyuni-project.org/) / [SUSE Manager](https://www.suse.com/products/suse-manager/), which is a tool for system management, patching deployment and automation.

This is the result of the Hackweek 23 project 
[Use Uyuni to migrate EL linux to SLL](https://hackweek.opensuse.org/23/projects/use-uyuni-to-migrate-el-linux-to-sll).

## Quickstart

### Deploy Uyuni / SUSE Manager
First requirement is to have [SUSE Manager 4.3](https://www.suse.com/download/suse-manager/) running. 

- Requirement: Use SUSE Manager 4.3
- Get Software
  - In a cloud provider search in the marketplace for SUSE Manager
  - If you want to use a VM of physical hardware go to [SUSE Manager Downloads](https://www.suse.com/download/suse-manager/)
    - Install SUSE Manager following [Documentation](https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/install-server-unified.html)
  - Complete initial SUSE Manager setup following [Documentation](https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/server-setup.html)


### Install the formula
We will be installing the formula from an RPM created in the Open Build Service

- Install formula
  - `zypper in liberate-formula`

### Configuring SUSE Manager
Now it's time to start basic configuration to have all the software channels for [SUSE Liberty Linux](https://www.suse.com/products/suse-liberty-linux/) available for the conversion.

- Provide SUSE Customer Center credentials
  - Log in to [SUSE Customer Center](https://scc.suse.com)
    - Go to `My Organization`, select your organization
    - Go to `Users` -> `Organization Credentials` and copy your Organization Username and Password
  - In your own instance of SUSE Manager
    - Go to `Admin` -> `Setup Wizard` -> `Organization Credentials`
    - Click on `Add new credential` And use the Username and Password provided in SCC and obtained in previous step
- Sync the SLL/SLES-ES channels in SUSE Manager
  - Go to `Admin` -> `Setup Wizard` -> `Products`
  - Select the SUSE Liberty Linux Channels that you will use:
    - EL7: `SUSE Linux Enterprise Server with Expanded Support 7 x86_64`
    - EL8: `RHEL or SLES ES or CentOS 8 Base`
    - EL9: `RHEL and Liberty 9 Base`
  - Click on the top right button `+ Add products`
  - Initial sychronization can take considerable time.  You can check progress by accessing the SUSE Manager machine via SSH and monitoring the logs using `tail -f /var/log/rhn/reposync/*`
- Create one Activation Key per [SUSE Liberty Linux](https://www.suse.com/products/suse-liberty-linux/) parent channel
  - Note: Activation Keys are the way to register systems and automatically assign them to the required software and configuration channels corresponding to them
  - Go to `Systems` -> `Activation Keys` and click on the top right message `+ Create key`
  - Then in the new Activation Key, add the following content:
    - `Description`: with some tech describing the acitvation key
    - `Key`: With the identifier for the key, for example `sll9-default` for your EL9 systems
      - Note: Keis will have a nimeric prefix depending ont he organization so that there are not to equal keys in the same SUSE Manager
    - `Usage`: Leave blank
    - `Base Channel`: Select one base channel. Depending on your EL version the base channel will be:
        - EL7: `RHEL x86_64 Server 7`
        - EL8: `RHEL8-Pool for x86_64`
        - EL9: `EL9-Pool for x86_64`
    - `Child Channel`
      - Use `include recommended` where available or select all if unavailable
    - `Add-On system type`: Leave all blank
    - `Contact Method`: Default
    - `Universal Default`: Leave unchecked
    - Click on `Create Activation Key`

### Adding Liberate Formula to SUSE Manager and assign it to activation keys
The Liberate Formula is available as an RPM (See 'Install formula' steps above).

Now we can assign the formula to an Activation Key by creating a System Group

 - Go to `Systems` -> `System Groups`
   - Go to the top right corner and click on `+ Create Group`
   - Add the following data:
     - `Name`: liberate
     - `Description`: Systems to be converted to SUSE Liberty Linux
   - Once in the `liberate` System Group page you can go to the tab `Formulas`
     - Select the `Liberate` and click on the `Save` button. 
       - A new tab called `Liberate` will apear.
       - You can switch to the `Liberate` tab and find the `Reinstall all packages after conversion` option
         - Please keep this option selected if you want to reinstall all the packages during conversion to ensure they have SUSE signatures and you do not keep any previous package
         - If you prefer you can de-select this box and perform the reinstallation afterwards. If you do so, remember to click on the `Save Formula` button

We have now a System Group that has assigned the `Liberate` formula. This formula will only apply once to convert the system to SUSE Liberty Linux, even if you run it multiple times. Now it's time to assign it to the Activation Key

 - Assign the System Group to the activation key
  - Go to `Systems` -> `Activation Keys`
  - Select the Activation Key, for example `sll9-default` for your EL9 systems
    - In the Activation Key page go to `Groups` tab
      - In the Group tab go to the `Join` tab, then select the `liberate` group and click on the `Join Selected Groups` button
      The group will be assigned to the Activation Key
    - To apply the conversion directly during registration, in the Activation Key Page, go to the `Details` tab
      - Go to `Configuration File Deployment` section and select the checkbox `Deploy configuration files to systems on registration`
      - Then click on `Update Activation Key`

This way when you register a system with this key it will perform the conversion automatically

### Registering a new system to SUSE Manager and proceed to the conversion
- There are two ways to onboard, or register, a new system (a.k.a. minion) with the Activation Key
  - Onboarding a new system *using webUI* and selecting the activation key
    ```Note: This is intended for a one-off registration or for testing purposes```
    - Go to `Systems` -> `Bootstraping`
      - In the `Bootstrap Minions` page fill the entries
      - Note: this will start an SSH connection to the system and run the bootstrap script to register it to SUSE Manager
      - `Host`: Hostname of the system to onboard
      - `SSH Port`: Leave blank to use default, which is `22`
      - `User`: type user or leave blank for `root`
      - `Authentication Method`: Select if you want to use `password` or provide a `SSH Private Key`
        - `Password`: If this was selected please provide the password to access the system
        - `SSH Private Key`: If this was selected please provide the file with the private key
          - `SSH Private Key Passphrase`: In case a private key was provided that requires a passphrase to unlock, please provide it here.
      - `Activation Key`: Select from the menu the Activation key to be used, for example `sll9-default`.
      - `Reactivation Key`: Leave blank it wont be used here
      - `Proxy`: Leave as `None` as it is used for the SUSE Manager specific proxies.
      - Click on the `+ Bootstrap` button to start the registration
      - Note: A message will show in the top of the page stating that the system is being registered, or "bootstraped" in SUSE Manager parlance.
  - Onboarding a new system using a *bootstrap script* with an assigned Activation key
    ```Note: This is intended to be used for mass registration```
    - In the left menu, go to `Admin` -> `Manager Configuration` -> `Bootstrap Script`, to reach the bootstrap script configuration. Let's fill the fields here.
      - `SUSE Manager server hostname`: This should be set to the hostname that the client systems (a.k.a. minions) will use to reach SUSE Manager, as well as the SUSE Manager hostname
        - Note: a Certificate will be used associated to this name for the client systems, as it was configured in the initial setup. If it's changed, a new certificate shall be created
      - `SSL cert location`: Path, in the SUSE Manager server, to the filename provided as a certificate to register it. Please keep it as it is.
      - `Bootstrap using Salt`: Select this checkbox to apply salt states, like the one we added via configuration channel. It is required to perform the conversion.
      - `Enable Client GPG checking`: Select this checkbox to ensure all packages installed come from the proper sources, in this case, SUSE Liberty Linux signed packages.
      - `Enable Remote Configuration`: Leave unchecked.
      - `Enable Remote Commands`: Leave unchecked.
      - `Client HTTP Proxy`: Leave blank. This is in case the client requires a proxy to access the SUSE Manager server.
      - `Client HTTP Proxy username`: Leave blank.
      - `Client HTTP Proxy password`: Leave blank.
      - Click now in the `Update` button to refresh the bootstrap script `bootstrap.sh`
        - Bootstrap script generated is reachable via web by accesing the server path `/pub/bootstrap/`, for example for a server named `suma.suse.lab` it will be at https://suma.suse.lab/pub/bootstrap/
        - Accessing SUSE Manager server via SSH the bootstrap script is available in `/srv/www/htdocs/pub/bootstrap/`
          - Copy the bootstrap script in `/srv/www/htdocs/pub/bootstrap/` by running `cp bootstrap.sh bootstrap-sll9.sh`
          - Edit `bootstrap-sll9.sh` and add the activation key you want to use, i.e. `sll9-default` to the line `ACTIVATION_KEYS=` leaving it as `ACTIVATION_KEYS=sll9-default`
          - Run the newly created bootstrap script, i.e. `bootstrap-sll9.sh`, in the machines to be registered and converted
            - A quick way to do it is by running `curl -Sks https://your.suma.server/pub/bootstrap/bootstrap-sll9.sh | /bin/bash` as root in the machine
- Configuration channel and software channels will be assigned automatically by the Activation Key
- Apply high state and the minion will be migrated to SLL/SLES-ES
  - The high state apply will both apply the configuration channel and migrate the machine to Liberty Linux

## Version testing status

| OS version  | Status  |
| ----------- | ------- |
| Rhel 9      | Working |
| Rocky 9     | Working |
| Alma 9      | Working |
| Oracle 9    | Working |
| Rhel 8      | Working |
| Rocky 8     | Working |
| Alma 8      | Working |
| Oracle 8    | Working |
| Rhel 7      | Not Tested |
| CentOS 7    | Working |
| Oracle 7    | Working |
