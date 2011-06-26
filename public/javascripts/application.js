$(function(){

  	$('#results.items').isotope({
    	itemSelector: '.item',
			layoutMode : 'fitRows',
			animationOptions: {
		     duration: 500,
		     easing: 'linear',
		     queue: false
		   }
    });

});