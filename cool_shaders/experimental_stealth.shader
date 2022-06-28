shader_type spatial;

uniform float magnitude : hint_range(-1000, 1000) = 100; //Controls the "strength" of the magnification/distortion.  A value of zero doesn't change the background at all.
uniform bool flipGreen = false; //Added this parameter since sometimes normal maps work with green as the down direction instead of up.

void fragment( )
{
	vec2 SCREEN_PIXEL_SIZE = 1.0 / VIEWPORT_SIZE;
	float alpha = ALPHA;
	float red = ALBEDO.r;
	float green = ALBEDO.g;
	
	
	vec2 angle = vec2(
		(red - 0.5) * (magnitude * SCREEN_PIXEL_SIZE.x) , //Calculates the left-right value based on the red value of the normal map.  A red value of 50% is head-on.  0% is fully to the left and 100% is fully to the right.  I'm also multiplying it by the screen_pixel_size so that the magnitude is in pixels and not dependent on screen dimensions.  And the magnitude to adjust how big of a shift it will be.
		(green - 0.5) * (magnitude * SCREEN_PIXEL_SIZE.y) ) ; //Ditto, but with Green for up-down
	if (flipGreen) {angle.y = -angle.y;} // Flips the vertical value if "flipGreen" is selected
	vec2 shiftvec = -angle;  //Whatever angle the surface is pointing to, you want to grab pixels from the opposite direction.  Could probably alter this line to make it more realistic, if you're familiar with lens physics.
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + alpha * shiftvec).rgb;
//COLOR = texture( SCREEN_TEXTURE, SCREEN_UV + alpha *  shiftvec); //Grab a pixel from the screen at an offset by the shiftvec.
}