module ActionView
  module Helpers
    # Overrides the standard Rails methods to be able to catch legacy AJAX callbacks.
    module FormTagHelper

      require 'legacy_ajax_callbacks'
      extend LegacyAjaxCallbacks

      private

      alias_method :rails_form_tag_in_block, :form_tag_in_block
      def form_tag_in_block(html_options, &block)
        html_options, inline_js = LegacyAjaxCallbacks.enable(html_options)
        rails_form_tag_in_block(html_options, &block) + inline_js
      end

    end
  end
end
