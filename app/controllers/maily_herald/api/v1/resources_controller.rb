module MailyHerald
  module Api
    module V1
      class ResourcesController < BaseController
        before_action :load_resource,   except:  [:index, :create]
        before_action :load_resources,  only:    :index

        def index
          @items = @items.search_by(params[:query])  if  @items.respond_to?(:search_by)   &&  params[:query].present?
          @items = @items.like_email(params[:query]) if  @items.respond_to?(:like_email)  &&  params[:query].present?

          if block_given?
            @items = yield(@items)
          end

          render_api @items, paginate: true, root: root
        end

        def create
          @item = resource.new
          yield(@item) if block_given?
          assign_attributes_and_render_response
        end

        def show
          render_api @item, root: root
        end

        def update
          assign_attributes_and_render_response
        end

        def destroy
          if @item.destroy
            render_api({})
          else
            render_error @item
          end
        end

        protected

        def resource
          @resource ||= set_resource
        end

        private

        def load_resource
          @item = resource.find params[:id]
        end

        def load_resources
          @items = resource.all
        end

        def assign_attributes_and_render_response
          @item.attributes = item_params

          if @item.save
            render_api @item, root: root
          else
            render_error @item
          end

        rescue ArgumentError => e
          if e.to_s.match(/not\ a\ valid\ kind/)
            render_error({kind: "invalid"})
          else
            render_error({base: "invalid"})
          end
        end
      end
    end
  end
end
