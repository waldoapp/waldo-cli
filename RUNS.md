# How to trigger runs?

## Auto runs
Currently runs are automatically triggered at each app version upload. 

These runs have a type `auto`.

## Manual runs
You can also use Waldo application to trigger manually runs. First click on the `+` button this will expand a dropdown containing a `Run Tests` section.

These runs are flagged a `manual`.

## CI triggered runs
Lately we introduced a new way of running your tests thanks to a direct call to Waldo’s API.
This is convenient when you want to trigger runs through your CI's script.

To achieve that simply add the following lines into your CI’s script:
```
# Trigger a run
curl -X POST -H "Authorization: Upload-Token $UPLOAD_TOKEN" https://api.waldo.io/suites
```
Where `$UPLOAD_TOKEN` is the same token used to upload your application.

For more details about CI scripts and `$UPLOAD_TOKEN` please refer to `Documentation` section in Waldo application.

This new type of runs has a `ci-trigger` type.