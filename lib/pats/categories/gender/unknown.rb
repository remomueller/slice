# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Gender
      # Defines unknown gender variable and associated subquery.
      class Unknown < Default
        def label
          'Unknown or not reported'
        end

        def variable_name
          'ciw_sex'
        end

        def subquery
          "#{database_value} IS NULL"
        end

        def css_class
          'lighter'
        end
      end
    end
  end
end
