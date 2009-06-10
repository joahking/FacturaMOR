module RedHillConsulting::Core::ActiveRecord::ConnectionAdapters
  module MysqlAdapter
    def self.included(base)
      base.class_eval do
        alias_method_chain :remove_column, :redhillonrails_core
      end
    end

    def set_table_comment(table_name, comment)
      execute "ALTER TABLE #{table_name} COMMENT='#{quote_string(comment)}'"
    end
    
    def clear_table_comment(table_name)
      execute "ALTER TABLE #{table_name} COMMENT=''"
    end

    def remove_foreign_key(table_name, foreign_key_name)
      execute "ALTER TABLE #{table_name} DROP FOREIGN KEY #{foreign_key_name}"
    end

    def remove_column_with_redhillonrails_core(table_name, column_name)
      foreign_keys(table_name).select { |foreign_key| foreign_key.column_names.include?(column_name.to_s) }.each do |foreign_key|
        remove_foreign_key(table_name, foreign_key.name)
      end
      remove_column_without_redhillonrails_core(table_name, column_name)
    end

    def foreign_keys(table_name, name = nil)
      results = execute("SHOW CREATE TABLE `#{table_name}`", name)

      foreign_keys = []

      results.each do |row|
        row[1].each do |line|
          if line =~ /^  CONSTRAINT [`"](.+?)[`"] FOREIGN KEY \([`"](.+?)[`"]\) REFERENCES [`"](.+?)[`"] \((.+?)\)( ON DELETE (.+?))?( ON UPDATE (.+?))?,?$/
            name = $1
            column_names = $2
            references_table_name = $3
            references_column_names = $4
            on_update = $8
            on_delete = $6
            on_update = on_update.downcase.gsub(' ', '_').to_sym if on_update
            on_delete = on_delete.downcase.gsub(' ', '_').to_sym if on_delete

            foreign_keys << ForeignKeyDefinition.new(name,
                                           table_name, column_names.gsub('`', '').split(', '),
                                           references_table_name, references_column_names.gsub('`', '').split(', '),
                                           on_update, on_delete)
         end
       end
      end

      foreign_keys
    end
  end
end
