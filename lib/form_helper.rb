module ActionView
  module Helpers
    # Overrides the standard Rails methods to be able to catch legacy AJAX callbacks.
    module FormHelper

      require 'legacy_ajax_callbacks'
      extend LegacyAjaxCallbacks

      alias_method :rails_form_for, :form_for
      def form_for(record, options = {}, &proc)
        options[:html], inline_js = LegacyAjaxCallbacks.enable(options[:html] || {})
        rails_form_for(record, options, &proc) + inline_js
      end

    end
  end
end