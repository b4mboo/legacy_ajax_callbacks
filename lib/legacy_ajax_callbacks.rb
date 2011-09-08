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
      LEGACY_OPTIONS = [
        :update, :data
      ]

      # Returns an array of legacy keys to improve readability.
      def legacy_keys
        LEGACY_AJAX_CALLBACKS + LEGACY_OPTIONS
      end

      # Expects an options hash and returns a boolean stating if it is free of
      # any of the supported legacy AJAX callbacks.
      def no_ajax_callbacks?(options)
        # Check if options and legacy keywords have a common subset.
        (options.keys & legacy_keys).empty?
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
        options.reject{|key, value| legacy_keys.include?(key)}
      end

      # Creates an inline JavaScript, that binds the callbacks to the link's id.
      def inline_javascript(options)
        callbacks = ''
        # :before and :loading get merged into ajax:beforeSend.
        before_send = options.values_at(:before, :loading).compact!
        if options[:data]
          before_send << "xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')"
          before_send << "settings.data = $.param(#{options[:data].to_json})"
        end
        unless before_send.empty?
          callbacks += ".bind('ajax:beforeSend', function(evt, xhr, settings){#{before_send.join('; ')}})"
        end
        if options[:success]
          callbacks += ".bind('ajax:success', function(evt, data, status, xhr){#{options[:success]}})"
        end
        if options[:failure]
          callbacks += ".bind('ajax:error', function(evt, xhr, status, error) {#{options[:failure]}})"
        end
        # :loaded, :interactive and :complete get merged into ajax:complete.
        complete = options.values_at(:loaded, :interactive, :complete).compact!
        if options[:update]
          complete.unshift "$('##{options[:update]}').html(xhr.responseText);"
        end
        unless complete.empty?
          callbacks += ".bind('ajax:complete', function(evt, xhr, status){#{complete.join('; ')}})"
        end
        # Finally, return the constructed inline JavaScript.
        "<script type='text/javascript'>$(document).ready(function($){$('##{options[:id]}')#{callbacks};});</script>".html_safe
      end

  end

end
