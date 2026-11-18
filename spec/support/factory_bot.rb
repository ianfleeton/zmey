# frozen_string_literal: true

# Associations in built (unsaved) records are created rather than built, so
# a built record can be saved without its associations failing validation.
# Set once here so behaviour doesn't depend on which spec files are loaded.
FactoryBot.use_parent_strategy = false
