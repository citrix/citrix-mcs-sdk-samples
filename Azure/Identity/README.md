# Identity Pool

## Overview
An Identity pool is a container for machine identities that can be configured with all the information required for new Active Directory accounts. In other words, machine identity means computer account. In MCS, an identity pool is a collection of computer accounts for the provisioned machines in a catalog.

### Types of Machine Identities
There are mainly four types of identity types -
1. Active Directory joined (AD)
2. Azure Active Directory joined (Azure AD)
3. Hybrid Azure Active Directory joined (Hybrid Azure AD)
4. Non-domain joined (NDJ)

## How to use Identity Pool
There are four scripts in this folder which helps the user to perform CRUD (Create, Read, Update, Delete) operations on identity pools on Azure.

1. Create Identity Pool scripts - To create an Identity Pool
    - [Readme](../Identity/Create%20IdentityPool/README.md)
2. Get Identity Pool scripts - To get the information of an existing Identity Pool
    - [Readme](../Identity/Get%20IdentityPool/README.md)
3. Update Identity Pool scripts - To edit different settings on the existing Identity Pool
    - [Readme](../Identity/Update%20IdentityPool/README.md)
4. Remove Identity Pool scripts - To remove an existing Identity Pool
    - [Readme](../Identity/Remove%20IdentityPool/README.md)

# Identity

## Overview
The concept of identity extends beyond traditional AD accounts to encompass a broader range of account types, including AD, AAD, HAD, and NDJ, providing more comprehensive support and coverage.

## How to use Identity
There are 7 scripts in this folder which helps the user to perform CRUD (Create, Read, Update, Delete) operations on identities on Azure.
1. Add Identity script = To add existing identities into a given identity pool
   - [Readme](../Identity/Add%20Identity/README.md)
2. Get Identity script - To retrieve existing identities and its properties
   - [Readme](../Identity/Get%20Identity/README.md)
3. New Identity script - To create new identity in a given identity pool
   - [Readme](../Identity/New%20Identity/README.md)
4. Remove Identity script - To remove identities from an identity pool.
   - [Readme](../Identity/Remove%20Identity/README.md)
5. Repair and Reset Identity script - To repair/reset an identity's identity/user certificate info.
   - [Readme](../Identity/Repair%20Identity/README.md)
6. Unlock Identity script - To unlock the given identity accounts.
   - [Readme](../Identity/Unlock%20Identity/README.md)
7. Update Identity script - To updates the state of identity accounts in a given identity pool.
   - [Readme](../Identity/Update%20Identity/README.md)