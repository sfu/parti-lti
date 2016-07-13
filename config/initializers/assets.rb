# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << "#{Rails.root}/vendor/assets/stylesheets/pikachoose"

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( submissions.js )
Rails.application.config.assets.precompile += %w( *.png *.jpg *.jpeg *.gif )
Rails.application.config.assets.precompile += %w( submission_form.css submission_form.js )
Rails.application.config.assets.precompile += %w( participants.css participants.js )
Rails.application.config.assets.precompile += %w( room_editor.css room_editor.js )
