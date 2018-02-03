jQuery(function() {

    var hide_events = function(category) {
//        jQuery('.littleevent:not(.event-category-Film').slideUp();
        jQuery('.littleevent.event-category-' + category).slideDown();
    };

    jQuery('#category_list input').change(function() {
        // Selector of .event-category-x for things we want to show.
        // http://api.jquery.com/map/ -- note the .get
        var sel_to_show = jQuery('#category_list input:checked').map(function(i, elem) {
            console.log("in map, i="+i+", elem="+elem);
            var name = jQuery(elem).val();
            return '.littleevent.'+name;
        }).get().join();

        var sel_to_hide = '.littleevent:not('+sel_to_show+')';

        console.log("sel_to_show: " + sel_to_show);
        console.log("sel_to_hide: " + sel_to_hide);
        
        jQuery(sel_to_show).show();
        jQuery(sel_to_hide).hide();
    });
    
    /*
      If a user clicks on a star character, we send an update to the backend which
      is associated with the logged in user/cookie.
      The returned json should contain the current/changed star character in the 
      "star" attribute.
     */

    jQuery('.star-event').click(function(event) {
        var eventid = jQuery(this).attr('id');
        var star_uri = SwEvent.base_uri + "/star_event"; 
        jQuery.ajax({
            type: 'POST',
            url: star_uri,
            data: {
                event_id: eventid
            },
            dataType: "json",
            success: function( json ) {
                jQuery("#"+eventid).html(json.star);
            },
            error: function(xhr, status, errortext) {
                alert("There was a problem starring this event");
                console.log("Error: " + errortext);
                console.log("Status: " + status);
            }
        });
    });

    /*
      User clicks on the "+" next to an event, display the linked div
      below which contains the event description and the venue details.
     */

    jQuery('i.open_extra').click( function() {
        var which = jQuery(this).attr('id');
        jQuery("#extra_"+which).toggle();
        echo.render();

    });

/*
				var cal = $( '#calendar' ).calendario( {
						onDayClick : function( $el, $contentEl, dateProperties ) {

							for( var key in dateProperties ) {
								console.log( key + ' = ' + dateProperties[ key ] );
							}

						},
						caldata : codropsEvents
					} );
*/
/*
    var cal = jQuery('#calendar').calendario({
        caldata: initial_caldata
    }
    );
*/
});

//jQuery('#calendar').calendario();
