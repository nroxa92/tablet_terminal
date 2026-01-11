PS C:\Projekti\AI_VILLA\villa_admin> cd functions
PS C:\Projekti\AI_VILLA\villa_admin\functions> firebase deploy --only functions

=== Deploying to 'vls-admin'...

i  deploying functions
i  functions: preparing codebase default for deployment
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
i  functions: ensuring required API cloudbuild.googleapis.com is enabled...
i  artifactregistry: ensuring required API artifactregistry.googleapis.com is enabled...
!  functions: package.json indicates an outdated version of firebase-functions. Please upgrade using npm install --save firebase-functions@latest in your functions directory.
!  functions: Please note that there will be breaking changes when you upgrade.
i  functions: Loading and analyzing source code for codebase default to determine what to deploy
Serving at port 8180

i  extensions: ensuring required API firebaseextensions.googleapis.com is enabled...
i  functions: preparing functions directory for uploading...
i  functions: packaged C:\Projekti\AI_VILLA\villa_admin\functions (82.03 KB) for uploading
i  functions: ensuring required API cloudscheduler.googleapis.com is enabled...
i  functions: ensuring required API run.googleapis.com is enabled...
i  functions: ensuring required API eventarc.googleapis.com is enabled...
i  functions: ensuring required API pubsub.googleapis.com is enabled...
i  functions: ensuring required API storage.googleapis.com is enabled...
i  functions: generating the service identity for pubsub.googleapis.com...
i  functions: generating the service identity for eventarc.googleapis.com...
i  functions: ensuring required API secretmanager.googleapis.com is enabled...
+  functions: functions source uploaded successfully
i  functions: creating Node.js 20 (2nd Gen) function distributeApkUpdate(europe-west3)...
i  functions: creating Node.js 20 (2nd Gen) function sendSystemNotification(europe-west3)...
i  functions: creating Node.js 20 (2nd Gen) function getBrandInfo(europe-west3)...
i  functions: creating Node.js 20 (2nd Gen) function initializeSystem(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function createOwner(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function linkTenantId(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function listOwners(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function deleteOwner(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function resetOwnerPassword(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function toggleOwnerStatus(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function translateHouseRules(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function registerTablet(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function tabletHeartbeat(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function translateNotification(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function addSuperAdmin(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function removeSuperAdmin(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function listSuperAdmins(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function scheduledBackup(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function manualBackup(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function getAdminLogs(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function sendEmailNotification(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function onBookingCreated(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function sendCheckInReminders(europe-west3)...
i  functions: updating Node.js 20 (2nd Gen) function updateEmailSettings(europe-west3)...
+  functions[registerTablet(europe-west3)] Successful update operation.
+  functions[listSuperAdmins(europe-west3)] Successful update operation.
Could not create or update Cloud Run service onbookingcreated, Container Healthcheck failed. Quota exceeded for total allowable CPU per project per region.

Logs URL: https://console.cloud.google.com/logs/viewer?project=vls-admin&resource=cloud_run_revision/service_name/onbookingcreated/revision_name/onbookingcreated-00003-qil&advancedFilter=resource.type%3D%22cloud_run_revision%22%0Aresource.labels.service_name%3D%22onbookingcreated%22%0Aresource.labels.revision_name%3D%22onbookingcreated-00003-qil%22
For more troubleshooting guidance, see https://cloud.google.com/run/docs/troubleshooting#container-failed-to-start
+  functions[deleteOwner(europe-west3)] Successful update operation.
+  functions[updateEmailSettings(europe-west3)] Successful update operation.
+  functions[createOwner(europe-west3)] Successful update operation.
Could not create or update Cloud Run service resetownerpassword, Container Healthcheck failed. Quota exceeded for total allowable CPU per project per region.

Logs URL: https://console.cloud.google.com/logs/viewer?project=vls-admin&resource=cloud_run_revision/service_name/resetownerpassword/revision_name/resetownerpassword-00004-nup&advancedFilter=resource.type%3D%22cloud_run_revision%22%0Aresource.labels.service_name%3D%22resetownerpassword%22%0Aresource.labels.revision_name%3D%22resetownerpassword-00004-nup%22
For more troubleshooting guidance, see https://cloud.google.com/run/docs/troubleshooting#container-failed-to-start
Could not create or update Cloud Run service sendcheckinreminders, Container Healthcheck failed. Quota exceeded for total allowable CPU per project per region.

Logs URL: https://console.cloud.google.com/logs/viewer?project=vls-admin&resource=cloud_run_revision/service_name/sendcheckinreminders/revision_name/sendcheckinreminders-00003-rub&advancedFilter=resource.type%3D%22cloud_run_revision%22%0Aresource.labels.service_name%3D%22sendcheckinreminders%22%0Aresource.labels.revision_name%3D%22sendcheckinreminders-00003-rub%22
For more troubleshooting guidance, see https://cloud.google.com/run/docs/troubleshooting#container-failed-to-start
+  functions[initializeSystem(europe-west3)] Successful create operation.
+  functions[getAdminLogs(europe-west3)] Successful update operation.
+  functions[sendSystemNotification(europe-west3)] Successful create operation.
+  functions[manualBackup(europe-west3)] Successful update operation.
+  functions[removeSuperAdmin(europe-west3)] Successful update operation.
Could not create or update Cloud Run service addsuperadmin, Container Healthcheck failed. Quota exceeded for total allowable CPU per project per region.

Logs URL: https://console.cloud.google.com/logs/viewer?project=vls-admin&resource=cloud_run_revision/service_name/addsuperadmin/revision_name/addsuperadmin-00003-hun&advancedFilter=resource.type%3D%22cloud_run_revision%22%0Aresource.labels.service_name%3D%22addsuperadmin%22%0Aresource.labels.revision_name%3D%22addsuperadmin-00003-hun%22
For more troubleshooting guidance, see https://cloud.google.com/run/docs/troubleshooting#container-failed-to-start
+  functions[tabletHeartbeat(europe-west3)] Successful update operation.
+  functions[distributeApkUpdate(europe-west3)] Successful create operation.
+  functions[scheduledBackup(europe-west3)] Successful update operation.
Could not create or update Cloud Run service getbrandinfo, Container Healthcheck failed. Quota exceeded for total allowable CPU per project per region.

Logs URL: https://console.cloud.google.com/logs/viewer?project=vls-admin&resource=cloud_run_revision/service_name/getbrandinfo/revision_name/getbrandinfo-00001-cug&advancedFilter=resource.type%3D%22cloud_run_revision%22%0Aresource.labels.service_name%3D%22getbrandinfo%22%0Aresource.labels.revision_name%3D%22getbrandinfo-00001-cug%22
For more troubleshooting guidance, see https://cloud.google.com/run/docs/troubleshooting#container-failed-to-start
+  functions[linkTenantId(europe-west3)] Successful update operation.
+  functions[toggleOwnerStatus(europe-west3)] Successful update operation.
+  functions[listOwners(europe-west3)] Successful update operation.
+  functions[translateNotification(europe-west3)] Successful update operation.
+  functions[translateHouseRules(europe-west3)] Successful update operation.
+  functions[sendEmailNotification(europe-west3)] Successful update operation.

Functions deploy had errors with the following functions:
        addSuperAdmin(europe-west3)
        getBrandInfo(europe-west3)
        onBookingCreated(europe-west3)
        resetOwnerPassword(europe-west3)
        sendCheckInReminders(europe-west3)
Error: There was an error deploying functions:
- Error Failed to update function onBookingCreated in region europe-west3
- Error Failed to update function resetOwnerPassword in region europe-west3
- Error Failed to update function sendCheckInReminders in region europe-west3
- Error Failed to update function addSuperAdmin in region europe-west3
- Error Failed to create function getBrandInfo in region europe-west3
PS C:\Projekti\AI_VILLA\villa_admin\functions> firebase deploy --only functions

=== Deploying to 'vls-admin'...

i  deploying functions
i  functions: preparing codebase default for deployment
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
i  functions: ensuring required API cloudbuild.googleapis.com is enabled...
i  artifactregistry: ensuring required API artifactregistry.googleapis.com is enabled...
!  functions: package.json indicates an outdated version of firebase-functions. Please upgrade using npm install --save firebase-functions@latest in your functions directory.
!  functions: Please note that there will be breaking changes when you upgrade.
i  functions: Loading and analyzing source code for codebase default to determine what to deploy
Serving at port 8242


Error: User code failed to load. Cannot determine backend specification. Timeout after 10000. See https://firebase.google.com/docs/functions/tips#avoid_deployment_timeouts_during_initialization'
PS C:\Projekti\AI_VILLA\villa_admin\functions> npm install
npm warn EBADENGINE Unsupported engine {
npm warn EBADENGINE   package: 'vls-functions@6.0.0',
npm warn EBADENGINE   required: { node: '20' },
npm warn EBADENGINE   current: { node: 'v24.12.0', npm: '11.6.2' }
npm warn EBADENGINE }

up to date, audited 509 packages in 7s

68 packages are looking for funding
  run `npm fund` for details

2 vulnerabilities (1 moderate, 1 high)

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
PS C:\Projekti\AI_VILLA\villa_admin\functions> 