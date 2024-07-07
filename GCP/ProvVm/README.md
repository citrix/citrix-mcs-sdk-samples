# Life cycle of a Virtual Machine in GCP
## Overview
A ProvVM is a Virtual Machine that is created based on a ProvScheme inputs, and ProvScheme can have many ProvVMs. This section contains scripts for various operations, including provisioning a new virtual machine, removing a virtual machine, and retrieving details of a provisioned virtual machine.

A BrokerCatalog contains BrokerMachines. Each ProvVM must have an associated BrokerMachine created in order to view the machine through Citrix Studio, enable power management, and allow for it to be assigned to a delivery group.

The following figure shows a ProvScheme with multiple ProvVMs in it.\
<img src="../../images/GCP-ProvVMsinProvScheme.png" alt="drawing" width="500"/>

The following figure shows a BrokerCatalog with multiple BrokerMachines in it.\
<img src="../../images/GCP-BrokerMachinesInCatalog.png" alt="drawing" width="500"/>

A BrokerMachine will be established in the catalog for each ProvVM in the ProvScheme.\
<img src="../../images/GCP-ProvVMAndBrokerMachine.png" alt="drawing" width="500"/>

This folder contains scripts for various operations, including provisioning a new virtual machine, removing a virtual machine, and retrieving details of a provisioned virtual machine.
1. Add ProvVM scripts - To provision a virtual machine in an existing provisioning scheme
2. Remove ProvVM scripts - To remove/forget/purge an existing virtual machine
3. Get ProvVM scripts - To get the information of an existing virtual machine