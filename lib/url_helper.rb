module ActionView
  module Helpers
    # Overrides the standard Rails methods to be able to catch legacy AJAX callbacks.
    module UrlHelper

      require 'legacy_ajax_callbacks'
      extend LegacyAjaxCallbacks

      alias_method :rails_link_to, :link_to
      def link_to(*args, &block)
        # A given block will result in a recursive call. We'll catch it then.
        return rails_link_to(*args, &block) if block_given?
        # If any inline JS is generated, html_options will change, too.
        html_options, inline_js = LegacyAjaxCallbacks.enable(args[2] || {})
        rails_link_to(args[0], args[1], html_options) + inline_js
      end

      alias_method :rails_button_to, :button_to
      def button_to(name, options = {}, html_options = {})
        html_options, inline_js = LegacyAjaxCallbacks.enable(html_options)
        rails_button_to(name, options, html_options) + inline_js
      end

    end
  end
end
