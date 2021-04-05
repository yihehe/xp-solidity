Verifying Education and Experience

The recruiting process for any organization is long and rigorous, and one of the most time consuming steps is verifying what the applicant says is true, which typically requires background checks and calling on their references. What we will explore in this project is solving the problem verifying an individual's educational and professional experience in a trusted and verifiable way using blockchains.

|     Caller     | Function |                                 What it does                                  |                   Inputs                    |                    Storage                     | TX? |
|----------------|----------|-------------------------------------------------------------------------------|---------------------------------------------|------------------------------------------------|-----|
| Candidate C    | propose  | Propose some experience O at organization O                                   | Organization O address Hash of experience E | Experience { Organization Hash Not certified } | yes |
| Organization O | certify  | Certifies the hash of some experience E                                       | Hash of experience E                        | Experience { Organization Hash Certified }     | yes |
| Candidate C    | grant    | Grants permission to Organization R by providing the encrypted list of hashes | Encrypted list of hashes                    | Permission { Encrypted }                       | yes |
| Organization R | request  | Fetch the latest encrypted hash                                               | Candidate address                           |                                                | no  |
| Organization R | verify   | Verifies a list of hashes has been certified                                  | Candidate C address List of hashes          |                                                | no  |

