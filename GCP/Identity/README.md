# Identity Pool

## Overview
An Identity pool is a container for machine identities that can be configured with all the information required for new Active Directory accounts. In other words, machine identity means computer account. In MCS, an identity pool is a collection of computer accounts for the provisioned machines in a catalog.

### Types of Machine Identities
There are mainly three types of identity types for GCP- 
1. Active Directory joined (AD) 
2. Hybrid Azure Active Directory joined (Hybrid Azure AD) 
3. Non-domain joined (NDJ)

## How to use Identity Pool
There are four scripts in this folder that helps the user perform CRUD (Create, Read, Update, Delete) operations on identity pools for GCP.

1. Create Identity Pool scripts - To create an Identity Pool 
    - [Readme](../Identity/Create%20IdentityPool/README.md) 
2. Get Identity Pool scripts - To get the information of an existing Identity Pool
    - [Readme](../Identity/Get%20IdentityPool/README.md) 
3. Update Identity Pool scripts - To edit different settings on the existing Identity Pool
    - [Readme](../Identity/Update%20IdentityPool/README.md) 
4. Remove Identity Pool scripts - To remove an existing Identity Pool
    - [Readme](../Identity/Remove%20IdentityPool/README.md)