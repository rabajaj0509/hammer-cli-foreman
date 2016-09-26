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

      output ListCommand.output_definition do
      end

      build_options
    end

    autoload_subcommands
  end

end
