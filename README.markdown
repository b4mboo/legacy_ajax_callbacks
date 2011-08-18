LegacyAjaxCallbacks
======================

This plugin re-enables inline AJAX callbacks in Rails 3 and allows you to continue using your old Rails 2 callbacks, until your done porting all your views to the use of unobstrusive JavaScript. I highly recommend that transition to an unobstrusive approach, as it will make your code much cleaner.

Some links for further reference on that topic:

    http://www.alfajango.com/blog/rails-3-remote-links-and-forms/

    http://www.simonecarletti.com/blog/2010/06/unobtrusive-javascript-in-rails-3/


Example
-------

    <%= link_to 'Click me' @my_stuff, {:remote => true, :complete => 'alert("Done!")'} %>

As you can see in the above example, you'll still need to change your syntax from ``link_to_remote`` to ``link_to`` with the option ``:remote => true``. However, with this plugin you can keep your AJAX callbacks the way they used to be.


Copyright (c) 2011 Dominik Bamberger, released under the MIT license. For full details see MIT-LICENSE included in this distribution.
