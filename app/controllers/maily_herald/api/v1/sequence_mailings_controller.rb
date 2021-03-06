module MailyHerald
  module Api
    module V1
      class SequenceMailingsController < MailingsController
        before_action :load_sequence

        def create
          super do |mailing|
            mailing.sequence = @sequence
          end
        end

        private

        def load_sequence
          @sequence = MailyHerald::Sequence.find(params[:sequence_id])
        end

        def item_params
          params.require(:sequence_mailing).permit(:kind, :title, :mailer_name, :from, :conditions, :subject, :template_plain, :template_html, :absolute_delay, :track)
        end
      end
    end
  end
end
