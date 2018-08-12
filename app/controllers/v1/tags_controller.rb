module V1
  class TagsController < ::V1::ApplicationController
    discoverable(
      :version => "v1",
      :namespace => "accounts"
    )

    def index
      authorize(policy_scope(Tag))

      realization = JSONAPI::Realizer.index(
        Tags::IndexSchema.new(modified_parameters),
        :headers => request.headers,
        :scope => policy_scope(Tag),
        :type => :accounts
      )

      render(:json => serialize(realization))
    end

    def show
      realization = JSONAPI::Realizer.show(
        Tags::ShowSchema.new(modified_parameters),
        :headers => request.headers,
        :scope => policy_scope(Tag),
        :type => :accounts
      )

      authorize(realization.model)

      render(:json => serialize(realization))
    end
  end
end