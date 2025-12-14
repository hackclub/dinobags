class BaseDashboard < Administrate::BaseDashboard
  class << self
    def model
      name.gsub("Dashboard", "").constantize
    end

    def attribute_types
      model.columns_hash.each_with_object({}) do |(name, column), hash|
        hash[name.to_sym] = field_type_for(column)
      end.merge(association_types)
    end

    def collection_attributes
      model.column_names.map(&:to_sym)
    end

    def show_page_attributes
      model.column_names.map(&:to_sym)
    end

    def form_attributes
      model.column_names.map(&:to_sym) - %i[id created_at updated_at]
    end

    private

    def field_type_for(column)
      case column.type
      when :string, :text
        Administrate::Field::String
      when :integer, :bigint
        Administrate::Field::Number
      when :float, :decimal
        Administrate::Field::Number.with_options(decimals: 2)
      when :boolean
        Administrate::Field::Boolean
      when :date
        Administrate::Field::Date
      when :datetime, :timestamp
        Administrate::Field::DateTime
      when :json, :jsonb
        Administrate::Field::String
      else
        Administrate::Field::String
      end
    end

    def association_types
      model.reflect_on_all_associations.each_with_object({}) do |assoc, hash|
        hash[assoc.name] = case assoc.macro
                           when :belongs_to
                             Administrate::Field::BelongsTo
                           when :has_many
                             Administrate::Field::HasMany
                           when :has_one
                             Administrate::Field::HasOne
                           else
                             Administrate::Field::String
                           end
      end
    end
  end

  ATTRIBUTE_TYPES = {}
  COLLECTION_ATTRIBUTES = []
  SHOW_PAGE_ATTRIBUTES = []
  FORM_ATTRIBUTES = []

  def attribute_types
    self.class.attribute_types
  end

  def collection_attributes
    self.class.collection_attributes
  end

  def show_page_attributes
    self.class.show_page_attributes
  end

  def form_attributes(_action = nil)
    self.class.form_attributes
  end

  def display_resource(resource)
    resource.to_s
  end
end
