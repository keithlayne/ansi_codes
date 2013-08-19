module AnsiCodes
  module ActiveModel
    extend ::ActiveSupport::Concern

    include ::ActiveModel::Validations
    include ::ActiveModel::Conversion
    include ::ActiveModel::Serializers::JSON
    include ::ActiveModel::Serializers::Xml

    included do
      extend ::ActiveModel::Naming
    end

    def persisted?
      true
    end

    def from_json(json, include_root = include_root_in_json)
      self.class.from_json(json, include_root)
    end

    def from_xml(xml)
      self.class.from_xml(xml)
    end

  end

  class State
    include ActiveModel

    def attributes
      { ansi_code: nil, abbreviation: nil, name: nil }
    end

    def to_key
      [ansi_code] if persisted?
    end

    def self.from_json(json, include_root = include_root_in_json)
      hash = ActiveSupport::JSON.decode(json)
      hash = hash.values.first if include_root
      find hash['ansi_code']
    end

    def self.from_xml
      find Hash.from_xml(xml).values.first['ansi_code']
    end
  end

  class County
    include ActiveModel

    def attributes
      { state_ansi: nil, county_ansi: nil, name: nil,
        short_name: nil, designation: nil }
    end

    def to_key
      [state_ansi, county_ansi] if persisted?
    end

    def self.from_json(json, include_root = include_root_in_json)
      hash = ActiveSupport::JSON.decode(json)
      hash = hash.values.first if include_root
      find *hash.values_at('state_ansi', 'county_ansi')
    end

    def self.from_xml
      find *Hash.from_xml(xml).values.first.values_at('state_ansi', 'county_ansi')
    end
  end
end if defined? ActiveModel