# Clean System Restore Points

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Copyright Glen Buktenica](https://img.shields.io/badge/Copyright-Glen_Buktenica-blue.svg)](http://buktenica.com)

Domain joined Windows computers will reset their machine passwords by default every 30 days.  
If a system restore is performed that is older than this the computer will no longer be able to access domain services as its password is now wrong.  
This script prevents that buy reading the age of the Domain Machine Password and deleting all system restore points that are older.  
This script should be scheduled to run daily on all domain joined machines.