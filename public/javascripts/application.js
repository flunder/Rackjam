$(document).ready(function(){

	/* Setup Brand-dropdown */
	$('#brand_dropdown select').selectmenu({
			width: 200
	});


	/* Rackjam NOTICE cookie handling */
	$('#closeIntro').click(function(){
			$(this).parent('div').slideUp('slow');				
			$.cookie( "rackjamnotice", "closed", { expires: 3 } ); 	
	})
	
		/* ISOTOPE */
  	$('#results.items.grid').isotope({
    	itemSelector: '.item',
			layoutMode : 'fitRows',
			animationOptions: {
		     duration: 500,
		     easing: 'linear',
		     queue: false
		}
    });		

	/* Adverts slider */
	$("#box").jCarouselLite({
		auto: 10000,
		speed: 700,
		circular: true,
		visible: 1,
		easing: 'easeInOutCubic',
		start: Math.floor(Math.random()*$("#box ul li").length),
		vertical: true
    });

	/*
	$('#box').hover(
		function() {
			$(this).fadeTo('slow', 1);
		}, 
		function() {
			$(this).fadeTo('slow', 0.7);
		}
	)
	*/
		
	// smartInputs ---------------------------------------------- 

	// sumbit the searchform on enter for b0rked browsers 
	$('.smartInput').keypress(function(e){
		if(e.which == 13){
	  	$('form').submit();
	   }
	 });	

	// initial state
	$(".smartInput").each(function() {
		if( !this.value.length ) {
			$(this).css({ backgroundPosition:"0px 0px" });
		}
	})

	// focus & blur states
	$(".smartInput").focus(function() {
		if( !this.value.length ) {
			$(this).css({ backgroundPosition:"0px -29px" });
		}
	}).blur(function() {
		if( !this.value.length ) {
			$(this).css({ backgroundPosition:"0px 0px" });
		}
	});		

    /* login form js values */
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

  /* Hover ajax functions for /HOT ----------------------------- */
		function hoveredItem(){ 
		$.ajax({
		  url: "/interests.js",
			data: { id: $(this).attr('id'), value: + "1" }
		});
	}
	
	function clickedItem(id){ 
			$.ajax({
			  url: "/interests.js",
				data:  { id: id, value: + "3" }
			});
	}
	
	function someFunc() {  }
	
	var config = {    
		over: someFunc, // function = onMouseOver callback (REQUIRED)    
		timeout: 2500, // number = milliseconds delay before onMouseOut    
		out: hoveredItem, // function = onMouseOut callback (REQUIRED)    
		interval: 300
	};
	
	$("#results li").hoverIntent(config)
	$("#results li").click(function(){ clickedItem($(this).attr('id')); })

    /* Love click handler ----------------- */
	$('.love').click(function(){

		var heart = $(this).find('a');
		var item = $(this).parents('li');
		var state = heart.attr('class');

		//$(heart).ajaxStart(function() {
		//  $(item).addClass('loading');
		//});

		$.ajax({
		  	url: "/likes/new",
				data:  { id: item.attr('id') },
 				success: function (msg) {
						if (state == 'unliked') {
								$(heart).attr('class','liked')
						} else if (state == 'liked') {
								$(heart).attr('class','unliked')
						}
				},
				error: function(){
					window.location = "/users/login";		
				}
		
		});

		return false;
	})

});	