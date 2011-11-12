$(function(){
  	$('#results.items.grid').isotope({
    	itemSelector: '.item',
			layoutMode : 'fitRows',
			animationOptions: {
		     duration: 500,
		     easing: 'linear',
		     queue: false
		   }
    });
});

$(document).ready(function(){
		$('#noticeMain').click(function(){
				$(this).fadeOut('slow');				
				$.cookie( "rackjamnotice", "closed", { expires: 2 } ); 	
		})
});

$(document).ready(function() {
	
	    $('.form span.defaultValue').each(function() {
    
	        var defaultValue = $(this).text();
	        var inputField = $(this).siblings('input');
        
	        inputField.attr("default",defaultValue) /* add the default attribute ~ <input type="" default="dd/mm/yyy" */
	        if (inputField.val() == '' || inputField.val() == defaultValue) {
	            inputField.val(defaultValue).addClass('defaultValueFields').addClass('initValue')
	        } 
	    });
     
	    /* Handle a click on a defaultValue field */
	    $(".defaultValueFields").live('focus',function() {   
	        $(this).removeClass('initValue')
    
	        if( $(this).val() == $(this).attr("default") ) {
	            $(this).val('');
	        }
	    }).blur(function() {
	        if( !$(this).val().length ) {
	            $(this).val($(this).attr("default")).addClass('initValue');
	        }
	    });  
	
		  /* Hover functions */
  		function makeTall(){ 
								
					$.ajax({
					  url: "/interests.js",
						data: "id=" + $(this).attr('id'),					
					  context: document.body,
					  success: function(){
					    $(this).addClass("done");
					  }
					});
					
			}
			function makeShort(){ }

			var config = {    
				over: makeTall, // function = onMouseOver callback (REQUIRED)    
				timeout: 5000, // number = milliseconds delay before onMouseOut    
				out: makeShort, // function = onMouseOut callback (REQUIRED)    
				interval: 700
			};
			
			$("#results li").hoverIntent(config)

	
});	
