require "administrate/base_dashboard"

class HCBCredentialDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    access_token_ciphertext: Field::String,
    base_url: Field::String,
    client_id: Field::String,
    client_secret_ciphertext: Field::String,
    redirect_uri: Field::String,
    refresh_token_ciphertext: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    access_token_ciphertext
    base_url
    client_id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    access_token_ciphertext
    base_url
    client_id
    client_secret_ciphertext
    redirect_uri
    refresh_token_ciphertext
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    access_token_ciphertext
    base_url
    client_id
    client_secret_ciphertext
    redirect_uri
    refresh_token_ciphertext
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how hcb credentials are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(hcb_credential)
  #   "HCBCredential ##{hcb_credential.id}"
  # end
end
