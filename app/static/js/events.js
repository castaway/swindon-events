jQuery(function() {
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
    var cal = jQuery('#calendar').calendario({
        caldata: initial_caldata
    }
    );
});

//jQuery('#calendar').calendario();
