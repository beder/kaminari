module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      # a workaround for AR 3.0.x that returns 0 for #count when page > 1
      # if +limit_value+ is specified, load all the records and count them
      if ActiveRecord::VERSION::STRING < '3.1'
        def count #:nodoc:
          limit_value ? length : super
        end
      end

      def total_count #:nodoc:
        # #count overrides the #select which could include generated columns referenced in #order, so skip #order here, where it's irrelevant to the result anyway
        c = except(:offset, :limit, :order)
        # Remove includes only if they are irrelevant
        c = c.except(:includes) unless references_eager_loaded_tables?
        # .group returns an OrderdHash that responds to #count
        if distinct_column_name.nil?
          c = c.count
        else
          c = c.count(distinct_column_name, :distinct => true)
        end
        c.respond_to?(:count) ? c.count : c
      end
 
 
      # Get the column name used in distinct query.
      # This could have been set on the Model class, or the ActiveRecord::Relation
      def distinct_column_name
        @distinct_column || distinct_column
      end
   end
  end
end
