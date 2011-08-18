LegacyAjaxCallbacks
======================

This plugin re-enables inline AJAX callbacks, the way Rails 2 used them.

Example
-------

    <%= link_to 'Click me' @my_stuff, {:remote => true, :complete => 'alert("Done!")'} %>

Copyright (c) 2011 Dominik Bamberger, released under the MIT license. For full details see MIT-LICENSE included in this distribution.
