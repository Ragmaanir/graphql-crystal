module GraphQL
  module Schema
    module FragmentResolver

      # replace named fragments with their concrete selections before
      # the query is resolved
      def self.resolve(value : Array(GraphQL::Language::Field), fragments)
        visit(value, fragments).map &.as(GraphQL::Language::Field)
      end

      def self.visit(values : Array, fragments : Array(GraphQL::Language::FragmentDefinition))
        new_values = Array(GraphQL::Language::AbstractNode).new
        values.each { |v| new_values = new_values + [visit(v, fragments)].flatten }
        new_values
      end

      def self.visit(value : GraphQL::Language::Field, fragments)
        new_values = Array(GraphQL::Language::AbstractNode).new
        value.selections.each do |s|
          new_values = new_values + visit(s, fragments).map &.as(GraphQL::Language::AbstractNode)
        end
        value.selections = new_values.flatten
        [value]
      end

      def self.visit(value : GraphQL::Language::FragmentSpread, fragments)
        fragment_definition = fragments.find(&.name.==(value.name))
        raise "fragment \"#{value.name}\" is undefined" unless fragment_definition
        fragment_definition.selections
      end

      # Inline fragments will be resolved inline as they carry all the
      # information needed to validate and apply them with a concrete
      # object further down the line of then object type resolution
      def self.visit(value : GraphQL::Language::InlineFragment, fragments)
        [value]
      end

      def self.visit(value, fragments)
        raise "I should have never arrived here!"
      end
    end
  end
end