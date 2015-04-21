## Features

* make ui router work without trailing slashes

* manage access keys

* ignore invalid data in submitted test payloads
  * store and display encountered errors

* display a graph of test counters

* purge remaining data
  * action to purge all data in purge control panel
  * purge outdated tests
  * purge test deprecations
  * purge purge actions

* make sure test payloads are processed even if one of the jobs fails

* find a way to make report generation faster
  * it must also be future-proof as 2000-result reports already take up to 10 minutes to be rendered

# Improvements

* use foreigner-matcher to test foreign keys (including dependent option)
* allow to configure test run purge throttling delay
* list of test payloads with processing time for admins
* redirect link to last test run for project
* replace user factories by one
* badges
