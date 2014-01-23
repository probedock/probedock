this.Translations.en =
  common:
    noData: "-"
    topLink: "Back to top"
    unexpectedModelError: "Record could not be saved"
    edit: "Edit"
    save: "Save"
    cancel: "Cancel"
    create: "Create"
    delete: "Delete"
    loading: "Loading..."
    alert:
      danger: "Oops!"
      warning: "Warning."
    "true": "yes"
    "false": "no"
  application:
    maintenance:
      title: "Maintenance Mode."
      notice: "ROX Center is currently undergoing maintenance. You will only be able to view data until maintenance is complete."
  statusModule:
    disconnected: "The connection to the server was lost. Data will not be refreshed anymore until you reload the page."
  maintenanceControls:
    title: "Maintenance Mode"
    instructions:
      userNotice: "When in maintenance mode, users will not be able to perform the following actions:"
      userActions:
        payloads: "Send test result payloads"
        testKeys: "Generate/release test keys"
        apiKeys: "Request/disable/delete API keys"
        deprecations: "Deprecate/undeprecate tests"
      adminNotice: "These administrative actions will also be unavailable:"
      adminActions:
        projects: "Create/delete projects"
        users: "Edit/deactivate/delete users"
    activate: "Start maintenance"
    deactivate: "End maintenance"
    status: "Application Status"
    statusOn: "In maintenance"
    statusOff: "Online"
    confirmation: "Are you sure you want to start the maintenance mode?"
    time: "Maintenance Time"
    error: "Could not toggle maintenance mode."
  latestTestRuns:
    title: "Latest Test Runs"
    results: "Results"
    empty: "No tests results were received yet."
  userInfo:
    activate: "Activate"
    deactivate: "Deactivate"
    deactivatedInstructions: "This user cannot log in or use the API."
    confirmDelete: "Are you sure you want to delete this user? This operation cannot be canceled."
    activationError: "Could not activate or deactivate user."
    deletionError: "Could not delete user."
  currentTestMetrics:
    title: "Test Count"
    today: "Today"
    week: "Last 7 days"
    month: "Last 30 days"
    written: "New Tests"
    run: "Tests Run"
    tooltip:
      time:
        today: "today"
        week: "over the last week"
        month: "over the last month"
      writtenText: "__user__ wrote __n__ new tests __time__"
      runText: "__user__ ran __n__ tests __time__"
  testCountersManager:
    title: "Test Counters"
    instructions: "The number of tests written and run each day is cached in counters and updated with each new test run. This helps to quickly display information about the number of tests without having to analyze the raw data."
    status: "Status"
    statuses:
      idle: "Idle"
      preparing: "Preparing"
      computing: "Computing"
    jobs: "Pending Jobs"
    remainingResults: "Remaining Results"
    totalCounters: "Total Counters"
    recompute: "Recompute all counters"
    recomputeConfirmation: "This will clear and re-compute all test counters. It will take from minutes to hours depending on the amount of data. Are you sure you want to proceed?"
    maintenanceNotice: "The application must be in maintenance mode to start recomputing counters. The maintenance can be ended as soon as the process has started."
    recomputingStarted: "The recomputing process has started successfully. You may stop the maintenance mode at your convenience."
  projectEditor:
    namePlaceholder: "My project"
    tokenPlaceholder: "my_project"
    create: "Add a project"
    update: "Edit this project"
    createFormTitle: "New project"
    updateFormTitle: "Editing"
    urlTokenInstructions: "allowed characters: a-z, 0-9, -, _"
  breakdownChart:
    noItem:
      category: "Uncategorized"
    title:
      category: "Tests by Category"
      project: "Tests by Project"
      author: "Tests by Author"
    subtitle:
      category: "for the 12 most used categories"
      project: "for the 12 projects with the most tests"
      author: "for the 12 authors who have written the most tests"
  testResult:
    status:
      passed: "passed"
      inactive: "inactive"
      failed: "failed"
  linksManager:
    title: "Menu Links"
    instructions: "Links will appear next to the menu brand as a dropdown menu."
    empty: "No links are defined"
    confirmDelete: "Are you sure you want to delete the __name__ link? This operation cannot be canceled."
  appData:
    headers:
      general: "General"
      jobs: "Jobs"
      count: "Records"
    environment: "Environment"
    users: "Users"
    databaseSize: "Database Size"
    cacheSize: "Cache RAM Size"
    resqueLink: "Resque Backend"
    jobs:
      workers: "Workers"
      working: "Working"
      pending: "Pending"
      processed: "Processed"
      failed: "Failed"
  testsData:
    tests: "Tests"
    testResults: "Results"
    testRuns: "Runs"
    failingTests: "Failing"
    outdatedTests: "Outdated"
    inactiveTests: "Inactive"
    outdatedInstructions: "Tests that have not been run in __days__ days"
  testInfo:
    goToTestRun: "Click to go to the test run."
    deprecationError: "The status of the test could not be changed."
    deprecate: "Deprecate"
    undeprecate: "Reactivate"
    actions: "Actions :"
    customValues: "Custom Data"
    noCustomValues: "This test has no custom data."
    resultTable: "Result List"
    resultChart: "Execution Time"
    resultInstructions: "Click on a result to see its details."
    resultPointInstructions: "Click to see details"
    resultStatus:
      passed: "passed"
      failed: "failed"
    permalinkInstructions: "Use this permalink to link to this test from elsewhere."
    copyToClipboard: "Copy to clipboard"
    copiedToClipboard: "Copied!"
  testRunReport:
    loadingError: "Report data could not be loaded"
    loadingTimeout: "Report generation timed out"
    noMatch: "No results matching this filter."
    statusFilter:
      passed:
        show: "Click to show passed results"
        hide: "Click to hide passed results"
      failed:
        show: "Click to show failed results"
        hide: "Click to hide failed results"
      inactive:
        show: "Click to show inactive results"
        hide: "Click to hide inactive results"
    tooltipMessage:
      passed: "Passed"
      failed: "Failed"
      inactive: "Inactive"
  globalSettings:
    title: "Settings"
    reportsCacheSize: "Reports Cache Size"
    reportsCacheSizeInstructions: "maximum number of reports to cache on disk (0 for no cache)"
    tagCloudSize: "Tag Cloud Size"
    tagCloudSizeInstructions: "maximum number of tags to show on the home page (1 or more)"
    testOutdatedDays: "Tests Outdated Days"
    testOutdatedDaysInstructions: "tests will be marked as outdated after this number of days (1 or more)"
    ticketingSystemUrl: "Ticketing System URL"
    save: "Save"
    error: "Could not save settings"
    success: "Successfully saved settings"
  usersTable:
    empty: "No users found."
  apiKeysTable:
    empty: "No API keys found."
    new: "Request a new API key"
    disable: "Disable this key"
    enable: "Enable this key"
    delete: "Delete this key"
    deleteConfirmation: "Are you sure you want to delete this key?"
    keyError: "Could not update or delete API key."
    creationError: "Could not create API key."
    generalError: "An error occurred while contacting the server."
  projectsTable:
    empty: "No projects found."
  keyGenerator:
    generate: "Generate"
    release: "Release unused keys"
    releaseConfirmation: "Are you sure you want to release all unused keys? This operation cannot be canceled. If you have used these keys for tests whose results have not yet been submitted, you will have to generate and assign new keys to these tests."
    newKeys: "new keys for"
    noProject: "No project available"
    instructions: "Each test must be identified by a unique key. You can request keys for new tests here."
    errors:
      generate: "Could not generate keys."
      release: "Could not release keys."
  resultData:
    instructions: "Click on a result to see its data."
    noMessage: "This result has no message."
    error: "Could not load result data."
    tabs:
      message: "Message"
  hallOfShame:
    title: "Hall of Shame"
    loading: "Loading..."
    refresh: "Refresh"
    headers:
      user: "User"
      currentlyFailingTests: "Currently Failing"
      testsBrokenFixed: "Broken / Fixed"
  testRunsTable:
    empty: "No tests have been run."
    status: "Status"
    search:
      groups:
        placeholder: "By group"
      runners:
        placeholder: "By runner"
  tableWithAdvancedSearch:
    search:
      show: "Show Advanced Search"
      hide: "Clear Advanced Search"
  testsTable:
    empty: "No matching tests found."
    lastRun: "Last Run"
    lastRunDate: "Date"
    lastRunDuration: "Duration"
    moreInfo: "Click for more info"
    goToLastRun: "Click to go to test run"
    keyTooltip: "Copy permalink to clipboard"
    search:
      status:
        placeholder: "By status"
        failing: "Failing"
        outdated: "Outdated"
        deprecated: "Deprecated"
        inactive: "Inactive"
      tags:
        placeholder: "By tag"
      tickets:
        placeholder: "By ticket"
      authors:
        placeholder: "By author"
      categories:
        placeholder: "By category"
        blank: "Uncategorized"
      projects:
        placeholder: "By project"
      breakers:
        placeholder: "By breaker"
  models:
    apiKey:
      identifier: "ID"
      sharedSecret: "Shared secret"
      createdAt: "Created at"
      lastUsedAt: "Last used at"
      usageCount: "Uses"
    user:
      name: "Username"
      active: "Active"
      email: "E-mail"
      createdAt: "Registered Since"
    test:
      name: "Name"
      project: "Project"
      author: "Author"
      key: "Key"
      createdAt: "Created at"
      lastRunAt: "Last run"
      lastRunDuration: "Duration"
      status: "Status"
      category: "Category"
      tags: "Tags"
      tickets: "Tickets"
      permalink: "Permalink"
      inactive: "Inactive"
      inactiveInstructions: "This test will not be counted as either passed or failed."
      deprecated: "Deprecated"
      deprecatedInstructions: "This test is no longer used. It will not show up in the list of outdated tests."
    testRun:
      runner: "Runner"
      status: "Status"
      endedAt: "End Date"
      duration: "Duration"
      numberOfResults: "Tests"
      group: "Group"
    testResult:
      runAt: "Run at"
      duration: "Duration"
      runner: "Runner"
      version: "Version"
      status: "Status"
    project:
      name: "Name"
      activeTestsCount: "Number of tests"
      createdAt: "First tested at"
      apiId: "API identifier"
      urlToken: "URL token"
    link:
      name: "Name"
      url: "URL"
