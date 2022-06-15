package
{
	public class Timings
	{
		
		public static const MAGIC_NUMBER:Number = 0.1;
		
		public static const _violinStarts:Array = new Array(
			1.918, 17.129, 79.915, 140.837); 
			
		public static const _violinEnds:Array = new Array(
			-16.816, -31.443, -108.986, -169.911); 
		
		public static const _violinAnimations:Array = new Array(
			"spinning", "playing", "playing", "playing");
		
		public static const _violinTappingFrames:Array = new Array(
			8,9);
		
		public static const _vocalGalStarts:Array = new Array(
			17.129, 49.900, 64.671, 94.667, 140.821, 155.592); 
		
		public static const _vocalGalEnds:Array = new Array(
			-33.294, -63.359, -91.934, -106.734, -152.852, -171.763); 
		
		public static const _vocalGalAnimations:Array = new Array(
			"frontsinging", "frontsinging", "sidesinging", "sidesinging", "sidesinging", "frontsinging");

		public static const _vocalGuyStarts:Array = new Array(
			64.671, 87.280, 102.043, 125.404, 143.245, 148.049, 162.974); 
		
		public static const _vocalGuyEnds:Array = new Array(
			-84.232, -99.007, -110.994, -140.907, -145.475, -159.939, -171.763); 

		public static const _vocalGuyAnimations:Array = new Array(
			"sidesinging", "sidesinging", "sidesinging", "frontsinging", "sidesinging", "sidesinging", "frontsinging");
		
		public static const _fullSaxLoopStarts:Array = new Array(
			35.139, 42.520, 108.985, 116.367);
		
		public static const _saxStarts:Array = new Array(
			0.011895, 
			0.935201, 1.162912, 1.279600, 1.394872, 1.511276, 1.858224, 
			2.780963, 3.010373, 3.125362, 3.241483, 3.359304, 3.703986, 
			4.394483, 4.853303, 5.312407, 5.773210, 
			6.240528, 6.470788, 6.697366, 6.928759, 7.164966);
		
		public static const _saxEnds:Array = new Array(
			0.288887, 
			1.098337, 1.256942, 1.386092, 1.501080, 1.789401, 2.078571, 
			2.942683, 3.103554, 3.231570, 3.347125, 3.554335, 3.924899, 
			4.842824, 5.016723, 5.765847, 5.923035, 
			6.400265, 6.687736, 6.919979, 7.149389, 7.323288);
		
		public static const _fullSaxStartsLiteral:Array = new Array(
			35.139, 
			36.061, 36.290, 36.407, 36.520, 36.640, 36.985,
		    37.908, 38.137, 38.253, 38.366, 38.486, 38.830, 
		    39.521, 39.979, 40.441, 40.903,
		    41.369, 41.596, 41.827, 42.056, 42.288, 42.522);
		
		public static const _fullSaxEndsLiteral:Array = new Array(
			35.417, 
			36.225, 36.383, 36.513, 36.628, 36.918, 37.208, 
		    38.072, 38.231, 38.358, 38.476, 38.793, 39.053, 
		    39.969, 40.146, 40.893, 41.059,
		    41.526, 41.816, 42.046, 42.276, 420.450, 42.803);
		
		public static const _saxGuyJumpFrames:Array = new Array(
			13,14,15,16,17);
		
		public static const _jumpTimes:Array = new Array(
			17.076, 24.468, 79.845, 87.238, 
			94.630, 101.980, 140.756, 148.149, 155.541, 
			162.933);
		
		public static const _dancersStart:Number = 17;
		public static const _dancersEnd:Number = 1000;
		
		public static const _danceMoves:Array = new Array(
			"spin",
			"tapping",
			"idle",
			"hipwiggle",
			"leftlunge",
			"rightlunge"
		);
		
		public static const _danceSequences:Array = new Array(
			["tapping", "tapping", "tapping", "tapping", "leftlunge", "rightlunge"],
			["hipwiggle", "hipwiggle", "hipwiggle", "rightlunge", "rightlunge", "leftlunge"],
			["spin", "hipwiggle", "spin", "hipwiggle"],
			["rightlunge", "tapping", "tapping", "leftlunge", "tapping", "tapping"],
			["tapping", "tapping", "hipwiggle", "tapping", "tapping", "hipwiggle"],
			["spin", "rightlunge", "spin", "leftlunge"]);
		
		public function Timings()
		{
		}
	}
}