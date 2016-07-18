# juniper-delete_hanging_sessios_from_bras
On Juniper E-Series (E120, E320) some client's session hangs from time to time. As this Juniper models do not have garbage collector, when too many resources are consumed by hanging sessions, some failure may take place. So, I have to write this script that deletes hanging sessios.

### Requirements

This scripts requires Net::Telnet module to work. I run it from cron on some Unix machine.

### Copyright

  Copyright (c) 2012-2016 Igor Popov

License
-------
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

### Authors

  Igor Popov
  (ipopovi |at| gmail |dot| com)
