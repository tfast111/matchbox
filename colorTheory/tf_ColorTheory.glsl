//Color Theory from single color
//color conversion parts from mouaif.wordpress.com
//tfast11@gmail.com

uniform float adsk_result_w, adsk_result_h, degree;
uniform vec3 inputColor;
uniform bool Triadic, splitComp, Analogous, Complement, Monochromatic;

//Create rectangle: X position, Y position, width, height
float rect(vec2 position, vec2 size ){
	if(length(max(abs(position)-size,0.0))==0.0){
		return 1.0;
	}
	return 0.0;
}

//Desat
vec3 Desaturate(vec3 color, float Desaturation)
{
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, color));
	return vec3(mix(color, gray, Desaturation));
}

//convert to HSL
vec3 RGBToHSL(vec3 color)
{
	vec3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)
	
	float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
	float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
	float delta = fmax - fmin;             //Delta RGB value

	hsl.z = (fmax + fmin) / 2.0; // Luminance

	if (delta == 0.0)		//This is a gray, no chroma...
	{
		hsl.x = 0.0;	// Hue
		hsl.y = 0.0;	// Saturation
	}
	else                                    //Chromatic data...
	{
		if (hsl.z < 0.5)
			hsl.y = delta / (fmax + fmin); // Saturation
		else
			hsl.y = delta / (2.0 - fmax - fmin); // Saturation
		
		float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
		float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
		float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;

		if (color.r == fmax )
			hsl.x = deltaB - deltaG; // Hue
		else if (color.g == fmax)
			hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
		else if (color.b == fmax)
			hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue

		if (hsl.x < 0.0)
			hsl.x += 1.0; // Hue
		else if (hsl.x > 1.0)
			hsl.x -= 1.0; // Hue
	}

	return hsl;
}

//Hue function
float HueToRGB(float f1, float f2, float hue)
{
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;
	float res;
	if ((6.0 * hue) < 1.0)
		res = f1 + (f2 - f1) * 6.0 * hue;
	else if ((2.0 * hue) < 1.0)
		res = f2;
	else if ((3.0 * hue) < 2.0)
		res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
	else
		res = f1;
	return res;
}

//convert back
vec3 HSLToRGB(vec3 hsl)
{
	vec3 rgb;
	
	if (hsl.y == 0.0)
		rgb = vec3(hsl.z); // Luminance
	else
	{
		float f2;
		
		if (hsl.z < 0.5)
			f2 = hsl.z * (1.0 + hsl.y);
		else
			f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
			
		float f1 = 2.0 * hsl.z - f2;
		
		rgb.r = HueToRGB(f1, f2, hsl.x + (1.0/3.0));
		rgb.g = HueToRGB(f1, f2, hsl.x);
		rgb.b= HueToRGB(f1, f2, hsl.x - (1.0/3.0));
	}
	
	return rgb;
}

void main( void ) {

vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

vec3 triadic1 = vec3(0.0);
triadic1 = RGBToHSL(inputColor);
triadic1.r = triadic1.r + 120.0/360.0;
triadic1 = HSLToRGB(triadic1);

vec3 triadic2 = vec3(0.0);
triadic2 = RGBToHSL(inputColor);
triadic2.r = triadic2.r - 120.0/360.0;
triadic2 = HSLToRGB(triadic2);

vec3 splitComp1 = vec3(0.0);
splitComp1 = RGBToHSL(inputColor);
splitComp1.r = splitComp1.r + 150.0/360.0;
splitComp1 = HSLToRGB(splitComp1);

vec3 splitComp2 = vec3(0.0);
splitComp2 = RGBToHSL(inputColor);
splitComp2.r = splitComp2.r - 150.0/360.0;
splitComp2 = HSLToRGB(splitComp2);

vec3 analogous1 = vec3(0.0);
analogous1 = RGBToHSL(inputColor);
analogous1.r = analogous1.r + degree/360.0;
analogous1 = HSLToRGB(analogous1);

vec3 analogous2 = vec3(0.0);
analogous2 = RGBToHSL(inputColor);
analogous2.r = analogous2.r - degree/360.0;
analogous2 = HSLToRGB(analogous2);

vec3 analogous3 = vec3(0.0);
analogous3 = RGBToHSL(inputColor);
analogous3.r = analogous3.r - (degree*2.0)/360.0;
analogous3 = HSLToRGB(analogous3);

vec3 analogous4 = vec3(0.0);
analogous4 = RGBToHSL(inputColor);
analogous4.r = analogous4.r + (degree*2.0)/360.0;
analogous4 = HSLToRGB(analogous4);

vec3 complement1 = vec3(0.0);
complement1 = RGBToHSL(inputColor);
complement1.r = complement1.r - .5;
complement1 = HSLToRGB(complement1);

vec2 boxSize = vec2(0.08, 0.09);

float box1 = rect(coords-vec2(0.15,0.9),boxSize);
vec3 color1 = inputColor * box1;
vec3 outputColor = color1;

if (Complement){

	float box4 = rect(coords-vec2(0.15,0.7),boxSize);
	vec3 color4 = complement1 * box4;

	outputColor += color4;
	}

if (Triadic){

	float box1b = rect(coords-vec2(0.32,0.9),boxSize);
	vec3 color1b = inputColor * box1b;

	float box2 = rect(coords-vec2(0.32,0.7),boxSize);
	vec3 color2 = triadic1 * box2;

	float box3 = rect(coords-vec2(0.32,0.5),boxSize);
	vec3 color3 = triadic2 * box3;
	
	outputColor += color1b+color2+color3;
	}
	
if (splitComp){

	float box6 = rect(coords-vec2(0.49,0.9),boxSize);
	vec3 color6 = inputColor * box6;

	float box7 = rect(coords-vec2(0.49,0.7),boxSize);
	vec3 color7 = splitComp1 * box7;

	float box8 = rect(coords-vec2(0.49,0.5),boxSize);
	vec3 color8 = splitComp2 * box8;
	
	outputColor += color6+color7+color8;
	}
	
if (Analogous){

	float box21 = rect(coords-vec2(0.66,0.9),boxSize);
	vec3 color21 = inputColor * box21;

	float box22 = rect(coords-vec2(0.66,0.7),boxSize);
	vec3 color22 = analogous2 * box22;

	float box20 = rect(coords-vec2(0.66,0.5),boxSize);
	vec3 color20 = analogous3 * box20;

	float box23 = rect(coords-vec2(0.66,0.3),boxSize);
	vec3 color23 = analogous1 * box23;

	float box24 = rect(coords-vec2(0.66,0.1),boxSize);
	vec3 color24 = analogous4 * box24;
	
	outputColor += color20+color21+color22+color23+color24;
	}
	
if (Monochromatic){

	float box12 = rect(coords-vec2(0.83,0.9),boxSize);
	vec3 color12 = inputColor * box12;

	float box13 = rect(coords-vec2(0.83,0.7),boxSize);
	vec3 color13 = Desaturate(inputColor, .20) * box13;
	
	float box14 = rect(coords-vec2(0.83,0.5),boxSize);
	vec3 color14 = Desaturate(inputColor, .40) * box14;
	
	float box15 = rect(coords-vec2(0.83,0.3),boxSize);
	vec3 color15 = Desaturate(inputColor, .60) * box15;
	
	float box16 = rect(coords-vec2(0.83,0.1),boxSize);
	vec3 color16 = Desaturate(inputColor, .80) * box16;
	
	outputColor += color12+color13+color14+color15+color16;
	}	

gl_FragColor = vec4(outputColor, 1.0);
}
