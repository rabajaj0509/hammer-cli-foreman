module HammerCLIForeman

  class Audit < HammerCLIForeman::Command

    resource :audits

    class ListCommand < HammerCLIForeman::ListCommand

      output do
        field :id, _("Id")
        field :created_at, _("At"), Fields::Date
        field :remote_address, _("IP")
        field nil, _("User"), Fields::SingleReference, :key => :user
        field :action, _("Action")
        field :auditable_type, _("Audit type")
        field nil, _("Audit record"), Fields::SingleReference, :key => :auditable
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      def extend_data(audit)
        audit["changes"] = audit["audited_changes"].map do |attribute, change|
          if change.is_a?(Array)
            {
              'attribute' => attribute,
              'value' => change[1]
            }
          elsif !change.nil?
            {
              'attribute' => attribute,
              'value' => change
            }
          end
        end.compact
        audit
      end

      output ListCommand.output_definition do
        collection :changes, _("Audited changes") do
          field :attribute, _("Attribute")
          field :value, _("Value"), Fields::Field, :hide_blank => true
        end
      end

      build_options
    end

    autoload_subcommands
  end

end
