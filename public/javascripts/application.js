$(document).ready(function(){


		/* Brands-dropdown */
		$('#brand_dropdown select').selectmenu({
				width: 200
		});

	
		/* NOTICE */
		$('#closeIntro').click(function(){
				$(this).parent('div').slideUp('slow');				
				$.cookie( "rackjamnotice", "closed", { expires: 2 } ); 	
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
				start: Math.floor(Math.random()*$("#box ul li").length)
				// vertical: true
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
				
});

$(document).ready(function() {
	
			// smartInput 
		
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
	
		  /* Hover functions for HOT ----------------------------- */
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
				interval: 75
			};
			
			//$("#results li").hoverIntent(config)
			//$("#results li").click(function(){ clickedItem($(this).attr('id')); })
	
});	

$(document).ready(function() {
	
	$('.love').click(function(){
		
			var heart = $(this).find('a');
			var item = $(this).parents('li');
			var state = heart.attr('class');
		
			$.ajax({
			  	url: "/likes/new",
					data:  { id: item.attr('id') },
  				success: function (msg) {
							if (state == 'unliked') {
									$(heart).attr('class','liked')
									// $(heart).css("background-image","url(../images/icons/like.png)").animate({opacity: 1},500)
						
							} else if (state == 'liked') {
									$(heart).attr('class','unliked')
									// $(heart).css("background-image","url(../images/icons/like_grey.png)").animate({opacity: 0.5},500)
									
							}
					}
			});
		
			return false;
	})
	
});	