[
  ({ config, helpers, ... }: {
    config.home-manager.users = helpers.config.mkForEachUser config (user: {
      home.stateVersion = config.system.stateVersion;
    });
  })
]
