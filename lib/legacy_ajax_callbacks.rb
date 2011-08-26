module LegacyAjaxCallbacks

  class << self

    # Enables compatibility for legacy ajax callbacks.
    def enable(options)
      options = options.symbolize_keys
      if no_ajax_callbacks?(options)
        [options, '']
      else
        # We need an id to be able to attach the callback to.
        options = adjust_element_id(options)
        # Return updated options hash and inline JS.
        [remove_callbacks(options), inline_javascript(options)]
      end
    end

    private

      # All supported legacy AJAX callbacks.
      LEGACY_AJAX_CALLBACKS = [
        :before, :loading, :loaded, :interactive, :success, :failure, :complete
      ]

      # Expects an options hash and returns a boolean stating if it is free of
      # any of the supported legacy AJAX callbacks.
      def no_ajax_callbacks?(options)
        # Check if options and callbacks have a common subset.
        (options.keys & LEGACY_AJAX_CALLBACKS).empty?
      end

      # Adjusts calls to the element itself by updating its id.
      def adjust_element_id(options)
        # Ensure an existing id to attach the callback to.
        options[:id] = "legacy_id_#{options.object_id}" unless options.keys.include?(:id)
        # Replace occurrences of currentElement with the actual element id.
        LEGACY_AJAX_CALLBACKS.each do |callback|
          options[callback].try(:gsub!, 'currentElement', "'##{options[:id]}'")
        end
        options
      end

      # Remove legacy callbacks before creating the html.
      def remove_callbacks(options)
        options.reject{|key, value| LEGACY_AJAX_CALLBACKS.include?(key)}
      end

      # Creates an inline JavaScript, that binds the callbacks to the link's id.
      def inline_javascript(options)
        callbacks = ''
        # :before and :loading get merged into ajax:beforeSend.
        before_send = options.values_at(:before, :loading).compact!
        unless before_send.empty?
          callbacks += ".live('ajax:beforeSend', function(evt, xhr, settings){#{before_send.join('; ')}})"
        end
        if options[:success]
          callbacks += ".live('ajax:success', function(evt, data, status, xhr){#{options[:success]}})"
        end
        if options[:failure]
          callbacks += ".live('ajax:error', function(evt, xhr, status, error) {#{options[:failure]}})"
        end
        # :loaded, :interactive and :complete get merged into ajax:complete.
        complete = options.values_at(:loaded, :interactive, :complete).compact!
        unless complete.empty?
          callbacks += ".live('ajax:complete', function(evt, xhr, status){#{complete.join('; ')}})"
        end
        # Finally, return the constructed inline JavaScript.
        "<script type='text/javascript'>$(document).ready(function($){$('##{options[:id]}')#{callbacks};});</script>".html_safe
      end

  end

end
