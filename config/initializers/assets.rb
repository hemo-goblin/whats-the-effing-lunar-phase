Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
Rails.application.config.assets.compile = true
Rails.application.config.assets.precompile =  ['*.js', '*.css', '*.css.erb', '*.svg']
