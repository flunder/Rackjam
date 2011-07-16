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